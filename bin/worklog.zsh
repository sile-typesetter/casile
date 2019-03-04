#!/bin/zsh

CASILEDIR=$(cd "$(dirname $0)/../" && pwd)

. ${CASILEDIR}/bin/functions.zsh

function gitcommits () {
	git rev-list --no-merges --reverse HEAD
}

function gitmodified () {
	git diff-tree --root --no-commit-id --name-only -r $@
}

function gitadded () {
	git diff --word-diff-regex=. $@ | addedchars | countchars
}

function gitremoved () {
	git diff --word-diff-regex=. $@ | removedchars | countchars
}

function addedchars () {
	perl -ne 'print $1 while /((?<=\{\+).+?(?=\+\}))/g'
}

function removedchars () {
	perl -ne 'print $1 while /((?<=\[\-).+?(?=\-\]))/g'
}

function gitattr () {
	git log --no-walk --format=$@
}

function gitparent () {
	git rev-parse --revs-only $1^ | read newparent
	test -z $newparent && echo 4b825dc642cb6eb9a060e54bf8d69288fbee4904 || echo $newparent
}

gitcommits |
	while read sha; do
		gitattr "%h %cI %aN" $sha | read short date author
		gitparent $sha | read parent
		gitmodified $sha |
			while read file; do
				gitadded ${parent}..$sha -- $file | read added
				gitremoved ${parent}..$sha -- $file | read removed
				test $(($added-$removed)) -eq 0 && continue
				echo "INSERT INTO commits VALUES ('$short', '$author', '$date', '$file', '$added', '$removed');"
			done
	done
