#!/usr/bin/env bash

cat - > /dev/null
cd $MARKED_ORIGIN
git diff --no-color --word-diff -U99999 -- $MARKED_PATH |
	sed -e '1,5d;s/ *{[-\.].*}$//g;s/\[-/{--/g;s/-\]/--}/g;s/{\+/{++/g;s/\+}/++}/g'
