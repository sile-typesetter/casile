BASE := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/../" && pwd)
TOOLS := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT != basename $(BASE)
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)
INPUT  = ${HOME}/ownCloud/viachristus/$(PROJECT)
SHELL = bash
OWNCLOUD = https://owncloud.alerque.com/remote.php/webdav/viachristus/$(PROJECT)
SOURCES := $(wildcard *.md)
TARGETS := ${SOURCES:.md=}
FORMATS ?= pdf epub mobi
LAYOUTS ?= a4 a5trim octavo halfletter cep app
PRINTS ?=
#PRINTS ?= kesme kesme-ciftyonlu
DRAFT ?= false
DIFF ?= true
CROP ?= false
STATS_MONTHS ?= 2
PRE_SYNC ?= true

# Local and CI builds calculate the branach differently
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(BRANCH),HEAD)
BRANCH = $(CI_BUILD_REF_NAME)
endif
_BRANCH = PARENT_$(subst +,_,$(subst -,_,$(BRANCH)))
ifneq ($($(_BRANCH)),)
PARENT = $($(_BRANCH))
endif
ifneq ($(BRANCH),master)
PARENT ?= $(shell $(TOOLS)/bin/findfirstnonunique.zsh)
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)/$(BRANCH)
PRE_SYNC = false
endif

# If we are directly on a tagged commit, build it to a special directory
TAG = $(shell git describe --tags)
ifeq ($(shell git describe --long --tags | rev | cut -d- -f2),0)
BRANCH = master
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)/$(TAG)
PRE_SYNC = false
DIFF = false
endif

# If our tag or branch has a slash in it, treat the first bit as a target
# and only build that item not the whole project.
TAG_TARGET = $(shell git describe --tags | cut -d/ -f1)
ifneq ($(TAG),$(TAG_TARGET))
TAG = $(shell git describe --tags | cut -d/ -f2)
TARGETS = $(TAG_TARGET)
endif

# If there is a layout associated with at tag, only build that layout
ifneq (LAYOUT_$(TAG),0)
LAYOUTS = $(LAYOUT_$(TAG))
FORMATS = pdf
endif

export TEXMFHOME := $(TOOLS)/texmf
export PATH := $(TOOLS)/bin:$(PATH)
export HOSTNAME := $(shell hostname)
export SILE_PATH := $(TOOLS)/

.ONESHELL:
.SECONDEXPANSION:
.PHONY: all ci clean init sync_pre sync_post $(TARGETS)
.SECONDARY:
.PRECIOUS: %.pdf %.sil

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
		$(foreach FORMAT,$(FORMATS),$(OUTPUT)/*.$(FORMAT)) $(BASE)/

sync_post:
	-rsync -ctv \
		$(foreach FORMAT,$(FORMATS),*.$(FORMAT)) $(OUTPUT)/
	$(call sync_owncloud)

%.pdf: $(foreach LAYOUT,$(LAYOUTS),$$*-$(LAYOUT).pdf) $(foreach LAYOUT,$(LAYOUTS),$(foreach PRINT,$(PRINTS),$$*-$(LAYOUT)-$(PRINT).pdf)) ;

%.pdf: %.sil $(TOOLS)/viachristus.lua
	@$(shell test -f "$<" || echo exit 0)
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	# Once for TOC, again for real page numbers, again again for final
	if $(DRAFT); then \
		sile -d viachristus $< -o $@ ;\
	else \
		sile $< -o $@ && sile $< -o $@ && sile $< -o $@ ;\
	fi

%-kesme.pdf: %.pdf
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

%-ciftyonlu.pdf: %.pdf
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
			smart_quotes.pl |
			sed -e 's#{==##g;s#==}##g' |
			sed -e 's#{>>##g;s#<<}##g'
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

%-a4.sil: %.md %.yml %-url.png $(TOOLS)/template.sil $$(wildcard $$*.lua) $(TOOLS)/layout-a4.lua
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),a4,false)

%-a5trim.sil: %.md %.yml %-url.png $(TOOLS)/template.sil $$(wildcard $$*.lua) $(TOOLS)/layout-a5trim.lua
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),133mm x 195mm,true)

%-octavo.sil: %.md %.yml %-url.png $(TOOLS)/template.sil $$(wildcard $$*.lua) $(TOOLS)/layout-octavo.lua
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),432pt x 648pt,true)

%-halfletter.sil: %.md %.yml %-url.png $(TOOLS)/template.sil $$(wildcard $$*.lua) $(TOOLS)/layout-halfletter.lua
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),halfletter,true)

%-cep.sil: %.md %.yml %-url.png $(TOOLS)/template.sil $$(wildcard $$*.lua) $(TOOLS)/layout-cep.lua
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),110mm x 170mm,true)

%-app.sil: %.md %.yml %-url.png $(TOOLS)/template.sil $$(wildcard $$*.lua) $(TOOLS)/layout-app.lua
	$(call build_sile,$<,$*,$(patsubst $*-%.sil,%,$@),82mm x 146mm,false)

%.epub %.odt %.docx: %.md %.yml
	pandoc \
		--smart \
		$(TOOLS)/viachristus.yml \
		$(shell test -f "$(PROJECT).yml" && echo "$(PROJECT).yml") \
		$(shell test -f "$(basename $1).yml" && echo "$(basename $1).yml") \
		$*.yml \
		<($(call preprocess_markdown,$<)) -o $@

%.mobi: %.epub
	-kindlegen $<

%-barkod.svg: %.yml
	zint --directsvg --scale=5 --barcode=69 --height=30 \
		--data=$(shell $(TOOLS)/bin/isbn_format.py $< print) |\
		convert - \
			-bordercolor White -border 10x10 \
			-font Hack-Regular -pointsize 36 \
			label:"ISBN $(shell $(TOOLS)/bin/isbn_format.py $< print mask)" +swap -gravity Center -append \
			-bordercolor White -border 0x10 \
			$@

%-url.png: %-url.svg %.yml
	convert $< $@

%-url.svg: %.yml
	zint --directsvg --scale=10 --barcode=58 \
		--data=$(shell $(call urlinfo,$*)) |\
		convert - \
			-bordercolor White -border 10x10 \
			-bordercolor Black -border 4x4 \
			$@

%-barkod.png: %-barkod.svg %.yml
	convert $< $@

stats: $(foreach SOURCE,$(SOURCES),$(SOURCE)-stats)

%-stats:
	@$(TOOLS)/stats.zsh $(@:-stats=) $(STATS_MONTHS)
