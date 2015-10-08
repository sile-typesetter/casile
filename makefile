BASE := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/../" && pwd)
TOOLS := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT != basename $(BASE)
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)
SHELL = bash
OWNCLOUD = https://owncloud.alerque.com/remote.php/webdav/viachristus/$(PROJECT)

export TEXMFHOME := $(TOOLS)/texmf
export PATH := $(TOOLS)/bin:$(PATH)

.ONESHELL:
.PHONY: all

all: $(TARGETS)

ci: init sync_pre all push sync_post

init:
	mkdir -p $(OUTPUT)

push:
	rsync -av --prune-empty-dirs \
		--include '*/' \
		--include='*.pdf' \
		--include='*.epub' \
		--include='*.mobi' \
		--exclude='*' \
		$(BASE)/ $(OUTPUT)/

sync_pre sync_post:
	pgrep -u $$USER -x owncloud ||\
		owncloudcmd -n -s $(OUTPUT) $(OWNCLOUD) 2>/dev/null

%.pdf: %.md
	pandoc \
		--chapters \
		-V links-as-notes \
		-V toc \
		-V lang="turkish" \
		-V mainfont="Crimson" \
		-V sansfont="Libertine Sans" \
		-V monofont="Hack" \
		-V fontsize="12pt" \
		-V documentclass="scrbook" \
		-V papersize="digest" \
		--latex-engine=xelatex \
		--template=$(TOOLS)/template.tex \
		$< -o $(basename $<).pdf

%.epub: %.md
	pandoc \
		$< -o $(basename $<).epub

%.mobi: %.md
	pandoc \
		$< -o $(basename $<).mobi

%.odt: %.md
	pandoc \
		$< -o $(basename $<).odt

%.docx: %.md
	pandoc \
		$< -o $(basename $<).docx
