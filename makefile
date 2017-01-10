# Initial setup, environment dependent
BASE := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/../" && pwd)
TOOLS := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT != basename $(BASE)
SHELL = bash

# Input/Output locations (for CI server)
OUTPUT = ${HOME}/ownCloud/viachristus/$(PROJECT)
INPUT  = ${HOME}/ownCloud/viachristus/$(PROJECT)
OWNCLOUD = https://owncloud.alerque.com/remote.php/webdav/viachristus/$(PROJECT)

# Find stuff to build that has both a YML and a MD component
TARGETS := $(filter $(basename $(wildcard *.md)),$(basename $(wildcard *.yml)))

# Default output formats and layouts (often overridden)
FORMATS ?= pdf epub mobi app
LAYOUTS ?= a4 a4ciltli octavo halfletter a5 a5trim cep app
RESOURCES ?= cilt 3b-on 3b-arka
#PRINTS ?= kesme kesme-ciftyonlu
BLEED = 3
TRIM= 10
PAPERWEIGHT = 60
COVER_GRAVITY ?= Center
LAYOUT_app = app

# Build mode flags
DRAFT ?= false # Take shortcuts, scale things down, be quick about it
DIFF ?= false # Show differences to parent brancd in build
STATS_MONTHS ?= 1 # How far back to look for commits when building stats
PRE_SYNC ?= true # Start CI builds with a sync _from_ the output folder
SYNCONLY ?= false # Skip builds and just sync what would have been built
DEBUG ?= false # Use SILE debug flags, set -x, and the like
SILE_DEBUG ?= viachristus # Specific debug flags to set
COVERS ?= true # Build covers?
HEAD ?= 0 # Number of lines of MD input to build from
SCALE = 10 # Reduction factor for draft builds
DPI = $(call scale,1200) # Default DPI for generated press resources

# Allow overriding executables used
SILE ?= sile
PANDOC ?= pandoc
CONVERT ?= convert
MAGICK ?= magick
INKSCAPE ?= inkscape

# List of supported outputs
PAPERSIZES = a4 a4ciltli octovo halfletter a5 a5trim cep app
RENDERINGS = 3b-on 3b-arka 3b-istif

# Default to running multiple jobs
JOBS := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)
MAKEFLAGS = "-j $(JOBS)"

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

# If this commit is tagged, run special rules for it
ALL_TAGS := $(shell git tag --points-at HEAD | xargs echo)
LAST_TAG := $(shell git describe --tags 2>/dev/null)
ifneq ($(ALL_TAGS),)

BRANCH = master
DIFF = false

# Use first segment of tags as target names
TARGETS = $(subst /,,$(dir $(ALL_TAGS)))

# Use last segment of tag names as formats
FORMATS = $(sort $(notdir $(ALL_TAGS)))
TAG_NAME = $(firstword $(sort $(notdir $(ALL_TAGS))))

# Else not directly on any tags
else

# If we are not on the master branch, guess the parent and output to a directory
ifneq ($(BRANCH),master)
PARENT ?= $(shell git merge-base master $(BRANCH))
OUTPUT := $(OUTPUT)/$(BRANCH)
PRE_SYNC = false
endif

# If the environment has information about a parent, override the calculated one
_BRANCH = PARENT_$(subst +,_,$(subst -,_,$(BRANCH)))
ifneq ($($(_BRANCH)),)
PARENT = $($(_BRANCH))
endif

# End non-tagged
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

export PATH := $(TOOLS)/bin:$(PATH)
export HOSTNAME := $(shell hostname)
export SILE_PATH := $(TOOLS)
export PROJECT := $(PROJECT)

ifeq ($(DEBUG),true)
SILE = /home/caleb/projects/sile/sile
export SILE_PATH = /home/caleb/projects/sile/;$(TOOLS)
endif

VIRTUALPDFS = $(foreach TARGET,$(TARGETS),$(TARGET).pdf)

.ONESHELL:
.SECONDEXPANSION:
.PHONY: all ci clean debug list force init dependencies sync_pre sync_post $(TARGETS) $(VIRTUALPDFS) %.app md_cleanup stats %-stats
.SECONDARY:
.PRECIOUS: %.pdf %.sil %.toc %.dat %.inc

all: $(TARGETS)

ci: | init clean debug sync_pre all sync_post stats

render: $(foreach TARGET,$(TARGETS),$(foreach LAYOUT,$(LAYOUTS),$(foreach RENDERING,$(RENDERINGS),$(TARGET)-$(LAYOUT)-$(RENDERING).png)))

clean:
	git clean -xf

debug:
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
	@echo PRE_SYNC: $(PRE_SYNC)
	@echo SYNCONLY: $(SYNCONLY)
	@echo versioninfo: $(call versioninfo,$(PROJECT))

force: ;

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

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
	hash $(CONVERT)
	hash $(MAGICK)
	hash povray
	hash yaml2json
	hash jq
	hash zint
	hash pdfinfo
	hash pdftk
	hash $(INKSCAPE)
	hash podofobox
	lua -v -l yaml
	perl -e ';' -MYAML
	perl -e ';' -MYAML::Merge::Simple
	python -c "import yaml"
	python -c "import isbnlib"

update_app_tags:
	git tag |
		grep '/app$$' |
		while read tag; do
			git tag -d $$tag
			git tag $$tag
		done

define addtosync
	echo $@ >> sync_files.dat
	-$(SYNCONLY) && exit 0
endef

define sync_owncloud
	-pgrep -u $(USER) -x owncloud || \
		owncloudcmd -n -s $(INPUT) $(OWNCLOUD) 2>/dev/null
endef

# If building in draft mode, scale resolutions down for quick builds
define scale
$(strip $(shell $(DRAFT) && echo $(if $2,$2,"($1 + $(SCALE) - 1) / $(SCALE)" | bc) || echo $1))
endef

sync_pre:
	$(call sync_owncloud)
	-$(PRE_SYNC) && rsync -ctv \
		$(OUTPUT)/* $(BASE)/

sync_post: sync_files.dat
	sort -u $< | sponge $<
	for target in $(TARGETS); do
ifeq ($(ALL_TAGS),)
		tagpath=
else
		tagpath=$$target/$(TAG_NAME)/
endif
		mkdir -p $(OUTPUT)/$$tagpath
		while read file; do
			test -f $$file && rsync -ct $$file $(OUTPUT)/$$tagpath
		done < $<
	done
	$(call sync_owncloud)

$(VIRTUALPDFS): %.pdf: $(foreach LAYOUT,$(LAYOUTS),$$*-$(LAYOUT).pdf) $(foreach LAYOUT,$(LAYOUTS),$(foreach RESOURCE,$(RESOURCES),$$*-$(LAYOUT)-$(RESOURCE).pdf)) ;

ONPAPERPDFS = $(foreach TARGET,$(TARGETS),$(foreach PAPERSIZE,$(PAPERSIZES),$(TARGET)-$(PAPERSIZE).pdf))
$(ONPAPERPDFS): %.pdf: %.sil
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	$(addtosync)
	# If in draft mode don't rebuild for TOC and do output debug info, otherwise
	# account for TOC issue: https://github.com/simoncozens/sile/issues/230
	if $(DRAFT); then
		$(SILE) -d $(SILE_DEBUG) $< -o $@
	else
		export pg0=$(call pagecount,$@)
		$(SILE) $< -o $@
		export pg1=$(call pagecount,$@)
		[[ $${pg0} -ne $${pg1} ]] && $(SILE) $< -o $@ ||:
		export pg2=$(call pagecount,$@)
		[[ $${pg1} -ne $${pg2} ]] && $(SILE) $< -o $@ ||:
	fi
	# If we have a special cover page for this format, swap it out for the half title page
	if $(COVERS) && [[ -f $*-kapak.pdf ]]; then
		pdftk $@ dump_data_utf8 output $*.dat
		pdftk C=$*-kapak.pdf B=$@ cat C1 B2-end output $*.tmp.pdf
		pdftk $*.tmp.pdf update_info_utf8 $*.dat output $@
		rm $*.tmp.pdf
	fi

ONPAPERSILS = $(foreach PAPERSIZE,$(PAPERSIZES),%-$(PAPERSIZE).sil)
$(ONPAPERSILS): %-processed.md %-merged.yml %-url.png $(TOOLS)/template.sil | $$(wildcard $$*.lua) $$(wildcard $(PROJECT).lua) $(TOOLS)/layout-$$(call parse_layout,$$@).lua $(TOOLS)/viachristus.lua
	$(PANDOC) --standalone \
			--wrap=preserve \
			-V documentclass="vc" \
			-V metadatafile="$(word 2,$^)" \
			-V versioninfo="$(call versioninfo,$*)" \
			-V urlinfo="$(call urlinfo,$*)" \
			-V qrimg="./$(word 3,$^)" \
			$(foreach LUA,$|, -V script=$(basename $(LUA))) \
			--template=$(word 4,$^) \
			--to=sile \
			$(word 2,$^) $< |
		$(call sile_hook) > $@

%-processed.md: $(TOOLS)/viachristus.m4 $(wildcard $(PROJECT).m4) $$(wildcard $$*.m4) %.md
	if [[ "$(BRANCH)" == master ]]; then
		m4 $^
	else
		$(DIFF) && branch2criticmark.bash $(PARENT) $(lastword $^) || m4 $^ |
			sed -e 's#{==#\\criticHighlight{#g' -e 's#==}#}#g' \
				-e 's#{>>#\\criticComment{#g'   -e 's#<<}#}#g' \
				-e 's#{++#\\criticAdd{#g'       -e 's#++}#}#g' \
				-e 's#{--#\\criticDel{#g'       -e 's#--}#}#g'
	fi |
		renumber_footnotes.pl |
		$(call md_cleanup) |
		$(call markdown_hook) > $@

%-ciftyonlu.pdf: %.pdf
	-pdfbook --short-edge --suffix ciftyonlu --noautoscale true -- $<

%-kirpilmis.pdf: %.pdf
	$(addtosync)
	b=$$(echo "$(TRIM) * 283.465" | bc)
	w=$$(echo "$(call pagew,$<) * 100 - $$b * 2" | bc)
	h=$$(echo "$(call pageh,$<) * 100 - $$b * 2" | bc)
	podofobox $< $@ media $$b $$b $$w $$h

define versioninfo
$(shell
	echo -en "$(basename $1)@"
	if [[ "$(BRANCH)" == master ]]; then
		git describe --tags >/dev/null 2>/dev/null || echo -en "$(BRANCH)-"
		git describe --long --tags --always --dirty=* | cut -d/ -f2 | xargs echo -en
	else
		$(DIFF) && echo -en "$$(git rev-parse --short $(PARENT))→"
		echo -en "$(BRANCH)-"
		git rev-list --boundary $(PARENT)..HEAD | grep -v - | wc -l | xargs -iX echo -en "X-"
		git describe --always | cut -d/ -f2 | xargs echo -en
	fi)
endef

urlinfo = "https://yayinlar.viachristus.com/$1"

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
	$(call find_and_munge,*.md,$(PANDOC) --atx-headers --wrap=preserve --to=markdown,Normalize and tidy Markdown syntax using Pandoc)
	# call find_and_munge,*.md,reorder_punctuation.pl,Cleanup punctuation mark order, footnote markers, etc.)
	# call find_and_munge,*.md,apostrophize_names.pl,Use apostrophes when adding suffixes to proper names)

define md_cleanup
	cat | ( [[ $(HEAD) -ge 1 ]] && head -n $(HEAD) || cat ) |
	( $(DIFF) && cat || (
		smart_quotes.pl |
		figure_dash.pl |
		reorder_punctuation.pl |
		link_verses.js |
		unicode_symbols.pl
	) )
endef

define markdown_hook
	cat -
endef

define sile_hook
	cat -
endef

%.sil.toc: %.pdf ;

%.app: %-app.info %-app-kapak-kare.png %-app-kapak-genis.png;

%-app.info: %-app.sil.toc %-merged.yml
	$(addtosync)
	$(TOOLS)/bin/toc2breaks.lua $* $^ $@ |\
		while read range out; do \
			pdftk $*-app.pdf cat $$range output $$out ;\
		done

issue.info:
	$(addtosync)
	@for source in $(TARGETS); do
		echo -e "# $$source\n"
		sed -ne "/^# /{s/^# *\(.*\)/ - [ ] [\1]($${source}.md)/g;p}" $$source.md
		find $${source}-bolumler -name '*.md' -print |
			sort -n |
			while read chapter; do
				number=$${chapter%-*}; number=$${number#*/}
				sed -ne "/^# /{s/ {.*}$$//;s!^# *\(.*\)! - [ ] $$number — [\1]($$chapter)!g;p}" $$chapter
			done
		echo
	done > $@

define skip_if_tracked
	$(COVERS) || exit 0
	git ls-files --error-unmatch -- $1 2>/dev/null && exit 0 ||:
endef

pagecount = $(shell pdfinfo $1 | awk '$$1 == "Pages:" {print $$2}' || echo 0)
pagew = $(shell pdfinfo $1 | awk '$$1$$2 == "Pagesize:" {print $$3}' || echo 0)
pageh = $(shell pdfinfo $1 | awk '$$1$$2 == "Pagesize:" {print $$5}' || echo 0)
spinemm = $(shell echo "$(call pagecount,$1) * $(PAPERWEIGHT) / 1000 + 1 " | bc)
mmtopx = $(shell echo "$1 * $(DPI) * 0.0393701 / 1" | bc)
mmtopm = $(shell echo "$1 * 90 * .0393701 / 1" | bc)
width = $(shell identify -density $(DPI) -format %[fx:w] $1)
height = $(shell identify -density $(DPI) -format %[fx:h] $1)
parse_layout = $(filter $(PAPERSIZES),$(subst -, ,$(basename $1)))
strip_layout = $(filter-out $1,$(foreach PAPERSIZE,$(PAPERSIZES),$(subst -$(PAPERSIZE)-,-,$1)))

%-kapak-zemin.png: %.pdf
	$(COVERS) || exit 0
	$(call skip_if_tracked,$@)
	$(MAGICK) -size $(call width,$<)x$(call height,$<) $(call zemin) $@

define draw_title
	$(CONVERT)  \
		-size 2500x2000 xc:none -background none \
		-gravity Center \
		-pointsize 128 -kerning -5 \
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
		-gravity $(COVER_GRAVITY) \
		-resize $2^ -extent $2 \
		-shave 10x10 \
		-bordercolor black -border 10x10 \
		-composite \
		$4
endef

%-kapak-kare.png: %-kapak-zemin.png
	$(addtosync)
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,2048x2048,$<,$@)

%-kapak-genis.png: %-kapak-zemin.png
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,3840x2160,$<,$@)

%-kapak.png: %-kapak-zemin.png
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,2000x3200,$<,$@)

%-app-kapak-kare.png: %-kapak-kare.png
	$(addtosync)
	$(COVERS) || exit 0
	$(CONVERT) $< -resize 1024x1024 $@

%-app-kapak-genis.png: %-kapak-genis.png
	$(addtosync)
	$(COVERS) || exit 0
	$(CONVERT) $< -resize 1920x1080 $@

%-kapak-isoa.png: %-kapak-zemin.png
	$(call skip_if_tracked,$@)
	export caption=$$($(TOOLS)/bin/cover_title.py $@)
	$(call draw_title,$$caption,4000x5657,$<,$@)

%-a4-kapak.pdf: %-kapak-isoa.png
	$(COVERS) || exit 0
	$(CONVERT)  $< \
		-bordercolor none -border 300x424 \
		-resize 2000x2828 \
		-page A4  \
		-compress jpeg \
		-quality 80 \
		+repage \
		$@

%-app-kapak.pdf: %-kapak.png
	$(COVERS) || exit 0
	$(CONVERT) $< \
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

FRAGMANLAR = $(foreach PAPERSIZE,$(PAPERSIZES),%-$(PAPERSIZE)-fragmanlar.pdf)
$(FRAGMANLAR): $(TOOLS)/fragmanlar.xml %-merged.yml $$(wildcard $$*.lua) $(TOOLS)/viachristus.lua $$(subst -fragmanlar,,$$@)
	cat <<- EOF > $*-fragmanlar.lua
		versioninfo = "$(call versioninfo,$*)"
		layout = "$(call parse_layout,$@)"
		metadatafile = "$(word 2,$^)"
		spine = "$(call spinemm,$(lastword $^))mm"
		basename = "$*"
	EOF
	$(SILE) $< -e 'infofile = "$*-fragmanlar"' -o $@

%-fragman-on.png: %-fragmanlar.pdf
	$(MAGICK) -density $(DPI) $<[0] \
		-channel RGB -negate \
		\( +clone -channel A -morphology Dilate:$(call scale,16) Octagon -blur $(call scale,40)x$(call scale,10) \) \
		-composite $@

%-fragman-arka.png: %-fragmanlar.pdf
	$(MAGICK) -density $(DPI) $<[1] \
		-channel RGB -negate \
		\( +clone -channel A -morphology Dilate:$(call scale,8) Octagon -blur $(call scale,20)x$(call scale,5) \) \
		-composite $@

%-fragman-sirt.png: %-fragmanlar.pdf | %.pdf
	$(MAGICK) -density $(DPI) $<[2] \
		-crop $(call mmtopx,$(call spinemm,$(word 1,$|)))x+0+0 \
		-channel RGB -negate \
		\( +clone -channel A -morphology Dilate:$(call scale,12) Octagon -blur $(call scale,20)x$(call scale,5) \) \
		-composite $@

%-epub-kapak.png: %-kapak.png
	$(call skip_if_tracked,$@)
	$(CONVERT) $< -resize $(call scale,1000)x$(call scale,1600) $@

%-cilt.png: %-fragman-on.png %-fragman-arka.png %-fragman-sirt.png $$(call strip_layout,$$*-barkod.png) $(TOOLS)/vc_sembol_renkli.svg $(TOOLS)/vc_logo_renkli.svg %-geometry.sh
	source $(lastword $^)
	texturew="$$(bc <<< "$$imgwpx / $(call scale,4,4)")"
	textureh="$$(bc <<< "$$imghpx / $(call scale,4,4)")"
	set -x
	@$(MAGICK) -size $${imgwpx}x$${imghpx} -density $(DPI) \
		$(call magick_zemin) \
		$(call magick_kenar) \
		\( -gravity east -size $${coverwpx}x$${coverhpx} -background none xc: $(call magick_on) -splice $${bleedpx}x \) -composite \
		\( -gravity west -size $${coverwpx}x$${coverhpx} -background none xc: $(call magick_arka) -splice $${bleedpx}x \) -composite \
		\( -gravity center -size $${spinepx}x$${coverhpx} -background none xc: $(call magick_sirt) \) -composite \
		\( -gravity east $(word 1,$^) -splice $${bleedpx}x \) -compose over -composite \
		\( -gravity west $(word 2,$^) -splice $${bleedpx}x \) -compose over -composite \
		\( -gravity center $(word 3,$^) \) -compose over -composite \
		$(call magick_sembol,$(word 5,$^))\
		$(call magick_barkod,$(word 4,$^)) \
		$(call magick_logo,$(word 6,$^)) \
		-composite +repage \
		$(call magick_cilt) \
		$@

%-cilt.svg: $(TOOLS)/cilt.svg %-cilt.png %-geometry.sh
	source $(word 3,$^)
	ver=$(subst @,\\@,$(call versioninfo,$@))
	perl -pne "
			s#IMG#$(word 2,$^)#g;
			s#VER#$${ver}#g;
			s#CANVASX#$${ciltwmm}mm#g;
			s#CANVASY#$${coverhmm}mm#g;
			s#IMW#$${imgwpm}#g;
			s#IMH#$${imghpm}#g;
			s#WWW#$${ciltwpm}#g;
			s#HHH#$${coverhpm}#g;
			s#BLEED#$${bleedpm}#g;
			s#TRIM#$${trimpm}#g;
			s#CW#$${coverwpm}#g;
			s#SW#$${spinepm}#g;
		" $< > $@

%-cilt.pdf:	%-cilt.svg %-cilt.png %-geometry.sh
	$(addtosync)
	source $(lastword $^)
	$(INKSCAPE) --without-gui \
		--export-dpi=$$dpi \
		--export-margin=$$trimmm \
		--file=$< \
		--export-pdf=$@

newgeometry = $(shell grep -qx dpi=$(DPI) $1 || echo force)

%-geometry.sh: $$(call newgeometry,$$@) | %.pdf %-fragmanlar.pdf
	set -x ; exec 2> >(cut -c3- > $@) # black magic to output the finished math
	dpi=$(DPI)
	bleedmm=$(BLEED)
	bleedpx=$(call mmtopx,$(BLEED))
	bleedpm=$(call mmtopm,$(BLEED))
	trimmm=$(TRIM)
	trimpx=$(call mmtopx,$(TRIM))
	trimpm=$(call mmtopm,$(TRIM))
	$(shell identify -density $(DPI) -format '
			coverwmm=%[fx:round(w/$(DPI)*25.399986)]
			coverwpx=%[fx:w]
			coverwpm=%[fx:round(w/$(DPI)*90)]
			coverhmm=%[fx:round(h/$(DPI)*25.399986)]
			coverhpx=%[fx:h]
			coverhpm=%[fx:round(h/$(DPI)*90)]
		' $(word 2,$|)[0])
	spinemm=$(call spinemm,$(word 1,$|))
	spinepx=$(call mmtopx,$(call spinemm,$(word 1,$|)))
	spinepm=$(call mmtopm,$(call spinemm,$(word 1,$|)))
	ciltwmm=$$(($$coverwmm+$$spinemm+$$coverwmm))
	ciltwpx=$$(($$coverwpx+$$spinepx+$$coverwpx))
	ciltwpm=$$(($$coverwpm+$$spinepm+$$coverwpm))
	imgwmm=$$(($$ciltwmm+$$bleedmm*2))
	imgwpx=$$(($$ciltwpx+$$bleedpx*2))
	imgwpm=$$(($$ciltwpm+$$bleedpm*2))
	imghmm=$$(($$coverhmm+$$bleedmm*2))
	imghpx=$$(($$coverhpx+$$bleedpx*2))
	imghpm=$$(($$coverhpm+$$bleedpm*2))

define magick_zemin
	xc:darkgray
endef

define magick_kenar
	-fill none -strokewidth 1 \
	$(shell $(DRAFT) && echo -n '-stroke gray50' || echo -n '-stroke transparent') \
	-draw "rectangle $$bleedpx,$$bleedpx %[fx:w-$$bleedpx],%[fx:h-$$bleedpx]" \
	-draw "rectangle %[fx:$$bleedpx+$$coverwpx],$$bleedpx %[fx:w-$$bleedpx-$$coverwpx],%[fx:h-$$bleedpx]"
endef

define magick_sembol
	-gravity south \
	\( -background none $1 -resize "%[fx:min($$spinepx*0.9-$(call mmtopx,1),$(call mmtopx,12))]"x \
		-alpha on -channel RGB +level-colors '#ff0000','#550000' \
		-splice x%[fx:$(call mmtopx,5)+$$bleedpx] \) \
	-compose over -composite
endef

define magick_logo
	-gravity southwest \
	\( \
	-background none $(TOOLS)/vc_logo_renksiz.svg \
	-channel RGB -negate \
	-level 20%,60%!  \
	-resize $(call mmtopx,30)x \
	-splice %[fx:$$bleedpx+$$coverwpx*15/100]x%[fx:$$bleedpx+$(call mmtopx,10)] \
	\) -compose screen -composite
endef

define magick_barkod
	-gravity southeast \
	\( -background white $1 -resize $(call mmtopx,30)x -bordercolor white -border $(call mmtopx,2) -background none -splice %[fx:$$bleedpx+$$coverwpx+$$spinepx+$$coverwpx*15/100]x%[fx:$$bleedpx+$(call mmtopx,10)] \) \
	-compose over -composite
endef

define magick_crease
	-stroke gray95 -strokewidth $(call mmtopx,0.5) \
	\( -size $${coverwpx}x$${coverhpx} -background none xc: -draw "line %[fx:$1$(call mmtopx,8)],0 %[fx:$1$(call mmtopx,8)],$${coverhpx}" -blur 0x$(call scale,$(call mmtopx,0.2)) -level 0x40%! \) \
	-compose modulusadd -composite
endef

define magick_fray
	\( +clone -alpha extract -virtual-pixel black -spread 2 -blur 0x4 -threshold 20% -spread 2 -blur 0x0.7 \) \
	-alpha off -compose copyopacity -composite
endef

%-cilt-on.png: %-cilt.png %-geometry.sh
	source $(word 2,$^)
	$(MAGICK) $< -gravity east -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! $@

%-cilt-arka.png: %-cilt.png %-geometry.sh
	source $(word 2,$^)
	$(MAGICK) $< -gravity west -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! $@

%-cilt-sirt.png: %-cilt.png %-geometry.sh
	source $(word 2,$^)
	$(MAGICK) $< -gravity center -crop $${spinepx}x$${coverhpx}+0+0! $@

%-pov-on.png: %-cilt-on.png %-geometry.sh
	source $(lastword $^)
	$(MAGICK) $< \
		$(call magick_crease,0+) \
		$(call magick_fray) \
		$@

%-pov-arka.png: %-cilt-arka.png %-geometry.sh
	source $(lastword $^)
	$(MAGICK) $< \
		$(call magick_crease,w-) \
		$(call magick_fray) \
		$@

%-pov-sirt.png: %-cilt-sirt.png
	$(MAGICK) $< -gravity center -extent 200%x100% $@

povtextures = %-pov-on.png %-pov-arka.png %-pov-sirt.png

%-3b.pov: %-geometry.sh | $(povtextures)
	source $<
	cat <<- EOF > $@
		#declare coverwmm = $$coverwmm;
		#declare coverhmm = $$coverhmm;
		#declare spinemm = $$spinemm;
		#declare coverhwx = $$coverwmm;
		#declare coverhpx = $$coverhmm;
		#declare frontimg = "$(word 1,$|)";
		#declare backimg = "$(word 2,$|)";
		#declare spineimg = "$(word 3,$|)";
		#declare lights = $(call scale,8,2);
	EOF

define povray
	headers=$$(mktemp povXXXXXX.inc)
	cat $2 $3 > $$headers
	povray -I$1 -HI$$headers -W$(call scale,$5) -H$(call scale,$6) -Q$(call scale,11,4) -O$4
	rm $$headers
endef

define povcrop
	$(MAGICK) $1 \( +clone \
		-virtual-pixel edge \
		-blur 0x%[fx:w/50] \
		-fuzz 15% \
		-trim -trim \
		-set option:fuzzy_trim "%[fx:w*1.2]x%[fx:h*1.2]+%[fx:page.x-w*0.1]+%[fx:page.y-h*0.1]" \
		+delete \) \
		-crop %[fuzzy_trim] \
		-resize $(call scale,4000)x $1
endef

%-3b-on.png: $(TOOLS)/kapak.pov %-3b.pov $(TOOLS)/on.pov | $(povtextures)
	$(addtosync)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,6000,8000)
	$(call povcrop,$@)

%-3b-arka.png: $(TOOLS)/kapak.pov %-3b.pov $(TOOLS)/arka.pov | $(povtextures)
	$(addtosync)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,6000,8000)
	$(call povcrop,$@)

%-3b-istif.png: $(TOOLS)/kapak.pov %-3b.pov $(TOOLS)/istif.pov | $(povtextures)
	$(addtosync)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,8000,6000)
	$(call povcrop,$@)

%.epub %.odt %.docx: %-processed.md %-merged.yml %-epub-kapak.png
	$(addtosync)
	$(PANDOC) \
		--smart \
		$(word 2,$^) \
		$< -o $@

%.mobi: %.epub
	$(call addtosync,$@)
	-kindlegen $<

%.json: $(TOOLS)/viachristus.yml $$(wildcard $(PROJECT).yml $$*.yml)
	jq -s 'reduce .[] as $$item({}; . + $$item)' $(foreach YAML,$^,<(yaml2json $(YAML))) > $@

%-merged.yml: $(TOOLS)/viachristus.yml $$(wildcard $(PROJECT).yml $$*.yml)
	perl -MYAML::Merge::Simple=merge_files -MYAML -E 'say Dump merge_files(@ARGV)' $^ |\
		sed -e '/^--- |/d;$$a...' > $@

%-barkod.svg: %-merged.yml
	zint --directsvg --scale=5 --barcode=69 --height=30 \
		--data=$(shell $(TOOLS)/bin/isbn_format.py $< print) |\
		$(CONVERT) - \
			-bordercolor white -border 10 \
			-font Hack-Regular -pointsize 36 \
			label:"ISBN $(shell $(TOOLS)/bin/isbn_format.py $< print mask)" +swap -gravity center -append \
			-bordercolor white -border 0x10 \
			$@

%-url.png: %-url.svg
	$(CONVERT) $< $@

%-url.svg:
	zint --directsvg --scale=10 --barcode=58 \
		--data=$(call urlinfo,$*) |\
		$(CONVERT) - \
			-bordercolor White -border 10x10 \
			-bordercolor Black -border 4x4 \
			$@

%-barkod.png: %-barkod.svg
	$(CONVERT) $< -background white -resize $(call scale,1200)x $@

stats: $(foreach TARGET,$(TARGETS),$(TARGET)-stats)

%-stats:
	@$(TOOLS)/stats.zsh $* $(STATS_MONTHS)

NAMELANGS = en tr und part xx
NAMESFILES = $(foreach LANG,$(NAMELANGS),$(TOOLS)/names.$(LANG).txt)

proper_names.txt: $(SOURCES) $(NAMESFILES) | $(TOOLS)/bin/extract_names.pl
	$(call skip_if_tracked,$@)
	find -maxdepth 2 -name '*.md' -execdir cat {} \; | $(TOOLS)/bin/extract_names.pl |\
		sort -u |\
		grep -vxf <(cat $(NAMESFILES)) > $@

sort_names: proper_names.txt | $(TOOLS)/bin/sort_names.zsh $(NAMESFILES)
	sort_names.zsh < $^

tag_names: $(SOURCES) | $(TOOLS)/bin/tag_names.zsh $(NAMESFILES)
	git diff-index --quiet --cached HEAD || exit 1 # die if anything already staged
	git diff-files --quiet -- $^ || exit 1 # die if input files have uncommitted changes
	tag_names.zsh la avadanlik/names.la.txt $^
	tag_names.zsh en avadanlik/names.en.txt $^

avadanlik/names.%.txt:
	test -f $@ || touch $@
	sort -u $@ | sponge $@

%-ayetler.json: %.md
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
	echo Obsolete, need to find new way to calculate unsplit sources
	# $(foreach SOURCE,$(SOURCES),$(call split_chapters,$(SOURCE)))

watch:
	git ls-files --recurse-submodules |
		entr -c -p make DRAFT=true $(WATCH_ARGS)

watchdiff:
	git ls-files | entr -c -p git diff --color=always
