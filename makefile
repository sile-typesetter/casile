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
LAYOUTS ?= a4 a4ciltli a5trim octavo halfletter cep app
PRINTS ?=
#PRINTS ?= kesme kesme-ciftyonlu
DRAFT ?= false
DIFF ?= false
CROP ?= false
STATS_MONTHS ?= 1
PRE_SYNC ?= true
DEBUG ?= false
COVERS ?= true
HEAD ?= 0

SILE ?= sile
PANDOC ?= pandoc
SILE_DEBUG ?= viachristus

# For watch targets, treat exta parameters as things to pass to the next make
ifeq (watch,$(firstword $(MAKECMDGOALS)))
  WATCH_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(WATCH_ARGS):;@:)
endif

# CI runners need help getting the branch name because of funky checkouts
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(BRANCH),HEAD)
ifeq ($(shell git rev-parse master),$(shell git rev-parse HEAD))
BRANCH = master
else
BRANCH = $(CI_BUILD_REF_NAME)
endif
endif

# If we are directly on a tagged commit, build it to a special directory
TAG := $(shell git describe --tags)
TAG_SEQ := $(shell git describe --long --tags | rev | cut -d- -f2)
ifeq ($(TAG_SEQ),0)

BRANCH = master
OUTPUT := $(OUTPUT)/$(TAG)
PRE_SYNC = false
DIFF = false

# If our tag or branch has a slash in it, treat the first bit as a target
# and only build that item not the whole project.
TAG_BASE = $(shell echo $(TAG) | cut -d/ -f1)
TAG_NAME = $(TAG)
ifneq ($(TAG),$(TAG_BASE))
TAG_NAME = $(shell echo $(TAG) | cut -d/ -f2)
TARGETS = $(TAG_BASE)
endif

# Not directly on a tag
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
export SILE_PATH := $(TOOLS)
export PROJECT := $(PROJECT)

ifeq ($(DEBUG),true)
SILE = /home/caleb/projects/sile/sile
export SILE_PATH = /home/caleb/projects/sile/;$(TOOLS)
endif

.ONESHELL:
.SECONDEXPANSION:
.PHONY: all ci clean init dependencies sync_pre sync_post $(TARGETS) %.app md_cleanup
.SECONDARY:
.PRECIOUS: %.pdf %.sil %.toc

all: $(TARGETS)

ci: init clean debug sync_pre all sync_post stats

clean:
	git clean -xf

debug:
	@echo ================================================================================
	@echo SOURCES: $(SOURCES)
	@echo TARGETS: $(TARGETS)
	@echo FORMATS: $(FORMATS)
	@echo LAYOUTS: $(LAYOUTS)
	@echo TAG: $(TAG)
	@echo TAG_SEQ: $(TAG_SEQ)
	@echo TAG_BASE: $(TAG_BASE)
	@echo TAG_NAME: $(TAG_NAME)
	@echo BRANCH: $(BRANCH)
	@echo PARENT: $(PARENT)
	@echo DIFF: $(DIFF)
	@echo DEBUG: $(DEBUG)
	@echo OUTPUT: $(OUTPUT)
	@echo TOOLS: $(TOOLS)
	@echo SILE: $(SILE)
	@echo SILE_PATH: $(SILE_PATH)
	@echo ================================================================================

$(TARGETS): $(foreach FORMAT,$(FORMATS),$$@.$(FORMAT))

init: dependencies
	mkdir -p $(OUTPUT)
	git submodule update --init --remote
	cd $(TOOLS) && yarn install

dependencies:
	hash yarn
	hash $(SILE)
	hash $(PANDOC)
	$(PANDOC) --list-output-formats | grep -q sile

define sync_owncloud
	-pgrep -u $(USER) -x owncloud || \
		owncloudcmd -n -s $(INPUT) $(OWNCLOUD) 2>/dev/null
endef

sync_pre:
	$(call sync_owncloud)
	-$(PRE_SYNC) && rsync -ctv \
		$(OUTPUT)/* $(BASE)/

sync_post:
	-rsync -ctv \
		$(foreach TARGET,$(TARGETS),$(foreach FORMAT,$(FORMATS),$(TARGET)*-$(FORMAT)*.{pdf,info,png} $(TARGET)*.$(FORMAT))) $(OUTPUT)/
	$(call sync_owncloud)

%.pdf: $(foreach LAYOUT,$(LAYOUTS),$$*-$(LAYOUT).pdf) $(foreach LAYOUT,$(LAYOUTS),$(foreach PRINT,$(PRINTS),$$*-$(LAYOUT)-$(PRINT).pdf)) $(MAKEFILE_LIST) ;

%.pdf: %.sil $(TOOLS)/viachristus.lua $(MAKEFILE_LIST)
	@$(shell test -f "$<" || echo exit 0)
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	# If in draft mode don't rebuild for TOC and do output debug info, otherwise
	# account for TOC issue: https://github.com/simoncozens/sile/issues/230
	if $(DRAFT); then \
		$(SILE) -d $(SILE_DEBUG) $< -o $@ ;\
	else \
		export pg0="$$(test -f $<.toc && ( pdfinfo $@ | grep Pages: | awk '{print $$2}' ) || echo 0)" ;\
		$(SILE) $< -o $@ ;\
		export pg1="$$(pdfinfo $@ | grep Pages: | awk '{print $$2}')" ;\
		[[ $${pg0} -ne $${pg1} ]] && $(SILE) $< -o $@ ||: ;\
		export pg2="$$(pdfinfo $@ | grep Pages: | awk '{print $$2}')" ;\
		[[ $${pg1} -ne $${pg2} ]] && $(SILE) $< -o $@ ||: ;\
	fi
	# If we have a special cover page for this format, swap it out for the half title page
	if $(COVERS) && [[ -f $*-kapak.pdf ]]; then
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

define find_and_munge
	git diff-index --quiet --cached HEAD || exit 1 # die if anything already staged
	find $(BASE) -maxdepth 2 -name '$1' |
		while read f; do
			grep -q 'esyscmd.*cat' $$f && continue # skip compilations that are mostly M4
			git diff-files --quiet -- $$f || exit 1 # die if this file has uncommitted changes
			$2 < $$f | sponge $$f
			git add -- $$f
		done
	git diff-index --quiet --cached HEAD || git ci -m "[auto] $3"
endef

md_cleanup:
	$(call find_and_munge,*.md,msword_escapes.pl,Fixup bad MS word typing habits that Pandoc tries to preserve)
	$(call find_and_munge,*.md,lazy_quotes.pl,Replace lazy double single quotes with real doubles)
	$(call find_and_munge,*.md,smart_quotes.pl,Replace straight quotation marks with typographic variants)
	$(call find_and_munge,*.md,figure_dash.pl,Convert hyphens between numbers to figure dashes)
	$(call find_and_munge,*.md,unicode_symbols.pl,Replace lazy ASCI shortcuts with Unicode symbols)
	$(call find_and_munge,*.md,italic_reorder.pl,Fixup italics around names and parethesised translations)
	$(call find_and_munge,*.md,$(PANDOC) --atx-headers --wrap=none --to=markdown,Normalize and tidy Markdown syntax using Pandoc)
	# call find_and_munge,*.md,reorder_punctuation.pl,Cleanup punctuation mark order, footnote markers, etc.)
	# call find_and_munge,*.md,apostrophize_names.pl,Use apostrophes when adding suffixes to proper names)

define md_cleanup
	cat | ( [[ $(HEAD) -ge 1 ]] && head -n $(HEAD) || cat ) |
	smart_quotes.pl |
	figure_dash.pl |
	reorder_punctuation.pl |
	unicode_symbols.pl
endef

define preprocess_markdown
	if [[ "$(BRANCH)" == master ]]; then
		m4 $(TOOLS)/viachristus.m4 $(wildcard $(PROJECT).m4) $(wildcard $(basename $1).m4) $1
	else
		($(DIFF) && branch2criticmark.bash $(PARENT) $1 || m4 $(TOOLS)/viachristus.m4 $(wildcard $(PROJECT).m4) $(wildcard $(basename $1).m4) $1) |
			sed -e 's#{==#\\criticHighlight{#g' -e 's#==}#}#g' \
				-e 's#{>>#\\criticComment{#g'   -e 's#<<}#}#g' \
				-e 's#{++#\\criticAdd{#g'       -e 's#++}#}#g' \
				-e 's#{--#\\criticDel{#g'       -e 's#--}#}#g'
	fi | $(call md_cleanup)
endef

define build_sile
	$(PANDOC) --standalone \
		--wrap=preserve \
		-V documentclass="vc" \
		-V papersize="$4" \
		-V metadatafile="$(basename $1)-merged.yml" \
		-V versioninfo="$(shell $(call versioninfo,$1))" \
		-V urlinfo="$(shell $(call urlinfo,$1))" \
		-V qrimg="./$(basename $1)-url.png" \
		$(shell test -f "$(basename $1).lua" && echo "-V script=$(basename $1)") \
		$(shell test -f "$(PROJECT).lua" && echo "-V script=$(PROJECT)") \
		$(shell $5 || $(CROP) && echo "-V script=$(TOOLS)/crop") \
		-V script=$(TOOLS)/layout-$3 \
		-V script=$(TOOLS)/viachristus \
		--template=$(TOOLS)/template.sil \
		"$(basename $1)-merged.yml" \
		<($(call preprocess_markdown,$1)) -o $2-$3.sil
endef

%-a4.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png %-a4-kapak.pdf $(TOOLS)/template.sil $(TOOLS)/layout-a4.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),a4,false)

%-a4ciltli.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-a4ciltli.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),a4,false)

%-a5trim.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-a5trim.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),137.878787mm x 195mm,true)

%-octavo.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-octavo.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),432pt x 648pt,true)

%-halfletter.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-halfletter.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),halfletter,true)

%-cep.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png $(TOOLS)/template.sil $(TOOLS)/layout-cep.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),110mm x 170mm,true)

%-app.sil: %.md %-merged.yml $$(wildcard $$*.lua) %-url.png %-app-kapak.pdf $(TOOLS)/template.sil $(TOOLS)/layout-app.lua $(MAKEFILE_LIST)
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),80mm x 128mm,false)

%.sil.toc: %.pdf ;

%.app: %-app.info %-app-kapak-kare.png %-app-kapak-genis.png $(MAKEFILE_LIST);

%-app.info: %-app.sil.toc %-merged.yml
	$(TOOLS)/bin/toc2breaks.lua $* $^ $@ |\
		while read range out; do \
			pdftk $*-app.pdf cat $$range output $$out ;\
		done

define skip_if_tracked
	$(COVERS) || exit 0
	git ls-files --error-unmatch -- $1 2>/dev/null && exit 0 ||:
endef

%-kapak-zemin.png: $(MAKEFILE_LIST)
	$(COVERS) || exit 0
	$(call skip_if_tracked,$@)
	convert -size 64x64 xc:darkgray +repage $@

define draw_title
	convert  \
		-size 5000x4000 xc:none -background none \
		-gravity center \
		-pointsize 256 -kerning -10 \
		-font Libertinus-Sans-Bold \
		-fill black -stroke none \
		-annotate 0 "$1" \
		-blur 80x20 \
		-fill white -stroke black -strokewidth 10 \
		-annotate 0 "$1" \
		-stroke none \
		-annotate 0 "$1" \
		-trim \
		-resize $2 -resize 95% -extent $2 \
		$3 +swap \
		-resize $2^ -extent $2 \
		-shave 10x10 \
		-bordercolor black -border 10x10 \
		-composite \
		$4
endef

%-kapak-kare.png: %-kapak-zemin.png $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,2048x2048,$<,$@)

%-kapak-genis.png: %-kapak-zemin.png $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,3840x2160,$<,$@)

%-kapak.png: %-kapak-zemin.png $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,2000x3200,$<,$@)

%-app-kapak-kare.png: %-kapak-kare.png $(MAKEFILE_LIST)
	$(COVERS) || exit 0
	convert $< -resize 1024x1024 $@

%-app-kapak-genis.png: %-kapak-genis.png $(MAKEFILE_LIST)
	$(COVERS) || exit 0
	convert $< -resize 1920x1080 $@

%-kapak-isoa.png: %-kapak-zemin.png $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,4000x5657,$<,$@)

%-a4-kapak.pdf: %-kapak-isoa.png $(MAKEFILE_LIST)
	$(COVERS) || exit 0
	convert  $< \
		-bordercolor none -border 300x424 \
		-resize 2000x2828 \
		-page A4  \
		-compress jpeg \
		-quality 80 \
		+repage \
		$@

%-app-kapak.pdf: %-kapak.png $(MAKEFILE_LIST)
	$(COVERS) || exit 0
	convert $< \
		-resize x1280 \
		-gravity Center \
		-crop 800x1280+0+0! \
		-gravity SouthWest \
		-extent 800x1280 \
		-page 226.772x362.834 \
		-compress jpeg \
		-quality 80 \
		+repage \
		$@

%-epub-kapak.png: %-kapak.png $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	convert $< -resize 1000x1600 $@

%.epub %.odt %.docx: %.md %-merged.yml %-epub-kapak.png $(MAKEFILE_LIST)
	$(PANDOC) \
		--smart \
		"$(basename $1)-merged.yml" \
		<($(call preprocess_markdown,$<)) -o $@

%.mobi: %.epub $(MAKEFILE_LIST)
	-kindlegen $<

%.json: $(TOOLS)/viachristus.yml $$(wildcard $(PROJECT).yml $$*.yml)
	jq -s 'reduce .[] as $$item({}; . + $$item)' $(foreach YAML,$^,<(yaml2json $(YAML))) > $@

%-merged.yml: $(TOOLS)/viachristus.yml $$(wildcard $(PROJECT).yml $$*.yml) | $(MAKEFILE_LIST)
	perl -MYAML::Merge::Simple=merge_files -MYAML -E 'say Dump merge_files(@ARGV)' $^ |\
		sed -e '/^--- |/d;$$a...' > $@

%-barkod.svg: %-merged.yml $(MAKEFILE_LIST)
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

%-barkod.png: %-barkod.svg $(MAKEFILE_LIST)
	convert $< $@

stats: $(foreach SOURCE,$(SOURCES),$(SOURCE)-stats)

%-stats: $(MAKEFILE_LIST)
	@$(TOOLS)/stats.zsh $(@:-stats=) $(STATS_MONTHS)

NAMELANGS = en tr und part xx
NAMESFILES = $(foreach LANG,$(NAMELANGS),$(TOOLS)/names.$(LANG).txt)

proper_names.txt: $(SOURCES) $(NAMESFILES) | $(TOOLS)/bin/extract_names.pl $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	$(TOOLS)/bin/extract_names.pl < $(SOURCES) |\
		sort -u |\
		grep -vxf <(cat $(NAMESFILES)) > $@

sort_names: proper_names.txt | $(TOOLS)/bin/sort_names.zsh $(NAMESFILES)
	sort_names.zsh < $^

tag_names: $(SOURCES) | $(TOOLS)/bin/tag_names.zsh $(NAMESFILES) $(MAKEFILE_LIST)
	git diff-index --quiet --cached HEAD || exit 1 # die if anything already staged
	git diff-files --quiet -- $^ || exit 1 # die if input files have uncommitted changes
	tag_names.zsh la avadanlik/names.la.txt $^
	tag_names.zsh en avadanlik/names.en.txt $^

avadanlik/names.%.txt:
	test -f $@ || touch $@
	sort -u $@ | sponge $@

%-ayetler.json: %.md | $(MAKEFILE_LIST)
	# cd $(TOOLS)
	# yarn add bible-passage-reference-parser
	extract_references.js < $^ > $@
	cat $@

normalize_references: $(SOURCES)
	$(call find_and_munge,*.md,normalize_references.js,Normalize verse references using BCV parser)

define split_chapters
	git diff-index --quiet --cached HEAD || exit 1 # die if anything already staged
	git diff-files --quiet -- $1 || exit 1 # die if this file has uncommitted changes
	grep -q 'esyscmd.*cat' $1 && exit 1 # skip if the source is aready a compilation
	split_chapters.zsh $1
	git diff-index --quiet --cached HEAD || git ci -m "[auto] Split $1 into one file per chapter"
endef

split_chapters:
	$(foreach SOURCE,$(SOURCES),$(call split_chapters,$(SOURCE)))

watch:
	( git ls-files ; cd $(TOOLS) ; git ls-files | xargs -iX echo $(TOOLS)/X ) | \
		entr -c -p make -B DRAFT=true $(WATCH_ARGS)

watchdiff:
	git ls-files | entr -c -p git diff --color=always
