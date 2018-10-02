#!/usr/bin/env zsh

function countchars () {
    perl -pne 's/\s//g' | wc -c
}

function countwords () {
    perl -pne 's/[^\s\w]//g' | wc -w
}
