#!/usr/bin/env zsh
WT=$(mktemp -d -u worktree-diff.XXXXXX)

trap 'rm -rf ${WT}' EXIT SIGHUP SIGTERM

macros=avadanlik/viachristus.m4

git worktree prune
git worktree add --detach ${WT} ${1}

m4 ${macros} ${WT}/${2} | git hash-object --stdin -w | read A
m4 ${macros} ${2} | git hash-object --stdin -w | read B

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
