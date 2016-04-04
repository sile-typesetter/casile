#!/usr/bin/env zsh
UPSHA='0'
function upsha() {
	let UPSHA=$UPSHA+1
	[[ $(git branch -r --contains "HEAD~${UPSHA}" | wc -l) -eq 1 ]] && git rev-parse --short "HEAD~$UPSHA^" || false
}
while upsha ; do
	:
done | tail -n 1
