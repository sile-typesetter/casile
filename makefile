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

%-kitap.pdf: %.md
	pandoc \
		--chapters \
		-V links-as-notes \
		-V toc \
		-V lang="turkish" \
		-V mainfont="Crimson" \
		-V sansfont="Montserrat" \
		-V monofont="Hack" \
		-V fontsize="13pt" \
		-V linkcolor="black" \
		-V scrheadings \
		-V documentclass="scrbook" \
		-V geometry="paperheight=210mm" \
		-V geometry="paperwidth=148mm" \
		-V geometry="layoutheight=195mm" \
		-V geometry="layoutwidth=135mm" \
		-V geometry="layouthoffset=7.5mm" \
		-V geometry="layoutvoffset=6.5mm" \
		-V geometry="outer=14mm" \
		-V geometry="inner=26mm" \
		-V geometry="top=20mm" \
		-V geometry="bottom=12mm" \
		-V geometry="footskip=18pt" \
		-V geometry="headsep=12pt" \
		-V geometry="showcrop" \
		--latex-engine=xelatex \
		--template=$(TOOLS)/template.tex \
		$< -o $(basename $<)-kitap.pdf

%.pdf: %.md
	pandoc \
		-V links-as-notes \
		-V toc \
		-V lang="turkish" \
		-V mainfont="Crimson" \
		-V sansfont="Libertine Sans" \
		-V monofont="Hack" \
		-V fontsize="13pt" \
		-V documentclass="scrbook" \
		-V papersize="a4paper" \
		--latex-engine=xelatex \
		--template=$(TOOLS)/template.tex \
		$< -o $(basename $<).pdf

%.epub: %.md
	pandoc \
		$(shell test -f "$(EBOOKCOVER)" && echo "--epub-cover-image=$(BASE)/$(EBOOKCOVER)") \
		$< -o $(basename $<).epub

%.mobi: %.epub
	-kindlegen $<

%.odt: %.md
	pandoc \
		$< -o $(basename $<).odt

%.docx: %.md
	pandoc \
		$< -o $(basename $<).docx
