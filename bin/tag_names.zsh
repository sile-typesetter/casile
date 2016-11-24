#!/usr/bin/env zsh

lang=$1 ; shift
names=$1 ; shift

function tag_name () {
	md=$1 ; shift
	name=$@
	clear
	git co -- $md
	msg="Tag instances of name '$name' as language '$lang'"
	perl -i -pne "s/(?<!\{)$name(?!\})/\\\\lang$lang{$name}/g if ! /^(\[\^\d+\]|#+ )/" -- $md
	git add -- $md
	git --no-pager diff --cached -U0 --word-diff=color --word-diff-regex=. --minimal --ignore-all-space -- $md |
		grep -v '@@'
	git diff-index --quiet --cached HEAD && continue 1
	read -q "?$msg? (y/n)" || continue 1
	git commit -m "[auto] $msg"
}

# First catch instances of whole names
for file in $@; do
	perl -e 'print sort { length($b) <=> length($a) } <>' < $names |
		while read name; do
			tag_name $file $name
		done
done

# Next try permutations of first, last, etc. (within reason)
for file in $@; do
	perl -ne 's/ /\n/g;print if /^.{3,}/' < $names |
		perl -e 'print sort { length($b) <=> length($a) } <>' |
		while read name; do
			tag_name $file $name
		done
done
