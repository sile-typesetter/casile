#!/usr/bin/env sh
set -e

pacman -S ghc stack

cd /tmp

git clone --depth 1 https://github.com/alerque/pandoc.git -b sile-writer-pr
cd pandoc

sed -i -e '10s!--test !!' Makefile
make quick
