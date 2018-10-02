#!/bin/zsh

CASILEDIR=$(cd "$(dirname $0)/../" && pwd)

basename="$1"
: ${2:=2}
let months=$2-1

. ${CASILEDIR}/bin/functions.zsh

function list_sources () {
	git ls-files | pcregrep "$basename.*(md|yml)"
}

function list_authors () {
	list_sources $1 |
		xargs -n1 git log --format=%aN --follow -- |
		sort -u
}

function list_commits () {
	basename=$1
	month=$2
	author=$3
	list_sources $basename |
		xargs -n1 git log --format='%at|%h|%s|%an'  --follow --find-renames -- |
		while IFS='|' read at sha1 msg aut; do
			inrange $month $at || continue
			[[ $aut == $author ]] || continue
			echo $at $sha1
		done |
		sort -u |
		cut -d\  -f2
}

function calculate_affected () {
	sha1=$1
	basename=$2
	before=0 beforew=0
	after=0 afterw=0
	git diff-tree --no-commit-id --name-only -r $sha1 |
		pcregrep "$basename.*(md|yml)" |
		while read file; do
			let after="$after + $(git show "$sha1:$file" 2>&- | countchars)"
			let before="$before + $(git show "$sha1^:$file" 2>&- | countchars)"
		done
	change=$(($after-$before))
	echo $after $change
}

function inrange () {
	month=$1
	at=$2
	since=$(date --date "$cyclestart - $month months" "+%F")
	until=$(date --date "$since + 1 month" "+%s")
	[[ $until -lt $rootstart ]] && return 1
	start=$(date --date "$cyclestart - $month months" "+%Y-%m")
	since=$(date --date "$since" "+%s")
	[[ $at -ge $until ]] && return 1
	[[ $at -le $since ]] && return 1
	return 0
}

function itemwords () {
	m4 ${CASILEDIR}/casile.m4 <(cat $1.md) |
		countwords
}

echo "ÇEVİRİ VE EDİTÖRLÜK RAPÖRÜ: $basename"
echo "(Son hali $(itemwords $basename) kelime)"

cyclestart=$(date "+%Y-%m-1")
rootstart=$(git log --format=%at | sort -n | head -n1)
list_authors $basename |
	while read author; do
        let usertotal=0
		echo
		echo "========================================================================"
		echo "$author"
		echo "========================================================================"
		for month in $(seq 0 $months); do
			let monthtotal=0
			echo
			echo "Ay $(date --date "$cyclestart - $month months" "+%Y-%m")"
			echo "-------------"
			list_commits $basename $month "$author" |
			while read sha1; do
				calculate_affected $sha1 $basename |
					read after change
				[[ $change -ge 0 ]] || continue
				let monthtotal=$monthtotal+$change
				# git log -1 --date="format:%m-%d %H:%M" --format="%ad (%h) %s" $sha1
				echo "Karakter: $(printf %8d $after) [$(printf %+8d $change)]" “$(git log -1 --format="%s" $sha1 | perl -pe 's/(?<=.{39}).{1,}$/…/')”
			done
			let usertotal=$usertotal+$monthtotal
		done
		echo
        echo "Toplam: $(printf %+20d $usertotal)"
	done
echo
