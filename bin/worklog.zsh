#!/bin/zsh

CASILEDIR=$(cd "$(dirname $0)/../" && pwd)

. ${CASILEDIR}/bin/functions.zsh

function gitcommits () {
	git rev-list --reverse HEAD
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

gitcommits |
	while read sha; do
		gitattr "%h %cI %aN" $sha | read short date author
		gitmodified $sha |
			while read file; do
				gitadded $sha -- $file | read added
				gitremoved $sha -- $file | read removed
				test $(($added-$removed)) -eq 0 && continue
				echo "INSERT INTO commits VALUES ('$short', '$date', '$author', '$file', '$added', '$removed');"
			done
	done
