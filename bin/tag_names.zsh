#!/usr/bin/env zsh

lang=$1 ; shift
names=$1 ; shift

touch rejects.txt

function reject () {
	echo $@ >> rejects.txt
}

function tag_name () {
	md=$1 ; shift
	name=$@
	clear
	git reset
	git checkout HEAD -- $md
	msg="Tag instances of name '$name' as language '$lang'"
	perl -i -pne "s/(?<!\{)$name(?![^\{\}]*\})/\\\\lang$lang{$name}/g if ! /^(\[\^\d+\]|#+ )/" -- $md
	git add -- $md
	git --no-pager diff --cached -U0 --word-diff=color --word-diff-regex=. --minimal --ignore-all-space -- $md |
		grep -v '@@'
	git diff-index --quiet --cached HEAD && continue 1
	read -q "?$msg? (y/n)" || { reject $name && continue 1 }
	git commit -m "[auto] $msg"
}

# First catch instances of whole names
for file in $@; do
	perl -e 'print sort { length($b) <=> length($a) } <>' < $names |
		grep -vxf rejects.txt |
		while read name; do
			tag_name $file $name
		done
	git reset
	git checkout HEAD -- $file
done

# Next try permutations of first, last, etc. (within reason)
for file in $@; do
	perl -pne 's/ /\n/g' < $names |
		sort -u |
		pcregrep -v '^\w{1,2}\.?$' |
		perl -e 'print sort { length($b) <=> length($a) } <>' |
		grep -vxf rejects.txt |
		while read name; do
			tag_name $file $name
		done
	git reset
	git checkout HEAD -- $file
done