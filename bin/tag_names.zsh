#!/usr/bin/env zsh

lang=$1 ; shift
names=$1 ; shift

for source in $@; do
	while read name; do
		clear
		git co -- $source
		msg="Tag instances of name '$name' as language '$lang'"
		perl -i -pne "s/(?<!\})$name(?!\})/\\\\lang$lang{$name}/g if ! /^(\[\^\d+\]|#+ )/" -- $source
		git add -- $source
		git --no-pager diff --cached -U0 --word-diff=color --minimal --ignore-all-space -- $source |
			grep -v '@@'
		git diff-index --quiet --cached HEAD && continue 1
		read -q "?$msg? (y/n)" || continue 1
		git commit -m "[auto] $msg"
	done < $names
done
