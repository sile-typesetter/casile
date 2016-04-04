#!/usr/bin/env bash
if git diff ${1}..HEAD --quiet -- ${2}; then
    cat $1 
else
    git diff --no-color --word-diff -U99999 ${1}..HEAD -- ${2} |
    sed -e '1,5d' |
        perl -pn \
            -e 's/\[-.*?-\]\{\+(.*?==.*?)\+\}/\1/g' |
        sed \
            -e 's/\[-/{--/g' -e 's/-\]/--}/g' \
            -e 's/{+/{++/g' -e 's/+}/++}/g'
fi
