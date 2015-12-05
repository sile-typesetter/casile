#!/bin/zsh

file="$1"
: ${2:=2}
let months=$2-1
echo "TRANSLATION PROGRESS REPORT: $file"
echo "(Non-whitespace characters added in last $months months)"

function countchars () {
    perl -pne 's/\s//g' | wc -c
}

cyclestart=$(date "+%Y-%m-1")
rootstart=$(git log --format=%at | sort -n | head -n1)
git log --format=%aN --follow -- "$file" |
    sort -u |
    while read author; do
        echo
        echo "========================================================================"
        echo "$author"
        echo "========================================================================"
        let user=0
        for i in $(seq 0 $months); do
            file=$1
            let month=0
            since=$(date --date "$cyclestart - $i months" "+%F")
            until=$(date --date "$since + 1 month" "+%s")
            [[ $until -lt $rootstart ]] && break
            start=$(date --date "$cyclestart - $i months" "+%Y-%m")
            since=$(date --date "$since" "+%s")
            [[ $since -lt $rootstart ]] && break
            echo
            echo "Month $start"
            echo "-------------"
            git log --format='%at|%h|%s|%an' \
                --follow --find-renames -- "$1" |
                while IFS='|' read at sha1 msg aut; do
					afterfile="$file"
					git -c core.quotepath=off log -1 $sha1 --stat --find-renames |
						grep ' => ' |
						perl -pne 's/ (.*) => (.*) \| .*/\1|\2/g;s/"//g' |
						IFS="|" read oldname newname
					[[ $newname == $file ]] && file="$oldname"
                    [[ $at -le $until ]] || continue
                    [[ $at -ge $since ]] || continue
                    [[ $aut == $author ]] || continue
                    after=$(git show "$sha1":"$afterfile" 2>&- | countchars)
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
