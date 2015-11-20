BASE := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/../" && pwd)
TOOLS := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT != basename $(BASE)
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)
SHELL = bash
OWNCLOUD = https://owncloud.alerque.com/remote.php/webdav/viachristus/$(PROJECT)

export TEXMFHOME := $(TOOLS)/texmf
export PATH := $(TOOLS)/bin:$(PATH)

.ONESHELL:
.PHONY: all ci clean init push sync_pre sync_post

all: $(TARGETS)

ci: init sync_pre all push sync_post

clean:
	git clean -xf

init:
	mkdir -p $(OUTPUT)

push:
	rsync -v \
		$(TARGETS) $(OUTPUT)/

sync_pre sync_post:
	pgrep -u $$USER -x owncloud ||\
		owncloudcmd -n -s $(OUTPUT) $(OWNCLOUD) 2>/dev/null

%-latex.pdf: %.md
	pandoc \
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
		-V geometry="paperwidth=135mm" \
		-V geometry="paperheight=195mm" \
		-V geometry="outer=15mm" \
		-V geometry="inner=25mm" \
		-V geometry="top=20mm" \
		-V geometry="bottom=15mm" \
		-V geometry="footskip=18pt" \
		-V geometry="headsep=14pt" \
		--latex-engine=xelatex \
		--template=$(TOOLS)/template.tex \
		$< -o $@

%-2up.pdf: %.pdf
	pdfbook --short-edge --suffix 2up --noautoscale true -- $<

%-kitap.sil: %.md
	pandoc \
		--standalone \
		-V documentclass="book" \
		-V papersize="135mm x 195mm" \
		-V script=$(basename $<) \
		-V script=$(TOOLS)/viachristus \
		--template=$(TOOLS)/template.sil \
		$(basename $<).yaml $< -o $@

%-kitap.pdf: %-kitap.sil
	sile $< -o $@ # Generate TOC
	sile $< -o $@ # Final

%-kesme.pdf: %.pdf
	xelatex -jobname=$(basename $@) '\documentclass{scrbook}\usepackage[paperheight=210mm,paperwidth=148.5mm,layoutheight=195mm,layoutwidth=135mm,layouthoffset=7.5mm,layoutvoffset=6.75mm,showcrop]{geometry}\usepackage{pdfpages}\begin{document}\includepdf[pages=-,noautoscale,fitpaper=false]{$<}\end{document}'

%.epub %.odt %.docx: %.md
	pandoc $(basename $<).yaml $< -o $@

%.mobi: %.epub
	-kindlegen $<
