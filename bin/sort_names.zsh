#!/usr/bin/env zsh

CASILEDIR=$(cd "$(dirname $0)/../" && pwd)

HALF=$(($COLUMNS/2-20))

while read name; do
	clear
	rg -n "$name" < *.md |
		perl -pne "s/^(\d+:).*?(.{0,$HALF}$name.*)/\\1\\2/g" |
		cut -b1-$COLUMNS |
		rg -N --color=always "$name"
	echo "\n\n\t$name\n\n"
	read -k "reply?Is this a full proper name in English, Turkish, Other, None, Partial, Skip, or Quit? (e/t/o/n/p/s/q)" < /dev/tty
	case $reply in
		e|E) echo $name >> ${CASILEDIR}/names.en.txt ;;
		t|T) echo $name >> ${CASILEDIR}/names.tr.txt ;;
		o|O) echo $name >> ${CASILEDIR}/names.und.txt ;;
		p|P) echo $name >> ${CASILEDIR}/names.part.txt ;;
		n|N) echo $name >> ${CASILEDIR}/names.xx.txt ;;
		q|Q) exit 0 ;;
	esac
done
