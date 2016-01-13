#!/bin/zsh

file="$1"
: ${2:=2}
let months=$2-1
echo "TRANSLATION PROGRESS REPORT: $file"
echo "(Non-whitespace characters added in last $months months)"

function countchars () {
    perl -pne 's/\s//g' | wc -c
}

function countwords () {
    perl -pne 's/[^\s\w]//g' | wc -w
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
                    afterw=$(git show "$sha1":"$afterfile" 2>&- | countwords)
                    before=$(git show "$sha1"^:"$file" 2>&- | countchars)
                    beforew=$(git show "$sha1"^:"$file" 2>&- | countwords)
                    change=$(($after-$before))
                    changew=$(($afterw-$beforew))
					[[ $change -le 0 ]] && continue
                    let month=$month+$change
                    echo "$sha1  Chars: $(printf %8d $after) [$(printf %8d $change)], Words: $(printf %8d $afterw) [$(printf %6d $changew)] $msg"
                done
				echo
                echo "Total:   $(printf %10d $month)"
            let user=$user+$month
        done
        echo
        echo "Project: $(printf %10d $user)"
    done
