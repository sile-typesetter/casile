SHELL := zsh
.SHELLFLAGS := +o nomatch -e -c

# Initial setup, environment dependent
PROJECTDIR := $(shell cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd)
CASILEDIR := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
GITNAME := $(notdir $(shell git worktree list | head -n1 | awk '{print $$1}'))
PROJECT ?= $(GITNAME)
PUBDIR ?= $(PROJECTDIR)/pub
PUBLISHERDIR ?= $(CASILEDIR)

# Set the language if not otherwise set
LANGUAGE ?= en

# Localization functions (source is a key => val file _and_ its inverse)
-include $(CASILEDIR)/makefile-$(LANGUAGE) $(CASILEDIR)/makefile-$(LANGUAGE)-reversed

# CaSILE Utility functions
include $(CASILEDIR)/makefile-functions

# Empty recipies for anything we _don't_ want to bother rebuilding:
$(MAKEFILE_LIST):;

MARKDOWNSOURCES := $(call find,*.md)
LUASOURCES := $(call find,*.lua)
MAKESOURCES := $(call find,[Mm]akefile*)
YAMLSOURCES := $(call find,*.yml)

# Find stuff to build that has both a YML and a MD component
TARGETS ?= $(filter $(basename $(notdir $(MARKDOWNSOURCES))),$(basename $(notdir $(YAMLSOURCES))))

# List of targets that don't have content but should be rendered anyway
MOCKUPTARGETS ?=
MOCKUPBASE ?= $(firstword $(TARGETS))
MOCKUPFACTOR ?= 1

# List of figures that need building prior to content
FIGURES ?=

# Default output formats and parameters (often overridden)
FORMATS ?= pdf epub
BLEED ?= 3
TRIM ?= 10
NOBLEED ?= 0
NOTRIM ?= 0
PAPERWEIGHT ?= 60
STAPLECOUNT ?= 2
COILSPACING ?= 12
COILWIDTH ?= 8
COILCOLOR ?= rgb<.7,.7,.7>
COVERGRAVITY ?= Center
SCENELIGHT ?= rgb<1,1,1>

# Build mode flags
DRAFT ?= false # Take shortcuts, scale things down, be quick about it
LAZY ?= false # Pretend to do things we didn't
DIFF ?= false # Show differences to parent brancd in build
STATSMONTHS ?= 1 # How far back to look for commits when building stats
DEBUG ?= false # Use SILE debug flags, set -x, and the like
DEBUGTAGS ?= casile # Specific debug flags to set
COVERS ?= true # Build covers?
MOCKUPS ?= true # Render mockup books in project
SCALE ?= 17 # Reduction factor for draft builds
HIDPI ?= $(call scale,1200) # Default DPI for generated press resources
LODPI ?= $(call scale,300) # Default DPI for generated consumer resources
SORTORDER ?= meta # Sort series by: none, alphabetical, date, meta, manual

# Allow overriding executables used
SILE ?= sile
PANDOC ?= pandoc
CONVERT ?= convert
IDENTIFY ?= identify
MAGICK ?= magick
INKSCAPE ?= inkscape
POVRAY ?= povray

# Set default output format(s)
LAYOUTS ?= a4-$(_print)

# Add any specifically targeted outputs to input layouts
GOALLAYOUTS = $(sort $(filter $(foreach BINDING,$(BINDINGS),%-$(BINDING)),$(foreach GOAL,$(MAKECMDGOALS),$(call parse_layout,$(GOAL)))))
LAYOUTS += $(GOALLAYOUTS)

# Categorize supported outputs
PAPERSIZES := $(call localize,$(subst layout-,,$(notdir $(basename $(wildcard $(CASILEDIR)/layout-*.lua)))))
BINDINGS := $(call localize,print paperback hardcover coil stapled)

DISPLAYS := $(_app) $(_screen)
PLACARDS := $(_square) $(_wide) $(_banner) epub
RENDERINGS := $(_3d)-$(_front) $(_3d)-$(_back) $(_3d)-$(_pile)

RENDERED ?= $(filter $(call pattern_list,$(filter-out $(DISPLAYS) $(PLACARDS),$(PAPERSIZES)),-%),$(LAYOUTS))
RENDERED += $(GOALLAYOUTS)

# Default to running multiple jobs
JOBS := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)
MAKEFLAGS += "-j $(JOBS)"

# Over-ride entr arguments, defaults to just clear
# Add -r to kill and restart jobs on activity
# And -p to wait for activity on first invocation
ENTRFLAGS := -c -r

# POVray's progress status output doesn't play nice with Gitlab's CI logging
ifneq ($(CI),)
POVFLAGS += -V
endif

# List of extra m4 macro files to apply to every source
M4MACROS ?=
PROJECTMACRO := $(wildcard $(PROJECT).m4)

# List of extra YAML meta data files to splice into each book
METADATA ?=
PROJECTYAML = $(wildcard $(PROJECT).yml)

# Extra lua files to include before processing documents
LUAINCLUDES += .casile.lua
PROJECTLUA := $(wildcard $(PROJECT).lua)

# Primary libraries to include (loaded in reverse order so this one is first)
LUALIBS += $(CASILEDIR)/casile.lua

# Extensible list of files for git to ignore
IGNORES += $(PROJECTCONFIGS)
IGNORES += $(LUAINCLUDES)
IGNORES += $(FIGURES)
IGNORES += $(PUBLISHERLOGO) $(PUBLISHEREMBLUM)
IGNORES += $(foreach PAPERSIZE,$(PAPERSIZES),$(PROJECT)-$(PAPERSIZE)*)
IGNORES += $(foreach TARGET,$(TARGETS),$(foreach FORMAT,$(FORMATS),$(TARGET).$(FORMAT)))
IGNORES += $(call pattern_list,$(TARGETS),$(PAPERSIZES),*)
IGNORES += $(INTERMEDIATES)

# Tell sile to look here for stuff before it’s internal stuff
SILEPATH += $(CASILEDIR)

# Extra arguments to pass to Pandoc
PANDOCARGS ?=

# Figure out if we're being run from
ATOM ?= $(shell env | grep -q ATOM_ && echo true || echo false)
ifeq ($(ATOM),true)
DRAFT = true
endif

# Set default document class
DOCUMENTCLASS ?= cabook
DOCUMENTOPTIONS += binding=$(call unlocalize,$(call parse_binding,$@))

# Default template for setting up Gitlab CI runners
CITEMPLATE ?= $(CASILEDIR)/travis.yml
CICONFIG ?= .travis.yml

# List of files that persist across make clean
PROJECTCONFIGS :=

ifeq ($(DRAFT),true)
$(MAKECMDGOALS): force
endif

# For watch targets, treat extra parameters as things to pass to the next make
ifeq (watch,$(firstword $(MAKECMDGOALS)))
WATCHARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(WATCHARGS):;@:)
endif

export PATH := $(CASILEDIR)/bin:$(PATH)
export HOSTNAME := $(shell hostname)
export PROJECT := $(PROJECT)

LOCALSILE ?= $(HOME)/projects/sile
ifeq ($(DEBUG),true)
SILE = $(LOCALSILE)/sile
.SHELLFLAGS += -x
endif

# Pass debug tags on to SILE
ifdef DEBUGTAGS
SILEFLAGS += -d $(subst $( ),$(,),$(DEBUGTAGS))
endif

# Add mock-ups to targets
ifeq ($(strip $(MOCKUPS)),true)
TARGETS += $(MOCKUPTARGETS)
endif

# Probe for available sources relevant to each target once
$(foreach TARGET,$(TARGETS),$(eval TARGETMACROS_$(TARGET) := $(wildcard $(TARGET).lua)))
$(foreach TARGET,$(TARGETS),$(eval TARGETYAMLS_$(TARGET) := $(wildcard $(TARGET).yml)))
$(foreach TARGET,$(TARGETS),$(eval TARGETLUAS_$(TARGET) := $(wildcard $(TARGET).lua)))

.ONESHELL:
.SECONDEXPANSION:
.SECONDARY:
.PRECIOUS: %.pdf %.sil %.toc %.dat %.inc
.DELETE_ON_ERROR:

# Disable as many default suffix and pattern rules as we can (makes debug output saner)
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules

.PHONY: books
books: $(TARGETS)

# Setup target dependencies to mimic stages of a CI pipeline
ifeq ($(MAKECMDGOALS),ci)
CI ?= 1
sync_pre: init debug
sync_post: books renderings promotionals
books: sync_pre
renderings: sync_pre
promotionals: sync_pre
endif

.PHONY: ci
ci: init debug sync_pre books renderings promotionals sync_post

.PHONY: renderings
renderings: $(call pattern_list,$(TARGETS),$(RENDERED),$(RENDERINGS),.jpg)

.PHONY: promotionals
promotionals: $(call pattern_list,$(TARGETS),$(PLACARDS),-$(_poster).jpg) $(call pattern_list,$(TARGETS),-icon.png)

# If a series, add some extra dependencies to convenience builds
ifneq ($(words $(TARGETS)),1)
promotionals: series_promotionals
renderings: series_renderings
endif

.PHONY: series_promotionals
series_promotionals: $(PROJECT)-epub-$(_poster)-$(_montage).jpg $(PROJECT)-$(_square)-$(_poster)-$(_montage).jpg

ifneq ($(filter ci promotionals series_promotionals %.web,$(MAKECMDGOALS)),)
LAYOUTS += $(call pattern_list,$(PLACARDS),-$(_print))
endif

.PHONY: series_renderings
series_renderings: $(call pattern_list,$(PROJECT),$(RENDERED),-$(_3d)-$(_montage).jpg)

$(PROJECT)-%-$(_poster)-$(_montage).png: $$(call pattern_list,$(TARGETS),%,-$(_poster).png) $(firstword $(TARGETS))-%-$(_geometry).sh
	$(sourcegeometry)
	$(MAGICK) montage \
		$(filter %.png,$^) \
		-geometry $${pagewpm}x$${pagehpm}+0+0 \
		$@

.PHONY: clean
clean: | $(require_pubdir)
	git clean -xf $(foreach CONFIG,$(PROJECTCONFIGS),-e $(CONFIG))
	rm -f $(PUBDIR)/*

.PHONY: debug
debug:
	@echo ALLTAGS: $(ALLTAGS)
	@echo BINDINGS: $(BINDINGS)
	@echo CASILEDIR: $(CASILEDIR)
	@echo CICONFIG: $(CICONFIG)
	@echo CITEMPLATE: $(CITEMPLATE)
	@echo DEBUG: $(DEBUG)
	@echo DEBUGTAGS: $(DEBUGTAGS)
	@echo DIFF: $(DIFF)
	@echo DOCUMENTCLASS: $(DOCUMENTCLASS)
	@echo DOCUMENTOPTIONS: $(DOCUMENTOPTIONS)
	@echo DRAFT: $(DRAFT)
	@echo FIGURES: $(FIGURES)
	@echo FORMATS: $(FORMATS)
	@echo GOALLAYOUTS: $(GOALLAYOUTS)
	@echo INPUTDIR: $(INPUTDIR)
	@echo LAYOUTS: $(LAYOUTS)
	@echo LUAINCLUDES: $(LUAINCLUDES)
	@echo LUALIBS: $(LUALIBS)
	@echo LUASOURCES: $(LUASOURCES)
	@echo M4MACROS: $(M4MACROS)
	@echo MAKECMDGOALS: $(MAKECMDGOALS)
	@echo MAKEFILE_LIST: $(MAKEFILE_LIST)
	@echo MAKESOURCES: $(MAKESOURCES)
	@echo MARKDOWNSOURCES: $(MARKDOWNSOURCES)
	@echo METADATA: $(METADATA)
	@echo MOCKUPBASE: $(MOCKUPBASE)
	@echo MOCKUPFACTOR: $(MOCKUPFACTOR)
	@echo MOCKUPTARGETS: $(MOCKUPTARGETS)
	@echo OUTPUTDIR: $(OUTPUTDIR)
	@echo PANDOCARGS: $(PANDOCARGS)
	@echo PAPERSIZES: $(PAPERSIZES)
	@echo PARENT: $(PARENT)
	@echo PROJECT: $(PROJECT)
	@echo PROJECTCONFIGS: $(PROJECTCONFIGS)
	@echo RENDERED: $(RENDERED)
	@echo SILE: $(SILE)
	@echo SILEFLAGS: $(SILEFLAGS)
	@echo SILEPATH: $(SILEPATH)
	@echo TAG: $(TAG)
	@echo TAGNAME: $(TAGNAME)
	@echo TARGETS: $(TARGETS)
	@echo YAMLSOURCES: $(YAMLSOURCES)
	@echo urlinfo: $(call urlinfo,$(PROJECT))
	@echo versioninfo: $(call versioninfo,$(PROJECT))

.PHONY: force
force: ;

.PHONY: fail

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.PHONY: $(TARGETS)
REALTARGETS = $(filter-out $(MOCKUPTARGETS),$(TARGETS))
$(REALTARGETS): $(foreach FORMAT,$(FORMATS),$$@.$(FORMAT))
$(MOCKUPTARGETS): $(foreach FORMAT,$(filter pdf,$(FORMATS)),$$@.$(FORMAT))

.PHONY: figures
figures: $(FIGURES)

.PHONY: init
init: check_dependencies init_toolkits update_repository $(PUBDIR) $(OUTPUTDIR)

$(PUBDIR) $(OUTPUTDIR):
	mkdir -p $@

.PHONY: init_casile
init_casile: time_warp_casile $(CASILEDIR)/yarn.lock

$(CASILEDIR)/yarn.lock: $(CASILEDIR)/package.json
	cd $(CASILEDIR) && yarn install

.PHONY: check_dependencies
check_dependencies:
	hash yarn
	hash $(SILE)
	hash $(PANDOC)
	$(PANDOC) --list-output-formats | grep -q sile
	hash $(CONVERT)
	hash $(IDENTIFY)
	hash $(MAGICK)
	hash $(POVRAY)
	# hash yaml2json
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
	python -c "import pandocfilters"
	$(call depend_font,Hack)
	$(call depend_font,TeX Gyre Heros)
	$(call depend_font,Libertinus Serif)
	$(call depend_font,Libertinus Serif Display)
	$(call depend_font,Libertinus Sans)

.PHONY: init_toolkits
init_toolkits: init_casile time_warp .gitignore .editorconfig

.PHONY: update_toolkits
update_toolkits: update_casile

.PHONY: upgrade_toolkits
upgrade_toolkits: upgrade_casile

.PHONY: init_casile
init_casile: time_warp_casile
	cd $(CASILEDIR) && yarn install

.PHONY: update_casile
update_casile: init_casile
	git submodule update --init --remote -- $(CASILEDIR)
	$(call time_warp,$(CASILEDIR))
	cd $(CASILEDIR) && yarn upgrade

.PHONY: upgrade_repository
upgrade_repository: upgrade_toolkits $(CICONFIG)_current

.PHONY: upgrade_casile
upgrade_casile: update_casile $(CASILEDIR)/upgrade-lua.sed $(CASILEDIR)/upgrade-make.sed $(CASILEDIR)/upgrade-yaml.sed
	$(call munge,$(LUASOURCES),sed -f $(filter %-lua.sed,$^),Replace old Lua variables and functions with new namespaces)
	$(call munge,$(MAKESOURCES),sed -f $(filter %-make.sed,$^),Replace old Makefile variables and functions with new namespaces)
	$(call munge,$(YAMLSOURCES),sed -f $(filter %-yaml.sed,$^),Replace old YAML key names)

.PHONY: update_repository
update_repository:
	git fetch --all --prune --tags

PROJECTCONFIGS += .editorconfig
.editorconfig: $(CASILEDIR)/editorconfig
	$(call skip_if_tracked,$@)
	cp $< $@

PROJECTCONFIGS += .gitignore
.gitignore: $(CASILEDIR)/gitignore $(MAKEFILE_LIST) | $(require_pubdir)
	$(call skip_if_tracked,$@)
	cp $< $@
	$(foreach IGNORE,$(IGNORES),echo '$(IGNORE)' >> $@;)

$(CICONFIG): $(CITEMPLATE)
	cat $< | \
		$(call ci_setup) | \
		sponge $@

$(CASILEDIR)/makefile-%-reversed: $(CASILEDIR)/makefile-%
	@awk -F' := ' '/^_/ { gsub(/_/, "", $$1); print "__" $$2 " := " $$1 }' < $< > $@

# Pass or fail target showing whether the CI config is up to date
.PHONY: $(CICONFIG)_current
$(CICONFIG)_current: $(CICONFIG)
	git update-index --refresh --ignore-submodules ||:
	git diff-files --quiet -- $<

# Reset file timestamps to git history to avoid unnecessary builds
.PHONY: time_warp time_warp_casile
time_warp: time_warp_casile
	$(call time_warp,$(PROJECTDIR))

time_warp_casile:
	$(call time_warp,$(CASILEDIR))

.PHONY: sync_pre
sync_pre: | $(require_pubdir) $(require_outputdir)
	$(call pre_sync)
	rsync -ctv $(INPUTDIR)/* $(PROJECTDIR)/ ||:

.PHONY: sync_post
sync_post: | $(require_pubdir) $(require_outputdir)
	for target in $(TARGETS); do
ifeq ($(ALLTAGS),)
		tagpath=
else
		tagpath=$$target/$(TAGNAME)/
endif
		mkdir -p $(OUTPUTDIR)/$$tagpath
		find $(PUBDIR) \
			-type f -name "$${target}*" \
			-execdir rsync -ct {} $(OUTPUTDIR)/$$tagpath \;
	done
	find $(PUBDIR) \
		-type f -name "$(PROJECT)*" \
		-execdir rsync -ct {} $(OUTPUTDIR)/$$tagpath \;
	$(call post_sync)

# Just needing a PDF format isn't enough without knowing what layouts to build
VIRTUALPDFS = $(call pattern_list,$(TARGETS),.pdf)
.PHONY: $(VIRTUALPDFS)
$(VIRTUALPDFS): %.pdf: $(call pattern_list,$$*,$(LAYOUTS),.pdf) ;

# Some layouts have matching extra resources to build such as covers
$(VIRTUALPDFS): $$(call pattern_list,$$(basename $$@),$(filter %-$(_paperback),$(LAYOUTS)),$(_binding),.pdf)
$(VIRTUALPDFS): $$(call pattern_list,$$(basename $$@),$(filter %-$(_hardcover),$(LAYOUTS)),$(_case) $(jacket),.pdf)
$(VIRTUALPDFS): $$(call pattern_list,$$(basename $$@),$(filter %-$(_coil),$(LAYOUTS)),$(_cover),.pdf)
$(VIRTUALPDFS): $$(call pattern_list,$$(basename $$@),$(filter %-$(_stapled),$(LAYOUTS)),$(_binding),.pdf)

# Some layouts have matching resources that need to be built first and included
coverpreq = $(and $(filter true,$(COVERS)),$(filter $(_print),$(call parse_binding,$1)),$(filter-out $(DISPLAYS) $(PLACARDS),$(call parse_papersize,$1)),$(basename $1)-$(_cover).pdf)

# Order is important here, these are included in reverse order so early supersedes late
onpaperlibs = $(TARGETLUAS_$(call parse_bookid,$1)) $(PROJECTLUA) $(CASILEDIR)/layout-$(call unlocalize,$(call parse_papersize,$1)).lua $(LUALIBS)

MOCKUPPDFS = $(call pattern_list,$(MOCKUPTARGETS),$(filter-out $(PLACARDS),$(PAPERSIZES)),$(BINDINGS),.pdf)
$(MOCKUPPDFS): %.pdf: $$(call mockupbase,$$@)
	pdftk A=$(filter %.pdf,$^) cat $(foreach P,$(shell seq 1 $(call pagecount,$@)),A2-2) output $@

FULLPDFS = $(call pattern_list,$(REALTARGETS),$(filter-out $(PLACARDS),$(PAPERSIZES)),$(BINDINGS),.pdf)
$(FULLPDFS): PANDOCARGS += --filter=$(CASILEDIR)/svg2pdf.py
$(FULLPDFS): %.pdf: %.sil $$(call coverpreq,$$@) .casile.lua $$(call onpaperlibs,$$@) $(LUAINCLUDES) | $(require_pubdir)
	$(call skip_if_lazy,$@)
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	# If in draft mode don't rebuild for TOC and do output debug info, otherwise
	# account for TOC $(_issue): https://github.com/simoncozens/sile/issues/230
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	if $(DRAFT); then
		$(SILE) $(SILEFLAGS) $< -o $@
	else
		export pg0=$(call pagecount,$@)
		$(SILE) $(SILEFLAGS) $< -o $@
		# Note this page count can't be in Make because of expansion order
		export pg1=$$(pdfinfo $@ | awk '$$1 == "Pages:" {print $$2}' || echo 0)
		[[ $${pg0} -ne $${pg1} ]] && $(SILE) $(SILEFLAGS) $< -o $@ ||:
		export pg2=$$(pdfinfo $@ | awk '$$1 == "Pages:" {print $$2}' || echo 0)
		[[ $${pg1} -ne $${pg2} ]] && $(SILE) $(SILEFLAGS) $< -o $@ ||:
	fi
	# If we have a special cover page for this format, swap it out for the half title page
	coverfile=$(filter %-$(_cover).pdf,$^)
	if $(COVERS) && [[ -f $coverfile ]]; then
		pdftk $@ dump_data_utf8 output $*.dat
		pdftk C=$${coverfile} B=$@ cat C1 B2-end output $*.tmp.pdf
		pdftk $*.tmp.pdf update_info_utf8 $*.dat output $@
		rm $*.tmp.pdf
	fi
	$(addtosync)

FULLSILS = $(call pattern_list,$(TARGETS),$(LAYOUTS),.sil)
$(FULLSILS): %.sil: $$(call pattern_list,$$(call parse_bookid,$$@),-$(_processed).md -manifest.yml -$(_verses)-$(_sorted).json -url.png) $(CASILEDIR)/template.sil | $$(call onpaperlibs,$$@)
	$(PANDOC) --standalone \
			$(PANDOCARGS) \
			--wrap=preserve \
			-V documentclass="$(DOCUMENTCLASS)" \
			$(if $(DOCUMENTOPTIONS),-V classoptions="$(call join_with,$(,),$(DOCUMENTOPTIONS))",) \
			-V metadatafile="$(filter %-manifest.yml,$^)" \
			-V versesfile="$(filter %-$(_verses)-$(_sorted).json,$^)" \
			-V versioninfo="$(call versioninfo,$@)" \
			-V urlinfo="$(call urlinfo,$@)" \
			-V qrimg="./$(filter %-url.png,$^)" \
			$(foreach LUA,$(filter %.lua,$|), -V script=$(basename $(LUA))) \
			--template=$(filter %.sil,$^) \
			--from=markdown-raw_tex \
			--to=sile \
			$(filter %-manifest.yml,$^) =( $(call pre_sile_markdown_hook) < $< ) |
		$(call sile_hook) > $@

# Send some environment data to a common Lua file to be pulled into all SILE runs
.casile.lua:
	cat <<- EOF > $@
		CASILE = {}
		CASILE.casiledir = "$(CASILEDIR)"
		CASILE.publisher = "casile"
	EOF

# Configure SILE arguments to include common Lua library
SILEFLAGS += $(foreach LUAINCLUDE,$(call reverse,$(LUAINCLUDES)),-I $(LUAINCLUDE))

preprocess_macros = $(CASILEDIR)/casile.m4 $(M4MACROS) $(PROJECTMACRO) $(TARGETMACROS_$1)

INTERMEDIATES += *-$(_processed).md
%-$(_processed).md: %.md $$(call preprocess_macros,$$*) $$(wildcard $$*-bolumler/*.md) | figures
	if $(DIFF) && $(if $(PARENT),true,false); then
		branch2criticmark.zsh $(PARENT) $<
	else
		m4 $(filter %.m4,$^) $<
	fi |
		renumber_footnotes.pl |
		$(call criticToSile) |
		$(call normalize_markdown) |
		$(call markdown_hook) > $@

%-$(_booklet).pdf: %-$(_spineless).pdf | $(require_pubdir)
	pdfbook --short-edge --noautoscale true --papersize "{$(call pageh,$<)pt,$$(($(call pagew,$<)*2))pt}" --outfile $@ -- $<
	$(addtosync)

%-topbottom.pdf: %-set1.pdf %-set2.pdf
	pdftk A=$(word 1,$^) B=$(word 2,$^) shuffle A B output $@

%-a4proof.pdf: %-topbottom.pdf | $(require_pubdir)
	pdfjam --nup 1x2 --noautoscale true --paper a4paper --outfile $@ -- $<
	$(addtosync)

%-cropleft.pdf: %.pdf | $$(geometryfile)
	$(sourcegeometry)
	t=$$(echo "$${trimpt} * 100" | bc)
	s=$$(echo "$${spinept} * 100 / 4" | bc)
	w=$$(echo "$(call pagew,$<) * 100 - $$t + $$s" | bc)
	h=$$(echo "$(call pageh,$<) * 100" | bc)
	podofobox $< $@ media 0 0 $$w $$h

%-cropright.pdf: %.pdf | $$(geometryfile)
	$(sourcegeometry)
	t=$$(echo "$${trimpt} * 100" | bc)
	s=$$(echo "$${spinept} * 100 / 4" | bc)
	w=$$(echo "$(call pagew,$<) * 100 - $$t + $$s" | bc)
	h=$$(echo "$(call pageh,$<) * 100" | bc)
	podofobox $< $@ media $$(($$t-$$s)) 0 $$w $$h

%-$(_spineless).pdf: %-$(_odd)-cropright.pdf %-$(_even)-cropleft.pdf
	pdftk A=$(word 1,$^) B=$(word 2,$^) shuffle A B output $@

%-$(_cropped).pdf: %.pdf | $$(geometryfile) $(require_pubdir)
	$(sourcegeometry)
	t=$$(echo "$${trimpt} * 100" | bc)
	w=$$(echo "$(call pagew,$<) * 100 - $$t * 2" | bc)
	h=$$(echo "$(call pageh,$<) * 100 - $$t * 2" | bc)
	podofobox $< $@ media $$t $$t $$w $$h
	$(addtosync)

%-set1.pdf: %.pdf
	pdftk $< cat 1-$$(($(call pagecount,$<)/2)) output $@

%-set2.pdf: %.pdf
	pdftk $< cat $$(($(call pagecount,$<)/2+1))-end output $@

%-$(_even).pdf: %.pdf
	pdftk $< cat even output $@

%-$(_odd).pdf: %.pdf
	pdftk $< cat odd output $@

.PHONY: normalize_lua
normalize_lua: $(LUASOURCES)
	$(call munge,$^,sed -e 's/function */function /g',Normalize Lua coding style)

.PHONY: normalize_markdown
normalize_markdown: $(MARKDOWNSOURCES)
	$(call munge,$^,msword_escapes.pl,Fixup bad MS word typing habits that Pandoc tries to preserve)
	$(call munge,$^,lazy_quotes.pl,Replace lazy double single quotes with real doubles)
	$(call munge,$^,smart_quotes.pl,Replace straight quotation marks with typographic variants)
	$(call munge,$^,figure_dash.pl,Convert hyphens between numbers to figure dashes)
	$(call munge,$^,unicode_symbols.pl,Replace lazy ASCI shortcuts with Unicode symbols)
	$(call munge,$^,italic_reorder.pl,Fixup italics around names and parethesised translations)
	$(call munge,$^,$(PANDOC) --atx-headers --wrap=preserve --to=markdown-smart,Normalize and tidy Markdown syntax using Pandoc)
	#(call munge,$^,reorder_punctuation.pl,Cleanup punctuation mark order such as footnote markers)
	#(call munge,$^,apostrophize_names.pl,Use apostrophes when adding suffixes to proper names)

%.toc: %.pdf ;

%.sil.tov: %.pdf ;

APPTARGETS = $(call pattern_list,$(TARGETS),.$(_app))
.PHONY: $(APPTARGETS)
$(APPTARGETS): %.$(_app): %-$(_app).info promotionals

WEBTARGETS = $(call pattern_list,$(TARGETS),.web)
.PHONY: $(WEBTARGETS)
$(WEBTARGETS): %.web: %-manifest.yml %-epub-$(_poster).jpg promotionals renderings

%-$(_app).info: %-$(_app).toc %-$(_app).pdf %-manifest.yml | $(require_pubdir)
	$(CASILEDIR)/bin/toc2breaks.lua $* $(filter %-$(_app).toc,$^) $(filter %-manifest.yml,$^) $@ |
		while read range out; do
			pdftk $(filter %-$(_app).pdf,$^) cat $$range output $$out
			ln -f $$out $(PUBDIR)/$$out
		done
	$(addtosync)

$(_issue).info: | $(require_pubdir)
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
	$(addtosync)

COVERBACKGROUNDS = $(call pattern_list,$(TARGETS),$(LAYOUTS),-$(_cover)-$(_background).png)
git_background = $(shell git ls-files -- $(call strip_layout,$1) 2>/dev/null)
$(COVERBACKGROUNDS): %-$(_cover)-$(_background).png: $$(call git_background,$$@) $$(geometryfile)
	$(sourcegeometry)
	$(if $(filter %.png,$(call git_background,$@)),true,false) && $(MAGICK) $(filter %.png,$^) \
		-gravity $(COVERGRAVITY) \
		-extent  "%[fx:w/h>=$${pageaspect}?h*$${pageaspect}:w]x" \
		-extent "x%[fx:w/h<=$${pageaspect}?w/$${pageaspect}:h]" \
		-resize $${pagewpx}x$${pagehpx} \
		$(call magick_background_filter) \
		$@ ||:
	$(if $(filter %.png,$(call git_background,$@)),false,true) && $(MAGICK) \
		-size $${pagewpx}x$${pagehpx}^ $(call magick_background_cover) -compose SrcOver -composite \
		$@ ||:

# Requires fake geometry file with no binding spec because binding not part of pattern
%-$(_poster).png: %-$(_print)-$(_cover).png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< \
		-resize $${pagewpp}x$${pagehpp}^ \
		$(and $(filter epub,$(call parse_papersize,$@)),-resize 1000x1600^) \
		$@

%-$(_cover).png: %-$(_cover)-$(_background).png %-$(_cover)-$(_fragment).png $$(geometryfile)
	$(sourcegeometry)
	@$(MAGICK) $< \
		\( -background none \
			-gravity Center \
			-size $${pagewpx}x$${pagehpx} \
			xc: \
			$(call magick_cover) \
		\) -compose SrcOver -composite \
		\( \
			-gravity Center \
			$*-$(_cover)-$(_fragment).png \
		\) -compose SrcOver -composite \
		-gravity Center \
		-size %[fx:u.w]x%[fx:u.h] \
		-compose SrcOver -composite \
		$@

# Gitlab projects need a sub 200kb icon image
%-icon.png: %-$(_square)-$(_poster).png | $(require_pubdir)
	$(MAGICK) $< \
		-define png:extent=200kb \
		-resize 196x196 \
		-quality 9 \
		$@
	$(addtosync)

%-$(_cover).pdf: %-$(_cover).png %-$(_cover)-$(_text).pdf $$(geometryfile)
	$(COVERS) || exit 0
	text=$$(mktemp kapakXXXXXX.pdf)
	bg=$$(mktemp kapakXXXXXX.pdf)
	$(sourcegeometry)
	$(MAGICK) $< \
		-density $(LODPI) \
		-compress jpeg \
		-quality 50 \
		+repage \
		$${bg}
	pdftk $(filter %.pdf,$^) cat 1 output $${text}
	pdftk $${text} background $${bg} output $@
	rm $${text} $${bg}

BINDINGFRAGMENTS = $(call pattern_list,$(TARGETS),$(LAYOUTS),-$(_binding)-$(_text).pdf)
$(BINDINGFRAGMENTS): %-$(_binding)-$(_text).pdf: $(CASILEDIR)/binding.xml $$(call parse_bookid,$$@)-manifest.yml $(LUAINCLUDES) $$(subst -$(_binding)-$(_text),,$$@) | $$(TARGETLUAS_$$(call parse_bookid,$$@)) $(PROJECTLUA) $(CASILEDIR)/layout-$$(call unlocalize,$$(call parse_papersize,$$@)).lua $(LUALIBS)
	cat <<- EOF > $*.lua
		versioninfo = "$(call versioninfo,$@)"
		metadatafile = "$(filter %-manifest.yml,$^)"
		spine = "$(call spinemm,$(filter %.pdf,$^))mm"
		$(foreach LUA,$(call reverse,$|),
		SILE.require("$(basename $(LUA))"))
	EOF
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) $(SILEFLAGS) -I <(echo "CASILE.include = '$*'") $< -o $@

%-$(_fragment)-$(_front).png: %-$(_text).pdf
	$(MAGICK) -density $(HIDPI) $<[0] \
		-colorspace sRGB \
		$(call magick_fragment_front) \
		$@

%-$(_fragment)-$(_back).png: %-$(_text).pdf
	$(MAGICK) -density $(HIDPI) $<[1] \
		-colorspace sRGB \
		$(call magick_fragment_back) \
		$@

%-$(_fragment)-$(_spine).png: %-$(_text).pdf | $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) -density $(HIDPI) $<[2] \
		-colorspace sRGB \
		-crop $${spinepx}x+0+0 \
		$(call magick_fragment_spine) \
		$@

COVERFRAGMENTS = $(call pattern_list,$(TARGETS),$(PAPERSIZES),$(BINDINGS),-$(_cover)-$(_text).pdf)
$(COVERFRAGMENTS): %-$(_text).pdf: $(CASILEDIR)/cover.xml $$(call parse_bookid,$$@)-manifest.yml $(LUAINCLUDES) | $$(TARGETLUAS_$$(call parse_bookid,$$@)) $(PROJECTLUA) $(CASILEDIR)/layout-$$(call unlocalize,$$(call parse_papersize,$$@)).lua $(LUALIBS)
	cat <<- EOF > $*.lua
		versioninfo = "$(call versioninfo,$@)"
		metadatafile = "$(filter %-manifest.yml,$^)"
		$(foreach LUA,$(call reverse,$|),
		SILE.require("$(basename $(LUA))"))
	EOF
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) $(SILEFLAGS) -I <(echo "CASILE.include = '$*'") $< -o $@

%-$(_fragment).png: %-$(_text).pdf
	$(MAGICK) -density $(HIDPI) $<[0] \
		-colorspace sRGB \
		$(call magick_fragment_cover) \
		$@

PUBLISHEREMBLUM ?= $(PUBLISHERDIR)/emblum.svg
publisher_emblum.svg: $(PUBLISHEREMBLUM)
	$(call skip_if_tracked,$@)
	cp $< $@

publisher_emblum-grey.svg: $(PUBLISHEREMBLUM)
	$(call skip_if_tracked,$@)
	cp $< $@

PUBLISHERLOGO ?= $(PUBLISHERDIR)/logo.svg
publisher_logo.svg: $(PUBLISHERLOGO)
	$(call skip_if_tracked,$@)
	cp $< $@

publisher_logo-grey.svg: $(PUBLISHERLOGO)
	$(call skip_if_tracked,$@)
	cp $< $@

BINDINGIMAGES = $(call pattern_list,$(TARGETS),$(filter-out %-$(_print),$(LAYOUTS)),-$(_binding).png)
$(BINDINGIMAGES): %-$(_binding).png: $$(basename $$@)-$(_fragment)-$(_front).png $$(basename $$@)-$(_fragment)-$(_back).png $$(basename $$@)-$(_fragment)-$(_spine).png $$(call parse_bookid,$$@)-$(_barcode).png publisher_emblum.svg publisher_logo.svg $$(geometryfile)
	$(sourcegeometry)
	@$(MAGICK) -size $${imgwpx}x$${imghpx} -density $(HIDPI) \
		$(or $(and $(call git_background,$*-$(_cover)-$(_background).png),$(call git_background,$*-$(_cover)-$(_background).png) -resize $${imgwpx}x$${imghpx}!),$(call magick_background_binding)) \
		$(call magick_border) \
		\( -gravity East -size $${pagewpx}x$${pagehpx} -background none xc: $(call magick_front) -splice $${bleedpx}x \) -compose SrcOver -composite \
		\( -gravity West -size $${pagewpx}x$${pagehpx} -background none xc: $(call magick_back) -splice $${bleedpx}x \) -compose SrcOver -composite \
		\( -gravity Center -size $${spinepx}x$${pagehpx} -background none xc: $(call magick_spine) \) -compose SrcOver -composite \
		\( -gravity East $(filter %-$(_front).png,$^) -splice $${bleedpx}x -write mpr:text-front \) -compose SrcOver -composite \
		\( -gravity West $(filter %-$(_back).png,$^) -splice $${bleedpx}x -write mpr:text-front \) -compose SrcOver -composite \
		\( -gravity Center $(filter %-$(_spine).png,$^) -write mpr:text-front \) -compose SrcOver -composite \
		$(call magick_emblum,publisher_emblum.svg) \
		$(call magick_barcode,$(filter %-$(_barcode).png,$^)) \
		$(call magick_logo,publisher_logo.svg) \
		-gravity Center -size %[fx:u.w]x%[fx:u.h] \
		-compose SrcOver -composite \
		$(call magick_binding) \
		$@

%-printcolor.png: %.png
	$(MAGICK) $< $(call magick_printcolor) $@

%-$(_binding).svg: $(CASILEDIR)/binding.svg $$(basename $$@)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	ver=$(subst @,\\@,$(call versioninfo,$@))
	perl -pne "
			s#IMG#$(filter %.png,$^)#g;
			s#VER#$${ver}#g;
			s#CANVASX#$${bindingwmm}mm#g;
			s#CANVASY#$${pagehmm}mm#g;
			s#IMW#$${imgwpm}#g;
			s#IMH#$${imghpm}#g;
			s#WWW#$${bindingwpm}#g;
			s#HHH#$${pagehpm}#g;
			s#BLEED#$${bleedpm}#g;
			s#TRIM#$${trimpm}#g;
			s#CW#$${pagewpm}#g;
			s#SW#$${spinepm}#g;
		" $< > $@

%-$(_binding).pdf: %-$(_binding).svg $$(geometryfile) | $(require_pubdir)
	$(sourcegeometry)
	$(INKSCAPE) --without-gui \
		--export-dpi=$$hidpi \
		--export-area-page \
		--export-margin=$$trimmm \
		--file=$< \
		--export-pdf=$@
	$(addtosync)

# Dial down trim/bleed for non-full-bleed output so we can use the same math
NONBOUNDGEOMETRIES = $(call pattern_list,$(TARGETS),$(PAPERSIZES),$(_print) $(DISPLAYS) $(PLACARDS),-$(_geometry).sh)
$(NONBOUNDGEOMETRIES): BLEED = $(NOBLEED)
$(NONBOUNDGEOMETRIES): TRIM = $(NOTRIM)

# Some output formats don't have PDF content, but we still need to calculate geometry for them so use empty templates
EMPTYGEOMETRIES = $(call pattern_list,$(TARGETS),$(PLACARDS),-$(_print).pdf)
$(EMPTYGEOMETRIES): $(_geometry)-$$(call parse_papersize,$$@).pdf
	cp $< $@

IGNORES += $(_geometry)-*.pdf

$(_geometry)-%.pdf: $(CASILEDIR)/geometry.xml $(LUAINCLUDES)
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) $(SILEFLAGS) \
		-e "papersize = '$(call unlocalize,$*)'" \
		$< -o $@

# The assorted promotional materials don't have binding specs because they aren't bound, fake print versions of the layouts
FAKEGEOMETRIES = $(call pattern_list,$(TARGETS),$(PLACARDS),-$(_geometry).sh)
$(FAKEGEOMETRIES): %-$(_geometry).sh: %-$(_print)-$(_geometry).sh
	ln -s $< $@

# Hard coded list instead of plain pattern because make is stupid: http://stackoverflow.com/q/41694704/313192
GEOMETRIES = $(call pattern_list,$(TARGETS),$(LAYOUTS),-$(_geometry).sh)
$(GEOMETRIES): %-$(_geometry).sh: $$(call geometrybase,$$@) $$(call newgeometry,$$@)
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
	$(shell $(IDENTIFY) -density $(HIDPI) -format '
			pagewmm=%[fx:round(w/$(HIDPI)*25.399986)]
			pagewpx=%[fx:w]
			pagewpm=%[fx:round(w/$(HIDPI)*90)]
			pagewpt=%[fx:round(w/$(HIDPI)*72)]
			pagewpp=%[fx:round(w/$(HIDPI)*$(LODPI))]
			pagehmm=%[fx:round(h/$(HIDPI)*25.399986)]
			pagehpx=%[fx:h]
			pagehpm=%[fx:round(h/$(HIDPI)*90)]
			pagehpt=%[fx:round(h/$(HIDPI)*72)]
			pagehpp=%[fx:round(h/$(HIDPI)*$(LODPI))]
			pageaspect=%[fx:w/h]
		' $(filter $(_geometry)-%.pdf,$^)[0] || echo false)
	pminpx=$$(($$pagewpx<$$pagehpx?$$pagewpx:$$pagehpx))
	pmaxpx=$$(($$pagewpx>$$pagehpx?$$pagewpx:$$pagehpx))
	pagecount=$(call pagecount,$(filter %.pdf,$<))
	spinemm=$(call spinemm,$(filter %.pdf,$<))
	spinepx=$(call mmtopx,$(call spinemm,$(filter %.pdf,$<)))
	spinepm=$(call mmtopm,$(call spinemm,$(filter %.pdf,$<)))
	spinept=$(call mmtopt,$(call spinemm,$(filter %.pdf,$<)))
	fbwmm=$$(($$pagewmm+$$bleedmm))
	fbwpx=$$(($$pagewpx+$$bleedpx))
	fbwpm=$$(($$pagewpm+$$bleedpm))
	fbwpt=$$(($$pagewpt+$$bleedpt))
	ftwmm=$$(($$pagewmm+$$trimmm*2))
	ftwpx=$$(($$pagewpx+$$trimpx*2))
	ftwpm=$$(($$pagewpm+$$trimpm*2))
	ftwpt=$$(($$pagewpt+$$trimpt*2))
	fthmm=$$(($$pagehmm+$$trimmm*2))
	fthpx=$$(($$pagehpx+$$trimpx*2))
	fthpm=$$(($$pagehpm+$$trimpm*2))
	fthpt=$$(($$pagehpt+$$trimpt*2))
	bindingwmm=$$(($$pagewmm+$$spinemm+$$pagewmm))
	bindingwpx=$$(($$pagewpx+$$spinepx+$$pagewpx))
	bindingwpm=$$(($$pagewpm+$$spinepm+$$pagewpm))
	bindingwpt=$$(($$pagewpt+$$spinept+$$pagewpt))
	imgwmm=$$(($$bindingwmm+$$bleedmm*2))
	imgwpx=$$(($$bindingwpx+$$bleedpx*2))
	imgwpm=$$(($$bindingwpm+$$bleedpm*2))
	imgwpt=$$(($$bindingwpt+$$bleedpt*2))
	imghmm=$$(($$pagehmm+$$bleedmm*2))
	imghpx=$$(($$pagehpx+$$bleedpx*2))
	imghpm=$$(($$pagehpm+$$bleedpm*2))
	imghpt=$$(($$pagehpt+$$bleedpt*2))
	widelayout=$$(($${pagewpx} > $${pagehpx}))
	$(call geometry_extras)

%-$(_binding)-$(_front).png: %-$(_binding).png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< -gravity East -crop $${pagewpx}x$${pagehpx}+$${bleedpx}+0! $@

%-$(_binding)-$(_back).png: %-$(_binding).png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< -gravity West -crop $${pagewpx}x$${pagehpx}+$${bleedpx}+0! $@

%-$(_binding)-$(_spine).png: %-$(_binding).png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< -gravity Center -crop $${spinepx}x$${pagehpx}+0+0! $@

%-$(_print)-pov-$(_front).png: %-$(_print).pdf $$(geometryfile)
	$(sourcegeometry)
	$(call pagetopng,1)

%-$(_print)-pov-$(_back).png: %-$(_print).pdf $$(geometryfile)
	$(sourcegeometry)
	$(call pagetopng,$(call pagecount,$<))

%-$(_print)-pov-$(_spine).png: $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) -size $${pagewpx}x$${pagehpx} xc:none $@

%-pov-$(_front).png: %-$(_binding)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< \
		-gravity East -crop $${pagewpx}x$${pagehpx}+$${bleedpx}+0! \
		$(call magick_emulateprint) \
		$(and $(filter $(_paperback),$(call parse_binding,$@)),$(call magick_crease,0+)) \
		$(call magick_fray) \
		$@

%-pov-$(_back).png: %-$(_binding)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< \
		-gravity West -crop $${pagewpx}x$${pagehpx}+$${bleedpx}+0! \
		$(call magick_emulateprint) \
		$(and $(filter $(_paperback),$(call parse_binding,$@)),$(call magick_crease,w-)) \
		$(call magick_fray) \
		$@

%-pov-$(_spine).png: %-$(_binding)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) $< \
		-gravity Center -crop $${spinepx}x$${pagehpx}+0+0! \
		-gravity Center \
		-extent 200%x100% \
		$(call magick_emulateprint) \
		$@

BOOKSCENESINC = $(sort $(call pattern_list,$(TARGETS),$(RENDERED),.inc))
$(BOOKSCENESINC): %.inc: $$(geometryfile) %-pov-$(_front).png %-pov-$(_back).png %-pov-$(_spine).png
	$(sourcegeometry)
	cat <<- EOF > $@
		#declare FrontImg = "$(filter %-pov-$(_front).png,$^)";
		#declare BackImg = "$(filter %-pov-$(_back).png,$^)";
		#declare SpineImg = "$(filter %-pov-$(_spine).png,$^)";
		#declare BindingType = "$(call unlocalize,$(call parse_binding,$@))";
		#declare StapleCount = $(STAPLECOUNT);
		#declare CoilSpacing = $(COILSPACING);
		#declare CoilWidth = $(COILWIDTH);
		#declare CoilColor = $(COILCOLOR);
		#declare PaperWeight = $(PAPERWEIGHT);
		#declare BookThickness = $$spinemm / $$pagewmm / 2;
		#declare HalfThick = BookThickness / 2;
	EOF

BOOKSCENES = $(sort $(call pattern_list,$(TARGETS),$(RENDERED),-$(_3d).pov))
$(BOOKSCENES): %-$(_3d).pov: $$(geometryfile) %.inc
	$(sourcegeometry)
	cat <<- EOF > $@
		#declare DefaultBook = "$(filter %.inc,$^)";
		#declare Lights = $(call scale,8,2);
		#declare BookAspect = $$pagewmm / $$pagehmm;
		#declare BookThickness = $$spinemm / $$pagewmm / 2;
		#declare HalfThick = BookThickness / 2;
		#declare toMM = 1 / $$pagehmm;
	EOF

ifneq ($(strip $(TARGETS)),$(strip $(PROJECT)))
SERIESSCENES = $(sort $(call pattern_list,$(PROJECT),$(RENDERED),-$(_3d).pov))
$(SERIESSCENES): $(PROJECT)-%-$(_3d).pov: $(firstword $(TARGETS))-%-$(_3d).pov $(call pattern_list,$(TARGETS),-%.inc)
	cat <<- EOF > $@
		#include "$<"
		#declare BookCount = $(words $(TARGETS));
		#declare Books = array[BookCount] {
		$(subst $(space),$(,)
		,$(foreach INC,$(call series_sort,$(filter %.inc,$^)),"$(INC)")) }
	EOF
endif

%-$(_3d)-$(_front).png: $(CASILEDIR)/book.pov %-$(_3d).pov $(CASILEDIR)/front.pov
	$(call povray,$(filter %/book.pov,$^),$*-$(_3d).pov,$(filter %/front.pov,$^),$@,6000,8000)

%-$(_3d)-$(_back).png: $(CASILEDIR)/book.pov %-$(_3d).pov $(CASILEDIR)/back.pov
	$(call povray,$(filter %/book.pov,$^),$*-$(_3d).pov,$(filter %/back.pov,$^),$@,6000,8000)

%-$(_3d)-$(_pile).png: $(CASILEDIR)/book.pov %-$(_3d).pov $(CASILEDIR)/pile.pov
	$(call povray,$(filter %/book.pov,$^),$*-$(_3d).pov,$(filter %/pile.pov,$^),$@,8000,6000)

$(PROJECT)-%-$(_3d)-$(_montage).png: $(CASILEDIR)/book.pov $(PROJECT)-%-$(_3d).pov $(CASILEDIR)/montage.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/montage.pov,$^),$@,8000,6000)

%.jpg: %.png | $(require_pubdir)
	$(MAGICK) $< \
		$(if $(findstring $(_3d),$*),$(call pov_crop),) \
		-quality 85 \
		$@
	$(addtosync)

%.epub: %-$(_processed).md %-manifest.yml %-epub-$(_poster).jpg | $(require_pubdir)
	$(PANDOC) \
		$(PANDOCARGS) \
		--epub-cover-image=$*-epub-$(_poster).jpg \
		$*-manifest.yml \
		=($(call strip_lang) < $*-$(_processed).md) -o $@
	$(addtosync)

%.odt: %-$(_processed).md %-manifest.yml | $(require_pubdir)
	$(PANDOC) \
		$(PANDOCARGS) \
		$*-manifest.yml \
		=($(call strip_lang) < $*-$(_processed).md) -o $@
	$(addtosync)

%.docx: %-$(_processed).md %-manifest.yml | $(require_pubdir)
	$(PANDOC) \
		$(PANDOCARGS) \
		$*-manifest.yml \
		=($(call strip_lang) < $*-$(_processed).md) -o $@
	$(addtosync)

%.mobi: %.epub | $(require_pubdir)
	kindlegen $< ||:
	$(addtosync)

.PHONY: $(call pattern_list,$(TARGETS),.$(_screen))
%.$(_screen): %-$(_screen).pdf %-manifest.yml

# This is obsoleted by YAML merger, but the code might prove useful someday
# because the results are more flexible that the perl class
# %.json: $(CASILEDIR)/casile.yml $(METADATA) $$(wildcard $(PROJECT).yml $$*.yml)
# 	jq -s 'reduce .[] as $$item({}; . + $$item)' $(foreach YAML,$^,<(yaml2json $(YAML))) > $@

MANIFESTS = $(call pattern_list,$(TARGETS),-manifest.yml)
$(MANIFESTS): %-manifest.yml: $(CASILEDIR)/casile.yml $(METADATA) $(PROJECTYAML) $$(TARGETYAMLS_$$*) | $(require_pubdir)
	perl -MYAML::Merge::Simple=merge_files -MYAML -E 'say Dump merge_files(@ARGV)' $(filter %.yml,$^) |
		sed -e 's/~$$/nil/g;/^--- |/d;$$a...' \
			-e '/\(own\|next\)cloudshare: [^"]/s/: \(.*\)$$/: "\1"/' > $@
	$(addtosync)

INTERMEDIATES += *-url.*

%-url.png: %-url.svg
	$(MAGICK) $< \
		-bordercolor white -border 10x10 \
		-bordercolor black -border 4x4 \
		$@

%-url.svg:
	zint \
			--direct \
			--filetype=svg \
			--scale=10 \
			--barcode=58 \
			--data=$(call urlinfo,$@) \
		> $@

INTERMEDIATES += *-$(_barcode).*

%-$(_barcode).svg: %-manifest.yml
	zint --direct \
			--filetype=svg \
			--scale=5 \
			--barcode=69 \
			--height=30 \
			--data=$(shell $(CASILEDIR)/bin/isbn_format.py $< paperback) |\
		sed -e 's/Helvetica\( Regular\)\?/TeX Gyre Heros/g' \
		> $@

%-$(_barcode).png: %-$(_barcode).svg
	$(MAGICK) $< \
		-bordercolor white -border 10 \
		-font Hack-Regular -pointsize 36 \
		label:"ISBN $(shell $(CASILEDIR)/bin/isbn_format.py $*-manifest.yml paperback mask)" +swap -gravity Center -append \
		-bordercolor white -border 0x10 \
		-resize $(call scale,1200)x \
		$@
	if [[ $(shell $(CASILEDIR)/bin/isbn_format.py $*-manifest.yml paperback) == 9786056644504 ]]; then
		$(MAGICK) $@ \
			-stroke red \
			-strokewidth $(call scale,10) \
			-draw 'line 0,0,%[fx:w],%[fx:h]' \
			$@
	fi

.PHONY: stats
STATSTARGETS = $(call pattern_list,$(TARGETS),-stats)
stats: $(STATSTARGETS) $(and $(CI),init)

.PHONY: $(STATSTARGETS)
$(STATSTARGETS): %-stats:
	stats.zsh $* $(STATSMONTHS)

%-$(_verses).json: %-$(_processed).md
	# cd $(CASILEDIR)
	# yarn add bible-passage-reference-parser
	$(if $(HEAD),head -n$(HEAD),cat) $< |
		extract_references.js > $@

%-$(_verses)-$(_sorted).json: %-$(_verses).json
	jq 'sort_by(.seq)' $< > $@

.PHONY: normalize_references
normalize_references: $(MARKDOWNSOURCES)
	$(call munge,$^,normalize_references.js,Normalize verse references using BCV parser)

.PHONY: normalize
normalize: normalize_lua normalize_markdown normalize_references

split_chapters:
	$(if $(MARKDOWNSOURCES),,exit 0)
	$(foreach SOURCE,$(MARKDOWNSOURCES),$(call split_chapters,$(SOURCE)))

watch:
	git ls-files --recurse-submodules |
		entr $(ENTRFLAGS) make DRAFT=true LAZY=true $(WATCHARGS)

diff:
	git diff --color=always --ignore-submodules --no-ext-diff
	git submodule foreach git diff --color=always --no-ext-diff
