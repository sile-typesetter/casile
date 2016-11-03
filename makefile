BASE := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/../" && pwd)
TOOLS := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT != basename $(BASE)
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)
INPUT  = ${HOME}/ownCloud/viachristus/$(PROJECT)
SHELL = bash
OWNCLOUD = https://owncloud.alerque.com/remote.php/webdav/viachristus/$(PROJECT)
SOURCES := $(wildcard *.md)
TARGETS := ${SOURCES:.md=}
FORMATS ?= pdf epub mobi app
LAYOUTS ?= a4 a5trim octavo halfletter cep app
PRINTS ?=
#PRINTS ?= kesme kesme-ciftyonlu
DRAFT ?= false
DIFF ?= true
CROP ?= false
STATS_MONTHS ?= 1
PRE_SYNC ?= true

SILE ?= sile

# CI runners need help getting the branch name because of funky checkouts
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(BRANCH),HEAD)
ifeq ($(shell git rev-parse master),$(shell git rev-parse HEAD))
BRANCH = master
else
BRANCH = $(CI_BUILD_REF_NAME)
endif
endif

# If we are directly on a tagged commit, build it to a special directory
TAG = $(shell git describe --tags)
TAG_SEQ = $(shell git describe --long --tags | rev | cut -d- -f2)
ifeq ($(TAG_SEQ),0)
BRANCH = master
OUTPUT := $(OUTPUT)/$(TAG)
PRE_SYNC = false
DIFF = false
else

# If we are not on the master branch, guess the parent and output to a directory
ifneq ($(BRANCH),master)
PARENT ?= $(shell $(TOOLS)/bin/findfirstnonunique.zsh)
OUTPUT := $(OUTPUT)/$(BRANCH)
PRE_SYNC = false
endif

# If the environment has information about a parent, override the calculated one
_BRANCH = PARENT_$(subst +,_,$(subst -,_,$(BRANCH)))
ifneq ($($(_BRANCH)),)
PARENT = $($(_BRANCH))
endif

endif

# If our tag or branch has a slash in it, treat the first bit as a target
# and only build that item not the whole project.
TAG_BASE = $(shell git describe --tags | cut -d/ -f1)
TAG_NAME = $(TAG)
ifneq ($(TAG),$(TAG_BASE))
TAG_NAME = $(shell git describe --tags | cut -d/ -f2)
TARGETS = $(TAG_BASE)
endif

# If there is a layout associated with a tag, only build that layout
ifdef LAYOUT_$(TAG_NAME)
LAYOUTS = $(LAYOUT_$(TAG_NAME))
FORMATS = pdf
endif

# If there is a format associated with a tag, only build that format
ifdef FORMAT_$(TAG_NAME)
FORMATS = $(FORMAT_$(TAG_NAME))
endif

export TEXMFHOME := $(TOOLS)/texmf
export PATH := $(TOOLS)/bin:$(PATH)
export HOSTNAME := $(shell hostname)
export SILE_PATH := $(TOOLS)/
export PROJECT := $(PROJECT)

.ONESHELL:
.SECONDEXPANSION:
.PHONY: all ci clean init sync_pre sync_post $(TARGETS) %.app
.SECONDARY:
.PRECIOUS: %.pdf %.sil %.toc

all: $(TARGETS)

ci: init clean sync_pre all sync_post stats

clean:
	git clean -xf

$(TARGETS): $(foreach FORMAT,$(FORMATS),$$@.$(FORMAT))

init:
	mkdir -p $(OUTPUT)

define sync_owncloud
	-pgrep -u $(USER) -x owncloud || \
		owncloudcmd -n -s $(INPUT) $(OWNCLOUD) 2>/dev/null
endef

sync_pre:
	$(call sync_owncloud)
	-$(PRE_SYNC) && rsync -ctv \
		$(foreach FORMAT,$(FORMATS),$(OUTPUT)/*-$(FORMAT)*.{pdf,info,png} $(OUTPUT)/*.$(FORMAT)) $(BASE)/

sync_post:
	-rsync -ctv \
		$(foreach FORMAT,$(FORMATS),*-$(FORMAT)*.{pdf,info,png} *.$(FORMAT)) $(OUTPUT)/
	$(call sync_owncloud)

%.pdf: $(foreach LAYOUT,$(LAYOUTS),$$*-$(LAYOUT).pdf) $(foreach LAYOUT,$(LAYOUTS),$(foreach PRINT,$(PRINTS),$$*-$(LAYOUT)-$(PRINT).pdf)) $(MAKEFILE_LIST) ;

%.pdf: %.sil $(TOOLS)/viachristus.lua $(MAKEFILE_LIST)
	@$(shell test -f "$<" || echo exit 0)
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	# If in draft mode don't rebuild for TOC and do output debug info, otherwise
	# account for TOC issue: https://github.com/simoncozens/sile/issues/230
	if $(DRAFT); then \
		$(SILE) -d viachristus $< -o $@ ;\
	else \
		export pg0="$$(test -f $<.toc && ( pdfinfo $@ | grep Pages: | awk '{print $$2}' ) || echo 0)" ;\
		$(SILE) $< -o $@ ;\
		export pg1="$$(pdfinfo $@ | grep Pages: | awk '{print $$2}')" ;\
		[[ $${pg0} -ne $${pg1} ]] && $(SILE) $< -o $@ ||: ;\
		export pg2="$$(pdfinfo $@ | grep Pages: | awk '{print $$2}')" ;\
		[[ $${pg1} -ne $${pg2} ]] && $(SILE) $< -o $@ ||: ;\
	fi
	# If we have a specil cover page for this format, swap it out for the half title page
	if [[ -f $*-kapak.pdf ]]; then
		pdftk $@ dump_data_utf8 output $*.dat
		pdftk C=$*-kapak.pdf B=$@ cat C1 B2-end output $*.tmp.pdf
		pdftk $*.tmp.pdf update_info_utf8 $*.dat output $@
		rm $*.tmp.pdf
	fi

%-kesme.pdf: %.pdf $(MAKEFILE_LIST)
	@if [ ! "" = "$(findstring octavo,$@)$(findstring halfletter,$@)" ]; then\
		export PAPER_OPTS="paperwidth=210mm,paperheight=297mm" ;\
	elif [ ! "" = "$(findstring a5trim,$@)" ]; then\
		export PAPER_OPTS="paperheight=210mm,paperwidth=148.5mm,layoutheight=195mm,layoutwidth=135mm,layouthoffset=7.5mm,layoutvoffset=6.75mm" ;\
	elif [ ! "" = "$(findstring cep,$@)" ]; then\
		export PAPER_OPTS="paperheight=210mm,paperwidth=148.5mm,layoutheight=170mm,layoutwidth=110mm,layouthoffset=19.35mm,layoutvoffset=20.08mm" ;\
	else \
		exit 0 ;\
	fi
	-xelatex -jobname=$(basename $@) -interaction=batchmode \
		"\documentclass{scrbook}\usepackage[$$PAPER_OPTS,showcrop]{geometry}\usepackage{pdfpages}\begin{document}\includepdf[pages=-,noautoscale,fitpaper=false]{$<}\end{document}"

%-ciftyonlu.pdf: %.pdf $(MAKEFILE_LIST)
	-pdfbook --short-edge --suffix ciftyonlu --noautoscale true -- $<

define versioninfo
	echo -en "$(basename $1)@"
	if [[ "$(BRANCH)" == master ]]; then
		git describe --tags >/dev/null 2>/dev/null || echo -en "$(BRANCH)-"
		git describe --long --tags --always --dirty=* | cut -d/ -f2 | xargs echo -en
	else
		$(DIFF) && echo -en "$(PARENT)→"
		echo -en "$(BRANCH)-"
		git rev-list --boundary $(PARENT)...HEAD | grep -v - | wc -l | xargs -iX echo -en "X-"
		git describe --always | cut -d/ -f2 | xargs echo -en
	fi
endef

define urlinfo
	echo -en "https://yayinlar.viachristus.com/$(basename $1)"
endef

define preprocess_markdown
	if [[ "$(BRANCH)" == master ]]; then
		m4 $(TOOLS)/viachristus.m4 $(wildcard $(PROJECT).m4) $(wildcard $(basename $1).m4) $1 |
			smart_quotes.pl
	else
		($(DIFF) && branch2criticmark.bash $(PARENT) $1 || m4 $(TOOLS)/viachristus.m4 $(wildcard $(PROJECT).m4) $(wildcard $(basename $1).m4) $1) |
			smart_quotes.pl |
			sed -e 's#{==#\\criticHighlight{#g' -e 's#==}#}#g' \
				-e 's#{>>#\\criticComment{#g'   -e 's#<<}#}#g' \
				-e 's#{++#\\criticAdd{#g'       -e 's#++}#}#g' \
				-e 's#{--#\\criticDel{#g'       -e 's#--}#}#g'
	fi
endef

define build_sile
	pandoc --standalone \
		--wrap=preserve \
		-V documentclass="book" \
		-V papersize="$4" \
		-V versioninfo="$(shell $(call versioninfo,$1))" \
		-V urlinfo="$(shell $(call urlinfo,$1))" \
		-V qrimg="./$(basename $1)-url.png" \
		$(shell test -f "$(basename $1).lua" && echo "-V script=$(basename $1)") \
		$(shell test -f "$(PROJECT).lua" && echo "-V script=$(PROJECT)") \
		$(shell $5 || $(CROP) && echo "-V script=$(TOOLS)/crop") \
		-V script=$(TOOLS)/layout-$3 \
		-V script=$(TOOLS)/viachristus \
		--template=$(TOOLS)/template.sil \
		$(TOOLS)/viachristus.yml \
		$(shell test -f "$(PROJECT).yml" && echo "$(PROJECT).yml") \
		$(shell test -f "$(basename $1).yml" && echo "$(basename $1).yml") \
		<($(call preprocess_markdown,$1)) -o $2-$3.sil
endef

%-a4.sil: %.md $$(wildcard $$*.yml $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-a4.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),a4,false)

%-a5trim.sil: %.md $$(wildcard $$*.yml $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-a5trim.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),133mm x 195mm,true)

%-octavo.sil: %.md $$(wildcard $$*.yml $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-octavo.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),432pt x 648pt,true)

%-halfletter.sil: %.md $$(wildcard $$*.yml $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-halfletter.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),halfletter,true)

%-cep.sil: %.md $$(wildcard $$*.yml $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-cep.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),110mm x 170mm,true)

%-app.sil: %.md $$(wildcard $$*.yml $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-app.lua $$(shell test -f $$*-epub-kapak.png && echo $$*-app-kapak.pdf) $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),80mm x 128mm,false)

%.sil.toc: %.pdf ;

%.app: %-app.info ;

%-app.info: %-app.sil.toc %-app.pdf %-app-kapak.png $(MAKEFILE_LIST) $(TOOLS)/bin/toc2breaks.lua $(TOOLS)/bin/share_link.py
	echo -e "# $* (Complete)\n" > $@
	echo " * [$*-app.pdf]($$($(TOOLS)/bin/share_link.py $*-app.pdf))" >> $@ ;\
	echo -e "\n# $* (Chunks)\n" >> $@
	$(TOOLS)/bin/toc2breaks.lua $< |\
		while read no range; do \
			export output="$*-app-$$no.pdf" ;\
			pdftk $*-app.pdf cat $$range output $$output ;\
			echo " * [$$output]($$($(TOOLS)/bin/share_link.py $$output))" >> $@ ;\
		done
	echo -e "\n# $* (Cover)\n" >> $@
	echo " * [$*-app-kapak.png]($$($(TOOLS)/bin/share_link.py $*-app-kapak.png))" >> $@
	echo -e "\n# $* (Ebooks)\n" >> $@
	echo " * [$*-app-kapak.png]($$($(TOOLS)/bin/share_link.py $*-app-kapak.png))" >> $@

%-kapak-kare.png:
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	convert \
		-background lightgrey \
		-fill darkblue \
		-pointsize 256 \
		caption:"$$caption" \
		-resize 480x \
		-gravity Center \
		-extent 480x480 \
		-bordercolor black \
		-border 10x10 \
		+repage \
		$@

%-app-kapak.png: %-kapak-kare.png
	cp $^ $@

%-app-kapak.pdf: %-app-kapak.png $(MAKEFILE_LIST)
	convert $< \
		-resize x1280 \
		-gravity Center \
		-crop 800x1280+0+0! \
		-gravity SouthWest \
		-extent 800x1280 \
		-page 226.64x362.624 \
		-compress jpeg \
		-quality 80 \
		+repage \
		$@

%.epub %.odt %.docx: %.md $$(wildcard $$*.yml) $(MAKEFILE_LIST)
	pandoc \
		--smart \
		$(TOOLS)/viachristus.yml \
		$(shell test -f "$(PROJECT).yml" && echo "$(PROJECT).yml") \
		$(shell test -f "$(basename $1).yml" && echo "$(basename $1).yml") \
		$*.yml \
		<($(call preprocess_markdown,$<)) -o $@

%.mobi: %.epub $(MAKEFILE_LIST)
	-kindlegen $<

%.json: $(TOOLS)/viachristus.yml $(wildcard $(PROJECT).yml $**.yml)
	jq -s 'reduce .[] as $$item({}; . + $$item)' $(foreach YAML,$^,<(yaml2json $(YAML))) > $@

%-barkod.svg: %.yml $(MAKEFILE_LIST)
	zint --directsvg --scale=5 --barcode=69 --height=30 \
		--data=$(shell $(TOOLS)/bin/isbn_format.py $< print) |\
		convert - \
			-bordercolor White -border 10x10 \
			-font Hack-Regular -pointsize 36 \
			label:"ISBN $(shell $(TOOLS)/bin/isbn_format.py $< print mask)" +swap -gravity Center -append \
			-bordercolor White -border 0x10 \
			$@

%-url.png: %-url.svg $(MAKEFILE_LIST)
	convert $< $@

%-url.svg: $(MAKEFILE_LIST)
	zint --directsvg --scale=10 --barcode=58 \
		--data=$(shell $(call urlinfo,$*)) |\
		convert - \
			-bordercolor White -border 10x10 \
			-bordercolor Black -border 4x4 \
			$@

%-barkod.png: %-barkod.svg %.yml $(MAKEFILE_LIST)
	convert $< $@

stats: $(foreach SOURCE,$(SOURCES),$(SOURCE)-stats)

%-stats: $(MAKEFILE_LIST)
	@$(TOOLS)/stats.zsh $(@:-stats=) $(STATS_MONTHS)

watch:
	( git ls-files ; cd $(TOOLS) ; git ls-files | xargs -iX echo $(TOOLS)/X ) | \
		entr -c -p make -B DRAFT=true
