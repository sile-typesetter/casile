#!/usr/bin/env zsh

while read name; do
	clear
	rg --color=always -m 5 "$name" < *.md | perl -pne "s/.*?(.{0,50}$name.{0,20}).*/\\1/g"
	echo "\n\n\t$name\n\n"
	read -k "reply?Is this a full proper name in English, Turkish, Other, None, Partial, or Skip? (e/t/o/n/p/s)" < /dev/tty
	case $reply in
		e|E) echo $name >> avadanlik/names.en.txt ;;
		t|T) echo $name >> avadanlik/names.tr.txt ;;
		o|O) echo $name >> avadanlik/names.und.txt ;;
		p|P) echo $name >> avadanlik/names.part.txt ;;
		n|n) echo $name >> avadanlik/names.xx.txt ;;
	esac
done
