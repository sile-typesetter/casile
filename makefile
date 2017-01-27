SHELL := zsh
.SHELLFLAGS = +o nomatch -e -c

# Initial setup, environment dependent
PROJECTDIR := $(shell cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd)
CASILEDIR := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT := $(notdir $(PROJECTDIR))

# Set the language if not otherwise set
LANGUAGE ?= en
include $(CASILEDIR)/makefile-$(LANGUAGE)

# Find stuff to build that has both a YML and a MD component
TARGETS ?= $(filter $(basename $(wildcard *.md)),$(basename $(wildcard *.yml)))

# Default output formats and parameters (often overridden)
FORMATS ?= pdf epub
BLEED ?= 3
TRIM ?= 10
PAPERWEIGHT ?= 60
COVERGRAVITY ?= Center

# Build mode flags
DRAFT ?= false # Take shortcuts, scale things down, be quick about it
DIFF ?= false # Show differences to parent brancd in build
STATSMONTHS ?= 1 # How far back to look for commits when building stats
DEBUG ?= false # Use SILE debug flags, set -x, and the like
SILEDEBUG ?= casile # Specific debug flags to set
COVERS ?= true # Build covers?
SCALE = 17 # Reduction factor for draft builds
HIDPI = $(call scale,1200) # Default DPI for generated press resources
LODPI = $(call scale,300) # Default DPI for generated consumer resources

# Allow overriding executables used
SILE ?= sile
PANDOC ?= pandoc
CONVERT ?= convert
MAGICK ?= magick
INKSCAPE ?= inkscape

# List of supported outputs
CILTLI = a4ciltli octavo halfletter a5trim cep
KAPAKLI = a4 a5 app
PANKARTLI = kare genis bant epub
PAPERSIZES = $(CILTLI) $(KAPAKLI) $(PANKARTLI)

# Default to running multiple jobs
JOBS := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)
MAKEFLAGS = "-j $(JOBS)"

# List of extra m4 macro files to apply to every source
M4MACROS ?=
# List of exta YAML meta data files to splice into each book
METADATA ?=

# Extra lua files to include before processing documents
LUAINCLUDE +=

# Tell sile to look here for stuff before it’s internal stuff
SILEPATH += $(CASILEDIR)

# Set default document class
DOCUMENTCLASS ?= cabook

# Utility variables for later, http://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
, := ,
space :=
space +=
$(space) := 
$(space) +=

# For watch targets, treat exta parameters as things to pass to the next make
ifeq (watch,$(firstword $(MAKECMDGOALS)))
  WATCH_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(WATCH_ARGS):;@:)
endif

export PATH := $(CASILEDIR)/bin:$(PATH)
export HOSTNAME := $(shell hostname)
export PROJECT := $(PROJECT)

ifeq ($(DEBUG),true)
SILE = /home/caleb/projects/sile/sile
.SHELLFLAGS = +o nomatch -e -x -c
endif

.ONESHELL:
.SECONDEXPANSION:
.PHONY: all ci clean debug list force init dependencies sync_pre sync_post $(TARGETS) %.app md_cleanup stats %-stats
.SECONDARY:
.PRECIOUS: %.pdf %.sil %.toc %.dat %.inc
.DELETE_ON_ERROR:

all: $(TARGETS)

ci: | init clean debug sync_pre all sync_post stats

render: $(foreach TARGET,$(TARGETS),$(foreach LAYOUT,$(LAYOUTS),$(foreach RENDERING,$(RENDERINGS),$(TARGET)-$(LAYOUT)-$(RENDERING).png)))

clean:
	git clean -xf

debug:
	@echo PROJECT: $(PROJECT)
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
	@echo MAKEFILE_LIST: $(MAKEFILE_LIST)
	@echo MAKECMDGOALS: $(MAKECMDGOALS)
	@echo OUTPUTDIR: $(OUTPUTDIR)
	@echo INPUTDIR: $(INPUTDIR)
	@echo CASILEDIR: $(CASILEDIR)
	@echo SILE: $(SILE)
	@echo SILEPATH: $(SILEPATH)
	@echo M4MACROS: $(M4MACROS)
	@echo METADATA: $(METADATA)
	@echo versioninfo: $(call versioninfo,$(PROJECT))

force: ;

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

$(TARGETS): $(foreach FORMAT,$(FORMATS),$$@.$(FORMAT))

init: dependencies
	$(and $(OUTPUTDIR),mkdir -p $(OUTPUTDIR))
	git submodule update --init --remote
	cd $(CASILEDIR) && yarn install

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
	hash sponge
	hash m4
	hash entr
	hash pcregrep
	hash node
	hash perl
	hash python
	hash lua
	hash bc
	hash rsync
	hash zsh
	lua -v -l yaml
	perl -e ';' -MYAML
	perl -e ';' -MYAML::Merge::Simple
	python -c "import yaml"
	python -c "import isbnlib"

define addtosync =
	echo $@ >> sync_files.dat
endef

# If building in draft mode, scale resolutions down for quick builds
define scale =
$(strip $(shell $(DRAFT) && echo $(if $2,$2,"($1 + $(SCALE) - 1) / $(SCALE)" | bc) || echo $1))
endef

sync_pre:
	$(if $(INPUTDIR),,exit 0)
	$(call pre_sync)
	-rsync -ctv $(INPUTDIR)/* $(PROJECTDIR)/

sync_post: sync_files.dat
	$(if $(OUTPUTDIR),,exit 0)
	sort -u $< | sponge $<
	for target in $(TARGETS); do
ifeq ($(ALL_TAGS),)
		tagpath=
else
		tagpath=$$target/$(TAG_NAME)/
endif
		mkdir -p $(OUTPUTDIR)/$$tagpath
		while read file; do
			test -f $$file && rsync -ct $$file $(OUTPUTDIR)/$$tagpath
		done < $<
	done
	$(call post_sync)

VIRTUALPDFS = $(foreach TARGET,$(TARGETS),$(TARGET).pdf)
.PHONY: $(VIRTUALPDFS)
$(VIRTUALPDFS): %.pdf: $(foreach LAYOUT,$(LAYOUTS),$$*-$(LAYOUT).pdf) $(foreach LAYOUT,$(LAYOUTS),$(foreach RESOURCE,$(RESOURCES),$$*-$(LAYOUT)-$(RESOURCE).pdf)) ;

coverpreq = $(if $(filter $(CILTLI),$(call parse_layout,$1)),,%-kapak.pdf)

ONPAPERPDFS = $(foreach TARGET,$(TARGETS),$(foreach PAPERSIZE,$(PAPERSIZES),$(TARGET)-$(PAPERSIZE).pdf))
$(ONPAPERPDFS): %.pdf: %.sil $$(call coverpreq,$$@) .casile.lua
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	$(addtosync)
	# If in draft mode don't rebuild for TOC and do output debug info, otherwise
	# account for TOC issue: https://github.com/simoncozens/sile/issues/230
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	if $(DRAFT); then
		$(SILE) -I .casile.lua $(and $(SILEDEBUG),-d $(subst $( ),$(,),$(SILEDEBUG))) $< -o $@
	else
		export pg0=$(call pagecount,$@)
		$(SILE) -I .casile.lua $(and $(SILEDEBUG),-d $(subst $( ),$(,),$(SILEDEBUG))) $< -o $@
		# Note this page count can't be in Make because of expansion order
		export pg1=$$(pdfinfo $@ | awk '$$1 == "Pages:" {print $$2}' || echo 0)
		[[ $${pg0} -ne $${pg1} ]] && $(SILE) -I .casile.lua $< -o $@ ||:
		export pg2=$$(pdfinfo $@ | awk '$$1 == "Pages:" {print $$2}' || echo 0)
		[[ $${pg1} -ne $${pg2} ]] && $(SILE) -I .casile.lua $< -o $@ ||:
	fi
	# If we have a special cover page for this format, swap it out for the half title page
	if $(COVERS) && [[ -f $*-kapak.pdf ]]; then
		pdftk $@ dump_data_utf8 output $*.dat
		pdftk C=$*-kapak.pdf B=$@ cat C1 B2-end output $*.tmp.pdf
		pdftk $*.tmp.pdf update_info_utf8 $*.dat output $@
		rm $*.tmp.pdf
	fi

ONPAPERSILS = $(foreach PAPERSIZE,$(PAPERSIZES),%-$(PAPERSIZE).sil)
$(ONPAPERSILS): %-processed.md %-merged.yml %-url.png $(CASILEDIR)/template.sil | $$(wildcard $$*.lua) $$(wildcard $(PROJECT).lua) $(CASILEDIR)/layout-$$(call parse_layout,$$@).lua $(CASILEDIR)/viachristus.lua
	$(PANDOC) --standalone \
			--wrap=preserve \
			-V documentclass="$(DOCUMENTCLASS)" \
			-V metadatafile="$(word 2,$^)" \
			-V versioninfo="$(call versioninfo,$*)" \
			-V urlinfo="$(call urlinfo,$*)" \
			-V qrimg="./$(word 3,$^)" \
			$(foreach LUA,$|, -V script=$(basename $(LUA))) \
			--template=$(word 4,$^) \
			--to=sile \
			$(word 2,$^) $< |
		$(call sile_hook) > $@

.casile.lua: $(LUAINCLUDE)
	cat <<- EOF > $@
		CASILE = {}
		CASILE.casiledir = "$(CASILEDIR)"
		CASILE.publisher = "casile"
	EOF
	$(and $^,cat $^ >> $@)

%-processed.md: $(CASILEDIR)/casile.m4 $(M4MACROS) $(wildcard $(PROJECT).m4) $$(wildcard $$*.m4) %.md
	if $(DIFF) && $(if $(PARENT),true,false); then
		branch2criticmark.zsh $(PARENT) $(lastword $^) |
			sed -e 's#{==#\\criticHighlight{#g' -e 's#==}#}#g' \
				-e 's#{>>#\\criticComment{#g'   -e 's#<<}#}#g' \
				-e 's#{++#\\criticAdd{#g'       -e 's#++}#}#g' \
				-e 's#{--#\\criticDel{#g'       -e 's#--}#}#g'
	else
		m4 $^
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

define find_and_munge
	git diff-index --quiet --cached HEAD || exit 1 # die if anything already staged
	find $(PROJECTDIR) -maxdepth 2 -name '$1' |
		grep -f <(git ls-files | sed -e 's/$$/$$/') |
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
	$(if $(HEAD),head -n$(HEAD),cat) |
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

%.app: %-app.info $(foreach PANKART,$(PANKARTLI),%-$(PANKART)-pankart.jpg) ;

%-app.info: %-app.sil.toc %-merged.yml
	$(addtosync)
	$(CASILEDIR)/bin/toc2breaks.lua $* $^ $@ |
		while read range out; do
			pdftk $*-app.pdf cat $$range output $$out
			echo $$out >> sync_files.dat
		done

issue.info:
	$(addtosync)
	for source in $(TARGETS); do
		echo -e "# $$source\n"
		if test -d $${source}-bolumler; then
			find $${source}-bolumler -name '*.md' -print |
				sort -n |
				while read chapter; do
					number=$${chapter%-*}; number=$${number#*/}
					sed -ne "/^# /{s/ {.*}$$//;s!^# *\(.*\)! - [ ] $$number — [\1]($$chapter)!g;p}" $$chapter
				done
		elif grep -q '^# ' $$source.md; then
			sed -ne "/^# /{s/^# *\(.*\)/ - [ ] [\1]($${source}.md)/g;p}" $$source.md
		else
			echo -e " - [ ] [$${source}]($${source}.md)"
		fi
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
mmtopx = $(shell echo "$1 * $(HIDPI) * 0.0393701 / 1" | bc)
mmtopm = $(shell echo "$1 * 90 * .0393701 / 1" | bc)
mmtopt = $(shell echo "$1 * 2.83465 / 1" | bc)
width = $(shell identify -density $(HIDPI) -format %[fx:w] $1)
height = $(shell identify -density $(HIDPI) -format %[fx:h] $1)
parse_layout = $(filter $(PAPERSIZES),$(subst -, ,$(basename $1)))
strip_layout = $(filter-out $1,$(foreach PAPERSIZE,$(PAPERSIZES),$(subst -$(PAPERSIZE)-,-,$1)))

# Utility to modify recursive variables, see http://stackoverflow.com/a/36863261/313192
define prepend
$(eval $(1) = $(2)$(value $(1)))
endef
define append
$(eval $(1) = $(value $(1))$(2))
endef

ONPAPERZEMIN = $(foreach PAPERSIZE,$(filter-out $(CILTLI),$(PAPERSIZES)),%-$(PAPERSIZE)-kapak-zemin.png)
gitzemin = $(shell git ls-files -- $(call strip_layout,$1) 2>/dev/null)
$(ONPAPERZEMIN): $$(call gitzemin,$$@) | $$(subst -kapak-zemin.png,-geometry.zsh,$$@)
	@source $(firstword $|)
	$(if $^,true,false) && $(MAGICK) $^ \
		-gravity $(COVERGRAVITY) \
		-extent  "%[fx:w/h>=$${coveraspect}?h*$${coveraspect}:w]x" \
		-extent "x%[fx:w/h<=$${coveraspect}?w/$${coveraspect}:h]" \
		-resize $${coverwpx}x$${coverhpx} \
		-normalize \
		$@ ||:
	$(if $^,false,true) && $(MAGICK) \
		-size $${coverwpx}x$${coverhpx}^ $(call magick_zemin) -composite \
		\( -background none xc: $(call magick_kapak) \) -composite \
		$@ ||:

%-pankart.jpg: %-kapak.png | %-geometry.zsh
	$(addtosync)
	@source $(firstword $|)
	$(MAGICK) $< \
		-resize $${coverwpp}x$${coverhpp}^ \
		-quality 85 \
		$@

%-kapak.png: %-kapak-zemin.png %-kapak-metin.pdf | %-geometry.zsh
	source $(firstword $|)
	$(MAGICK) -density $(HIDPI) $(lastword $^)[0] \
		-fill none \
		-fuzz 5% \
		-draw 'color 1,1 replace' \
		+write mpr:metin \
		\( mpr:metin \
			-channel RGBA \
			-morphology Dilate:%[fx:w/500] Octagon \
			-channel RGB \
			-negate \
		\) -composite \
		\( mpr:metin \
			-channel RGBA \
			-morphology Dilate:%[fx:w/200] Octagon \
			-resize 25% \
			-blur 0x%[fx:w/200] \
			-resize 400% \
			-channel A \
			-level 0%,250% \
			-channel RGB \
			-negate \
		\) -composite \
		\( mpr:metin \
		\) -composite \
		\( $< \
		\) +swap -compose over -composite \
		+repage $@

%-kapak.pdf: %-kapak.png %-kapak-metin.pdf | %-geometry.zsh
	$(COVERS) || exit 0
	metin=$$(mktemp kapakXXXXXX.pdf)
	bg=$$(mktemp kapakXXXXXX.pdf)
	source $(firstword $|)
	$(MAGICK) $< \
		-density $(LODPI) \
		-compress jpeg \
		-quality 50 \
		+repage \
		$$bg
	pdftk $(lastword $^) cat 1 output $$metin
	pdftk $$metin background $$bg output $@
	rm $$metin $$bg

CILTFRAGMANLAR = $(foreach PAPERSIZE,$(filter $(CILTLI),$(PAPERSIZES)),%-$(PAPERSIZE)-cilt-metin.pdf)
													
$(CILTFRAGMANLAR): $(CASILEDIR)/cilt.xml %-merged.yml $$(subst -cilt-metin,,$$@) .casile.lua | $(CASILEDIR)/viachristus.lua $(CASILEDIR)/layout-$$(call parse_layout,$$@).lua $(CASILEDIR)/covers.lua $$(wildcard $(PROJECT).lua) $$(wildcard $$*.lua)
	cat <<- EOF > $*-cilt.lua
		versioninfo = "$(call versioninfo,$*)"
		metadatafile = "$(word 2,$^)"
		spine = "$(call spinemm,$(lastword $^))mm"
		$(foreach LUA,$|, SILE.require("$(basename $(LUA))");)
	EOF
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) -I <(cat .casile.lua <(echo 'CASILE.infofile = "$*-cilt"')) $< -o $@

%-fragman-on.png: %-cilt-metin.pdf
	$(MAGICK) -density $(HIDPI) $<[0] \
		$(call magick_fragman_on) \
		-composite $@

%-fragman-arka.png: %-cilt-metin.pdf
	$(MAGICK) -density $(HIDPI) $<[1] \
		$(call magick_fragman_arka) \
		-composite $@

%-fragman-sirt.png: %-cilt-metin.pdf | %.pdf
	$(MAGICK) -density $(HIDPI) $<[2] \
		-crop $(call mmtopx,$(call spinemm,$(word 1,$|)))x+0+0 \
		$(call magick_fragman_arka) \
		-composite $@

KAPAKMETIN = $(foreach PAPERSIZE,$(filter-out $(CILTLI),$(PAPERSIZES)),%-$(PAPERSIZE)-kapak-metin.pdf)
$(KAPAKMETIN): $(CASILEDIR)/kapak.xml %-merged.yml .casile.lua | $(CASILEDIR)/viachristus.lua $(CASILEDIR)/layout-$$(call parse_layout,$$@).lua $(CASILEDIR)/covers.lua $$(wildcard $(PROJECT).lua) $$(wildcard $$*.lua)
	lua=$*-$(call parse_layout,$@)-kapak
	cat <<- EOF > $$lua.lua
		versioninfo = "$(call versioninfo,$*)"
		metadatafile = "$(word 2,$^)"
		$(foreach LUA,$|, SILE.require("$(basename $(LUA))");)
	EOF
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) -I <(cat .casile.lua <(echo "CASILE.infofile = '$$lua'") | tee dd) $< -o $@

%-cilt.png: %-fragman-on.png %-fragman-arka.png %-fragman-sirt.png $$(call strip_layout,$$*-barkod.png) $(CASILEDIR)/vc_sembol_renkli.svg $(CASILEDIR)/vc_logo_renkli.svg %-geometry.zsh
	source $(lastword $^)
	texturew="$$(bc <<< "$$imgwpx / $(call scale,4,4)")"
	textureh="$$(bc <<< "$$imghpx / $(call scale,4,4)")"
	@$(MAGICK) -size $${imgwpx}x$${imghpx} -density $(HIDPI) \
		$(or $(and $(call gitzemin,$*-kapak-zemin.png),$(call gitzemin,$*-kapak-zemin.png) -resize $${imgwpx}x$${imghpx}!),$(call magick_zemin)) \
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

%-cilt.svg: $(CASILEDIR)/cilt.svg %-cilt.png %-geometry.zsh
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

%-cilt.pdf:	%-cilt.svg %-cilt.png %-geometry.zsh
	$(addtosync)
	source $(lastword $^)
	$(INKSCAPE) --without-gui \
		--export-dpi=$$hidpi \
		--export-margin=$$trimmm \
		--file=$< \
		--export-pdf=$@

newgeometry = $(shell grep -sqx hidpi=$(HIDPI) $1 || echo force)
geometrybase = $(if $(filter $(CILTLI),$(call parse_layout,$1)),$1.pdf $1-cilt-metin.pdf,$1-kapak-metin.pdf)

# Hard coded list instead of plain pattern because make is stupid: http://stackoverflow.com/q/41694704/313192
GEOMETRIES = $(foreach TARGET,$(TARGETS),$(foreach PAPERSIZE,$(PAPERSIZES),$(TARGET)-$(PAPERSIZE)-geometry.zsh))
$(GEOMETRIES): %-geometry.zsh: $$(call newgeometry,$$@) | $$(call geometrybase,$$*)
	export PS4=; set -x ; exec 2> $@ # black magic to output the finished math
	hidpi=$(HIDPI)
	lodpi=$(HIDPI)
	bleedmm=$(BLEED)
	bleedpx=$(call mmtopx,$(BLEED))
	bleedpm=$(call mmtopm,$(BLEED))
	bleedpt=$(call mmtopt,$(BLEED))
	trimmm=$(TRIM)
	trimpx=$(call mmtopx,$(TRIM))
	trimpm=$(call mmtopm,$(TRIM))
	trimpt=$(call mmtopt,$(TRIM))
	$(shell identify -density $(HIDPI) -format '
			coverwmm=%[fx:round(w/$(HIDPI)*25.399986)]
			coverwpx=%[fx:w]
			coverwpm=%[fx:round(w/$(HIDPI)*90)]
			coverwpt=%[fx:round(w/$(HIDPI)*72)]
			coverwpp=%[fx:round(w/$(HIDPI)*$(LODPI))]
			coverhmm=%[fx:round(h/$(HIDPI)*25.399986)]
			coverhpx=%[fx:h]
			coverhpm=%[fx:round(h/$(HIDPI)*90)]
			coverhpt=%[fx:round(h/$(HIDPI)*72)]
			coverhpp=%[fx:round(h/$(HIDPI)*$(LODPI))]
			coveraspect=%[fx:w/h]
		' $(lastword $|)[0] || echo false)
	spinemm=$(call spinemm,$(firstword $|))
	spinepx=$(call mmtopx,$(call spinemm,$(firstword $|)))
	spinepm=$(call mmtopm,$(call spinemm,$(firstword $|)))
	spinept=$(call mmtopt,$(call spinemm,$(firstword $|)))
	ciltwmm=$$(($$coverwmm+$$spinemm+$$coverwmm))
	ciltwpx=$$(($$coverwpx+$$spinepx+$$coverwpx))
	ciltwpm=$$(($$coverwpm+$$spinepm+$$coverwpm))
	ciltwpt=$$(($$coverwpt+$$spinept+$$coverwpt))
	imgwmm=$$(($$ciltwmm+$$bleedmm*2))
	imgwpx=$$(($$ciltwpx+$$bleedpx*2))
	imgwpm=$$(($$ciltwpm+$$bleedpm*2))
	imgwpt=$$(($$ciltwpt+$$bleedpt*2))
	imghmm=$$(($$coverhmm+$$bleedmm*2))
	imghpx=$$(($$coverhpx+$$bleedpx*2))
	imghpm=$$(($$coverhpm+$$bleedpm*2))
	imghpt=$$(($$coverhpt+$$bleedpt*2))

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
	-background none $(CASILEDIR)/vc_logo_renksiz.svg \
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

%-cilt-on.png: %-cilt.png %-geometry.zsh
	source $(word 2,$^)
	$(MAGICK) $< -gravity east -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! $@

%-cilt-arka.png: %-cilt.png %-geometry.zsh
	source $(word 2,$^)
	$(MAGICK) $< -gravity west -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! $@

%-cilt-sirt.png: %-cilt.png %-geometry.zsh
	source $(word 2,$^)
	$(MAGICK) $< -gravity center -crop $${spinepx}x$${coverhpx}+0+0! $@

%-pov-on.png: %-cilt-on.png %-geometry.zsh
	source $(lastword $^)
	$(MAGICK) $< \
		$(call magick_crease,0+) \
		$(call magick_fray) \
		$@

%-pov-arka.png: %-cilt-arka.png %-geometry.zsh
	source $(lastword $^)
	$(MAGICK) $< \
		$(call magick_crease,w-) \
		$(call magick_fray) \
		$@

%-pov-sirt.png: %-cilt-sirt.png
	$(MAGICK) $< -gravity center -extent 200%x100% $@

povtextures = %-pov-on.png %-pov-arka.png %-pov-sirt.png

%-3b.pov: %-geometry.zsh | $(povtextures)
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

%-3b-on.png: $(CASILEDIR)/kapak.pov %-3b.pov $(CASILEDIR)/on.pov | $(povtextures)
	$(addtosync)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,6000,8000)
	$(call povcrop,$@)

%-3b-arka.png: $(CASILEDIR)/kapak.pov %-3b.pov $(CASILEDIR)/arka.pov | $(povtextures)
	$(addtosync)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,6000,8000)
	$(call povcrop,$@)

%-3b-istif.png: $(CASILEDIR)/kapak.pov %-3b.pov $(CASILEDIR)/istif.pov | $(povtextures)
	$(addtosync)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,8000,6000)
	$(call povcrop,$@)

%.epub %.odt %.docx: %-processed.md %-merged.yml %-epub-pankart.jpg
	$(addtosync)
	$(PANDOC) \
		--smart \
		--epub-cover-image=$(lastword $^) \
		$(word 2,$^) \
		$< -o $@

%.mobi: %.epub
	$(call addtosync,$@)
	-kindlegen $<

%.json: $(CASILEDIR)/casile.yml $(METADATA) $$(wildcard $(PROJECT).yml $$*.yml)
	jq -s 'reduce .[] as $$item({}; . + $$item)' $(foreach YAML,$^,<(yaml2json $(YAML))) > $@

%-merged.yml: $(CASILEDIR)/casile.yml $(METADATA) $$(wildcard $(PROJECT).yml $$*.yml)
	perl -MYAML::Merge::Simple=merge_files -MYAML -E 'say Dump merge_files(@ARGV)' $^ |
		sed -e 's/~$$/nil/g;/^--- |/d;$$a...' > $@

%-barkod.svg: %-merged.yml
	zint --directsvg --scale=5 --barcode=69 --height=30 \
		--data=$(shell $(CASILEDIR)/bin/isbn_format.py $< print) |\
		$(CONVERT) - \
			-bordercolor white -border 10 \
			-font Hack-Regular -pointsize 36 \
			label:"ISBN $(shell $(CASILEDIR)/bin/isbn_format.py $< print mask)" +swap -gravity center -append \
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
	stats.zsh $* $(STATSMONTHS)

%-ayetler.json: %.md
	# cd $(CASILEDIR)
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
	$(if $(SOURCES),,exit 0)
	$(foreach SOURCE,$(SOURCES),$(call split_chapters,$(SOURCE)))

watch:
	git ls-files --recurse-submodules |
		entr -c -p make DRAFT=true $(WATCH_ARGS)

watchdiff:
	git ls-files | entr -c -p git diff --color=always
