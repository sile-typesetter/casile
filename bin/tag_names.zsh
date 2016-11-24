#!/usr/bin/env zsh

lang=$1 ; shift
names=$1 ; shift

for source in $@; do
	while read name; do
		git co -- $source
		msg="Tag instances of name '$name' as language '$lang'"
		perl -i -pne "s/$name/\\\\lang$lang{$name}/g" $source
		git diff --word-diff=color --ignore-all-space -- $source
		read -q "?$msg? (y/n)" || continue 1
		git add -- $source
		git commit -m "[auto] $msg"
	done < $names
done
