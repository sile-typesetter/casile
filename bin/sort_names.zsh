#!/usr/bin/env zsh

while read name; do
	clear
	echo "\n\n\t$name\n\n"
	read -k "reply?Is this a full proper name in English, Turkish, Other, None or Skip? (e/t/o/n/s)" < /dev/tty
	case $reply in
		e|E) echo $name >> avadanlik/names.en.txt ;;
		t|T) echo $name >> avadanlik/names.tr.txt ;;
		o|O) echo $name >> avadanlik/names.und.txt ;;
		n|n) echo $name >> avadanlik/names.xx.txt ;;
	esac
done
