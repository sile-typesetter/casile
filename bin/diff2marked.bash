#!/usr/bin/env bash

cd $MARKED_ORIGIN
if git diff --quiet -- $MARKED_PATH; then
    cat -
    exit
else
    cat - > /dev/null
    git diff --no-color --word-diff -U99999 -- $MARKED_PATH |
        sed -e '1,5d;s/\\[A-Za-z0-9]*{\(.*\)}/\1/g;s/\\[A-Za-z0-9]* //g;s/ *{[-\.].*}$//g;s/\\[A-Za-z0-9]*{\(.*\)}/\1/g;s/\[-/{--/g;s/-\]/--}/g;s/{\+/{++/g;s/\+}/++}/g'
fi
