#!/usr/bin/env zsh

while read name; do
	clear
	echo "\n\n\t$name\n\n"
	read -k "reply?Is this a full proper name in English, Turkish, or any other language? (e/t/o/n)" < /dev/tty
	case $reply in
		e|E) echo $name >> avadanlik/names.en.txt ;;
		t|T) echo $name >> avadanlik/names.tr.txt ;;
		o|O|u|U) echo $name >> avadanlik/names.und.txt ;;
	esac
done
