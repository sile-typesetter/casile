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

%-latex.pdf: %.md
	/home/caleb/projects/pandoc/dist/build/pandoc/pandoc \
		--chapters \
		-V links-as-notes \
		-V toc \
		-V mainlang="turkish" \
		-V mainfont="Crimson" \
		-V sansfont="Montserrat" \
		-V monofont="Hack" \
		-V fontsize="12pt" \
		-V linkcolor="black" \
		-V scrheadings \
		-V documentclass="scrbook" \
		-V geometry="paperheight=195mm" \
		-V geometry="paperwidth=135mm" \
		-V geometry="outer=14mm" \
		-V geometry="inner=24mm" \
		-V geometry="top=20mm" \
		-V geometry="bottom=12mm" \
		-V geometry="footskip=18pt" \
		-V geometry="headsep=12pt" \
		-V geometry="showcrop" \
		--latex-engine=xelatex \
		--template=$(TOOLS)/template.tex \
		$< -o $(basename $<)-latex.pdf

%-2up.pdf: %.pdf
	pdfbook --short-edge --suffix 2up --noautoscale true -- $<

%.sil: %.md
	/home/caleb/projects/pandoc/dist/build/pandoc/pandoc \
		--standalone \
		--parse-raw \
		-V mainlang="tr" \
		-V documentclass="book" \
		-V papersize="135mm x 195mm" \
		-V include=$(TOOLS)/viachristus \
		-V script=$(TOOLS)/viachristus \
		--template=$(TOOLS)/template.sil \
		-f markdown+raw_tex -t sile+raw_tex \
		$< -o $(basename $<).sil

%-sile.pdf: %.sil
	sile $< -o $(basename $<)-sile.pdf # Generate TOC
	#sile $< -o $(basename $<).pdf # Final

%-kesme.pdf: %.pdf
	xelatex -jobname=$(basename $<)-kesme '\documentclass{scrbook}\usepackage[paperheight=210mm,paperwidth=148mm,layoutheight=195mm,layoutwidth=135mm,layouthoffset=7.5mm,layoutvoffset=6.5mm,showcrop]{geometry}\usepackage{pdfpages}\begin{document}\includepdf[pages=-,noautoscale,fitpaper=false]{$<}\end{document}'

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
