#!/bin/zsh

CASILEDIR=$(cd "$(dirname $0)/../" && pwd)

. ${CASILEDIR}/bin/functions.zsh

function gitcommits () {
	git rev-list --reverse HEAD
}

function gitmodified () {
	git diff-tree --root --no-commit-id --name-only -r $@ |
		grep -v '^\.' |
		grep '\.'
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

echo "commits:"
gitcommits |
	while read sha; do
		echo "- sha:" $(gitattr %h $sha)
		echo "  date:" $(gitattr %cI $sha)
		echo "  author:" $(gitattr %aN $sha)
		echo "  files:"
		gitmodified $sha |
			while read file; do
				echo "  - name: $file"
				echo "    added:" $(gitadded $sha -- $file)
				echo "    removed:" $(gitremoved $sha -- $file)
			done
	done
