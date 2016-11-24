#!/usr/bin/env zsh

HALF=$(($COLUMNS/2-20))

while read name; do
	clear
	rg --color=always "$name" < *.md | perl -pne "s/.*?(.{0,$HALF}$name.*)/\\1/g" | cut -b1-$COLUMNS
	echo "\n\n\t$name\n\n"
	read -k "reply?Is this a full proper name in English, Turkish, Other, None, Partial, Skip, or Quit? (e/t/o/n/p/s/q)" < /dev/tty
	case $reply in
		e|E) echo $name >> avadanlik/names.en.txt ;;
		t|T) echo $name >> avadanlik/names.tr.txt ;;
		o|O) echo $name >> avadanlik/names.und.txt ;;
		p|P) echo $name >> avadanlik/names.part.txt ;;
		n|n) echo $name >> avadanlik/names.xx.txt ;;
		q|Q) exit 0 ;;
	esac
done
