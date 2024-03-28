#!/usr/bin/env sh
set -e

finder () {
    test -d "$1" || return 0
    /usr/bin/find "$@" -type f | sort -bdi | xargs printf ' %s'
}

printf '\n%s' "LUALIBRARIES ="
finder lua-libraries -name '*.lua'
