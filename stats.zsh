#!/bin/zsh

echo "TRANSLATION PROGRESS REPORT: $1"
echo "(Non-whitespace characters added)"

function countchars () {
    perl -pne 's/\s//g' | wc -c
}

cyclestart=$(date "+%Y-%m-1")
rootstart=$(git log --max-parents=0 -1 --format=%at)

git log --format=%aN -- "$1" |
    sort -u |
    while read author; do
        echo
        echo "========================================================================"
        echo "$author"
        echo "========================================================================"
        let user=0
        for i in $(seq 0 6); do
            let month=0
            since=$(date --date "$cyclestart - $i months" "+%F")
            until=$(date --date "$since + 1 month" "+%F")
            [[ $(date --date "$until" "+%s") -le $rootstart ]] && break
            start=$(date --date "$since" "+%Y-%m")
            echo
            echo "Month $start"
            echo "-------------"
            git log --format='%h %s' --author="$author" \
                --since="$since" --until="$until" \
                --follow -- "$1" |
                while read sha1 msg; do
                    before=$(git show "$sha1"^:"$1" 2>&- | countchars)
                    after=$(git show "$sha1":"$1" 2>&- | countchars)
                    change=$(($after-$before))
                    [[ $change -le 0 ]] && continue
                    let month=$month+$change
                    echo "$sha1  $(printf %10d $change) $msg"
                done
                echo "Total:   $(printf %10d $month)"
            let user=$user+$month
        done
        echo
        echo "Project: $(printf %10d $user)"
    done
