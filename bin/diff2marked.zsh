#!/usr/bin/env zsh

cd $MARKED_ORIGIN
if git diff --quiet -- $MARKED_PATH; then
    cat -
    exit
else
    cat - > /dev/null
    git diff --no-color --word-diff -U99999 -- $MARKED_PATH |
        sed -e '1,5d' \
            -e 's/\\[A-Za-z0-9]*{\(.*\)}/\1/g' \
            -e 's/\\[A-Za-z0-9]* //g' \
            -e 's/ *{[-\.].*}$//g' \
            -e 's/\\[A-Za-z0-9]*{\(.*\)}/\1/g' \
            -e 's/\[-/{--/g' -e 's/-\]/--}/g' \
            -e 's/{+/{++/g' -e 's/+}/++}/g'
fi
