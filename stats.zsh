#!/bin/zsh

file="$1"
echo "TRANSLATION PROGRESS REPORT: $file"
echo "(Non-whitespace characters added)"

function countchars () {
    perl -pne 's/\s//g' | wc -c
}

cyclestart=$(date "+%Y-%m-1")
rootstart=$(git log --max-parents=0 -1 --format=%at)
git log --format=%aN --follow -- "$file" |
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
            until=$(date --date "$since + 1 month" "+%s")
            [[ $until -le $rootstart ]] && break
            start=$(date --date "$since" "+%Y-%m")
            echo
            echo "Month $start"
            echo "-------------"
            git log --format='%at|%h|%s|%an' \
                --since="$since" \
                --follow --find-renames -- "$1" |
                while IFS='|' read ts sha1 msg aut; do
                    after=$(git show "$sha1":"$file" 2>&- | countchars)
					git -c core.quotepath=off log -1 $sha1 --stat --find-renames |
						grep ' => ' |
						perl -pne 's/ (.*) => (.*) \| .*/\1|\2/g;s/"//g' |
						IFS="|" read oldname newname
					[[ $newname == $file ]] && file="$oldname"
					[[ $ts -le $until ]] || continue
					[[ $aut == $author ]] || continue
                    before=$(git show "$sha1"^:"$file" 2>&- | countchars)
                    change=$(($after-$before))
                    [[ $change -le 0 ]] && continue
                    let month=$month+$change
                    echo "$sha1  $(printf %10d $change) $msg"
                done
				echo
                echo "Total:   $(printf %10d $month)"
            let user=$user+$month
        done
        echo
        echo "Project: $(printf %10d $user)"
    done
