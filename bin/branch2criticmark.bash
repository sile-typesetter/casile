#!/usr/bin/env zsh

BRANCH=${1}
FILE=${2}
WT=$(mktemp -d -u worktree-diff.XXXXXX)

trap 'rm -rf ${WT}' EXIT SIGHUP SIGTERM

macros=avadanlik/viachristus.m4

git worktree prune > /dev/null
git worktree add --detach ${WT} ${BRANCH} > /dev/null

m4 ${macros} ${WT}/${FILE} | git hash-object --stdin -w | read A
m4 ${macros} ${FILE} | git hash-object --stdin -w | read B

if git diff ${A}..${B} --quiet; then
    git show ${B}
else
    git diff --no-color --word-diff -U99999 ${A}..${B} |
        sed -e '1,5d' |
            perl -pn \
                -e 's/\[-[^\]]*?-\]\{\+([^\}]*?==.*?)\+\}/\1/g' |
            sed \
                -e 's/\[-/{--/g' -e 's/-\]/--}/g' \
                -e 's/{+/{++/g' -e 's/+}/++}/g'
fi
