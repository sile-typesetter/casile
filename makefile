SHELL := zsh
.SHELLFLAGS = +o nomatch -e -c

# Initial setup, environment dependent
PROJECTDIR := $(shell cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd)
CASILEDIR := $(shell cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd)
PROJECT := $(notdir $(shell git worktree list | head -n1 | awk '{print $$1}'))
PUBDIR := $(PROJECTDIR)/pub

# Set the language if not otherwise set
LANGUAGE ?= en
include $(CASILEDIR)/makefile-$(LANGUAGE)

# Find stuff to build that has both a YML and a MD component
TARGETS ?= $(filter $(basename $(wildcard *.md)),$(basename $(wildcard *.yml)))

# List of figures that need building prior to content
FIGURES ?=

# Default output formats and parameters (often overridden)
FORMATS ?= pdf epub
BLEED ?= 3
TRIM ?= 10
PAPERWEIGHT ?= 60
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

# List of supported outputs
BINDINGS = a4ciltli royaloctavo octavo halfletter a5trim cep
DISPLAYS = a4 a5 app ekran
PLACARDS = kare genis bant epub
PAPERSIZES = $(BINDINGS) $(DISPLAYS) $(PLACARDS)

# Default to running multiple jobs
JOBS := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)
MAKEFLAGS = "-j $(JOBS)"

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
# List of exta YAML meta data files to splice into each book
METADATA ?=

# Extra lua files to include before processing documents
LUAINCLUDES += .casile.lua

# Primary libraries to include (loaded in reverse order so this one is first)
LUALIBS += $(CASILEDIR)/casile.lua

# Tell sile to look here for stuff before it’s internal stuff
SILEPATH += $(CASILEDIR)

# Extra arguments to pass to Pandow
PANDOCARGS ?=

# Figure out if we're being run from
ATOM ?= $(shell env | grep -q ATOM_ && echo true || echo false)
ifeq ($(ATOM),true)
DRAFT = true
endif

# Set default document class
DOCUMENTCLASS ?= cabook
DOCUMENTOPTIONS ?=

# Default template for setting up Gitlab CI runners
CITEMPLATE ?= $(CASILEDIR)/travis.yml
CICONFIG ?= .travis.yml

# Utility variables for later, http://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
, := ,
space :=
space +=
$(space) :=
$(space) +=

# Utility functions for simplifying per-project makefiles
depend_font = fc-match "$1" family | grep -qx "$1"

# Assorted utility functions for juggling information about books
pagecount = $(shell pdfinfo $1 | awk '$$1 == "Pages:" {print $$2}' || echo 0)
pagew = $(shell pdfinfo $1 | awk '$$1$$2 == "Pagesize:" {print $$3}' || echo 0)
pageh = $(shell pdfinfo $1 | awk '$$1$$2 == "Pagesize:" {print $$5}' || echo 0)
spinemm = $(shell echo "$(call pagecount,$1) * $(PAPERWEIGHT) / 1000 + 1 " | bc)
mmtopx = $(shell echo "$1 * $(HIDPI) * 0.0393701 / 1" | bc)
mmtopm = $(shell echo "$1 * 96 * .0393701 / 1" | bc)
mmtopt = $(shell echo "$1 * 2.83465 / 1" | bc)
width = $(shell $(IDENTIFY) -density $(HIDPI) -format %[fx:w] $1)
height = $(shell $(IDENTIFY) -density $(HIDPI) -format %[fx:h] $1)
parse_layout = $(filter $(PAPERSIZES),$(subst -, ,$(basename $1)))
strip_layout = $(filter-out $1,$(foreach PAPERSIZE,$(PAPERSIZES),$(subst -$(PAPERSIZE)-,-,$1)))
parse_bookid = $(firstword $(subst -, ,$(basename $1)))
series_sort = $(shell PROJECT=$(PROJECT) SORTORDER=$(SORTORDER) $(CASILEDIR)/bin/series_sort.lua $1)

# Utility to modify recursive variables, see http://stackoverflow.com/a/36863261/313192
prepend = $(eval $(1) = $(2)$(value $(1)))
append = $(eval $(1) = $(value $(1))$(2))

reverse = $(if $(wordlist 2,2,$(1)),$(call reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)),$(1))

# Making lists of possible targets is tedious syntax, but just using pattern
# rules means the targets are not extendable. By hard coding lists of possible
# targets we get a lot more flexibility. This makes those lists easier to write.
pattern_list = $(if $(and $(1),$(2)),,$(foreach A,$(1),$(A)))$(if $(and $(2),$(3)),,$(foreach A,$(1),$(foreach B,$(2),$(A)$(B))))$(if $(and $(3),$(4)),,$(foreach A,$(1),$(foreach B,$(2),$(foreach C,$(3),$(A)-$(B)$(C)))))$(if $(and $(4),$(5)),,$(foreach A,$(1),$(foreach B,$(2),$(foreach C,$(3),$(foreach D,$(4),$(A)-$(B)-$(C)$(D))))))

ifeq ($(DRAFT),true)
$(MAKECMDGOALS): force
endif

# For watch targets, treat exta parameters as things to pass to the next make
ifeq (watch,$(firstword $(MAKECMDGOALS)))
  WATCHARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(WATCHARGS):;@:)
endif

export PATH := $(CASILEDIR)/bin:$(PATH)
export HOSTNAME := $(shell hostname)
export PROJECT := $(PROJECT)

ifeq ($(DEBUG),true)
SILE = /home/caleb/projects/sile/sile
.SHELLFLAGS = +o nomatch -e -x -c
endif

# Pass debug tags on to SILE
ifdef DEBUGTAGS
SILEFLAGS += -d $(subst $( ),$(,),$(DEBUGTAGS))
endif

.ONESHELL:
.SECONDEXPANSION:
.SECONDARY:
.PRECIOUS: %.pdf %.sil %.toc %.dat %.inc
.DELETE_ON_ERROR:

.PHONY: books
books: $(TARGETS)

ifeq ($(MAKECMDGOALS),ci)
CI ?= 1
endif

.PHONY: ci
ci: init debug books renderings promotionals sync_post stats

.PHONY: renderings
renderings: $(call pattern_list,$(TARGETS),$(PUBLAYOUT),$(RENDERINGS),.jpg)

.PHONY: promotionals
promotionals: $(call pattern_list,$(TARGETS),$(PLACARDS),-pankart.jpg) $(call pattern_list,$(TARGETS),-icon.png)

# If a series, add some extra dependencies to convenience builds
ifneq ($(words $(TARGETS)),1)
promotionals: series_promotionals
renderings: series_renderings
endif

.PHONY: series_promotionals
series_promotionals: $(PROJECT)-epub-pankart-montaj.jpg $(PROJECT)-kare-pankart-montaj.jpg

.PHONY: series_renderings
series_renderings: $(PROJECT)-$(PUBLAYOUT)-3b-montaj.jpg

$(PROJECT)-%-pankart-montaj.png: $(call pattern_list,$(TARGETS)-%-pankart.png) $(firstword $(TARGETS))-%-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) montage \
		$(filter %.png,$^) \
		-geometry $${coverwpm}x$${coverhpm}+0+0 \
		$@

.PHONY: clean
clean: $(and $(CI),init)
	git clean -xf

.PHONY: debug
debug:
	@echo ALLTAGS: $(ALLTAGS)
	@echo BRANCH: $(BRANCH)
	@echo CASILEDIR: $(CASILEDIR)
	@echo CICONFIG: $(CICONFIG)
	@echo CITEMPLATE: $(CITEMPLATE)
	@echo DEBUG: $(DEBUG)
	@echo DEBUGTAGS: $(DEBUGTAGS)
	@echo DIFF: $(DIFF)
	@echo DRAFT: $(DRAFT)
	@echo FIGURES: $(FIGURES)
	@echo FORMATS: $(FORMATS)
	@echo INPUTDIR: $(INPUTDIR)
	@echo LAYOUTS: $(LAYOUTS)
	@echo LUAINCLUDES: $(LUAINCLUDES)
	@echo LUALIBS: $(LUALIBS)
	@echo M4MACROS: $(M4MACROS)
	@echo MAKECMDGOALS: $(MAKECMDGOALS)
	@echo MAKEFILE_LIST: $(MAKEFILE_LIST)
	@echo METADATA: $(METADATA)
	@echo OUTPUTDIR: $(OUTPUTDIR)
	@echo PANDOCARGS: $(PANDOCARGS)
	@echo PARENT: $(PARENT)
	@echo PROJECT: $(PROJECT)
	@echo SILE: $(SILE)
	@echo SILEFLAGS: $(SILEFLAGS)
	@echo SILEPATH: $(SILEPATH)
	@echo TAG: $(TAG)
	@echo TAGNAME: $(TAGNAME)
	@echo TARGETS: $(TARGETS)
	@echo urlinfo: $(call urlinfo,$(PROJECT))
	@echo versioninfo: $(call versioninfo,$(PROJECT))

.PHONY: force
force: ;

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.PHONY: $(TARGETS)
$(TARGETS): $(foreach FORMAT,$(FORMATS),$$@.$(FORMAT))

.PHONY: figures
figures: $(FIGURES)

.PHONY: init
init: check_dependencies init_toolkits update_repository
	$(and $(OUTPUTDIR),mkdir -p $(OUTPUTDIR))
	$(and $(PUBDIR),mkdir -p $(PUBDIR))

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

.PHONY: init_casile
init_casile: time_warp_casile
	cd $(CASILEDIR) && yarn install

.PHONY: update_casile
update_casile: init_casile
	git submodule update --init --remote -- $(CASILEDIR)
	$(call time_warp,$(CASILEDIR))
	cd $(CASILEDIR) && yarn upgrade

.PHONY: upgrade_repository
upgrade_repository: upgrade_casile update_toolkits

.PHONY: upgrade_casile
upgrade_casile: $(CASILEDIR)/upgrade.sed
	$(call find_and_munge,*.lua,sed -f $<,Replace old name and functions with new namespaces)
	$(call find_and_munge,*.yml,sed -e 's/owncloudshare/nextcloudshare/g',Update YAML key names)

.PHONY: update_repository
update_repository:
	git fetch --all --prune --tags

.editorconfig: $(CASILEDIR)/editorconfig
	$(call skip_if_tracked,$@)
	cp $< $@

.gitignore: $(CASILEDIR)/gitignore $(MAKEFILE_LIST)
	$(call skip_if_tracked,$@)
	cp $< $@
	$(foreach TARGET,$(TARGETS),$(foreach PAPERSIZE,$(PAPERSIZES),echo '$(TARGET)-$(PAPERSIZE)*' >> $@;))
	$(foreach TARGET,$(TARGETS),$(foreach FORMAT,$(FORMATS),echo '$(TARGET).$(FORMAT)' >> $@;))
	find -path "$(PUBDIR)/*" -type f -exec basename {} \; >> $@

$(CICONFIG): $(CITEMPLATE)
	cat $< | \
		$(call ci_setup) | \
		sponge $@

define ci_setup
	cat -
endef

# Pass or fail target showing whether the CI config is up to date
.PHONY: $(CICONFIG)_current
$(CICONFIG)_current: $(CICONFIG)
	git update-index --refresh
	git diff-files --quiet -- $<

define addtosync =
	$(DRAFT) && rm -f $(PUBDIR)/$@ || ln -f $@ $(PUBDIR)/$@
endef

# If building in draft mode, scale resolutions down for quick builds
define scale =
$(strip $(shell $(DRAFT) && echo $(if $2,$2,"($1 + $(SCALE) - 1) / $(SCALE)" | bc) || echo $1))
endef

# Reset file timestamps to git history to avoid un-necessary builds
.PHONY: time_warp time_warp_casile
time_warp: time_warp_casile
	$(call time_warp,$(PROJECTDIR))

time_warp_casile:
	$(call time_warp,$(CASILEDIR))

define time_warp
	cd $1
	git update-index --refresh --ignore-submodules ||:
	git diff-index --quiet --cached HEAD
	git ls-files |
		while read file; do
			ts=$$(git log -n1 --pretty=format:%cI -- $$file)
			git diff-files --quiet -- $$file || continue
			touch -d "$$ts" -- $$file
		done
endef

.PHONY: sync_pre
sync_pre: $(and $(CI),clean)
	$(call pre_sync)
	rsync -ctv $(INPUTDIR)/* $(PROJECTDIR)/ ||:

.PHONY: sync_post
sync_post: $(and $(CI),books)
	$(if $(OUTPUTDIR),,exit 0)
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

VIRTUALPDFS = $(call pattern_list,$(TARGETS),.pdf)
.PHONY: $(VIRTUALPDFS)
$(VIRTUALPDFS): %.pdf: $(call pattern_list,$$*,$(LAYOUTS),.pdf) $(call pattern_list,$$*,$(LAYOUTS),$(RESOURCES),.pdf) ;

coverpreq = $(if $(filter true,$(COVERS)),$(if $(filter $(BINDINGS),$(call parse_layout,$1)),,%-kapak.pdf),)

# Order is important here, these are included in reverse order so early supercedes late
onpaperlibs = $(wildcard $(call parse_bookid,$1).lua) $(wildcard $(PROJECT).lua) $(CASILEDIR)/layout-$(call parse_layout,$1).lua $(LUALIBS)

FULLPDFS = $(call pattern_list,$(TARGETS),$(filter-out $(PLACARDS),$(PAPERSIZES)),.pdf)
$(FULLPDFS): PANDOCARGS += --filter=$(CASILEDIR)/svg2pdf.py
$(FULLPDFS): %.pdf: %.sil $$(call coverpreq,$$@) .casile.lua $$(call onpaperlibs,$$@) $(LUAINCLUDES)
	$(call skip_if_lazy,$@)
	$(DIFF) && sed -e 's/\\\././g;s/\\\*/*/g' -i $< ||:
	# If in draft mode don't rebuild for TOC and do output debug info, otherwise
	# account for TOC issue: https://github.com/simoncozens/sile/issues/230
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
	if $(COVERS) && [[ -f $*-kapak.pdf ]]; then
		pdftk $@ dump_data_utf8 output $*.dat
		pdftk C=$*-kapak.pdf B=$@ cat C1 B2-end output $*.tmp.pdf
		pdftk $*.tmp.pdf update_info_utf8 $*.dat output $@
		rm $*.tmp.pdf
	fi
	$(addtosync)

FULLSILS = $(call pattern_list,$(TARGETS),$(PAPERSIZES),.sil)
$(FULLSILS): %.sil: $$(call parse_bookid,$$@)-processed.md $$(call parse_bookid,$$@)-manifest.yml $$(call parse_bookid,$$@)-ayetler-sorted.json $$(call parse_bookid,$$@)-url.png $(CASILEDIR)/template.sil | $$(call onpaperlibs,$$@)
	$(PANDOC) --standalone \
			$(PANDOCARGS) \
			--wrap=preserve \
			-V documentclass="$(DOCUMENTCLASS)" \
			$(if $(DOCUMENTOPTIONS),-V classoptions="$(DOCUMENTOPTIONS)",) \
			-V metadatafile="$(filter %-manifest.yml,$^)" \
			-V versesfile="$(filter %-ayetler-sorted.json,$^)" \
			-V versioninfo="$(call versioninfo,$@)" \
			-V urlinfo="$(call urlinfo,$@)" \
			-V qrimg="./$(filter %-url.png,$^)" \
			$(foreach LUA,$(filter %.lua,$|), -V script=$(basename $(LUA))) \
			--template=$(filter %.sil,$^) \
			--to=sile \
			$(filter %-manifest.yml,$^) <( $(call pre_sile_markdown_hook) < $< ) |
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

preprocess_macros = $(CASILEDIR)/casile.m4 $(M4MACROS) $(wildcard $(PROJECT).m4) $(wildcard $1.m4)
%-processed.md: %.md $$(call preprocess_macros,$$*) $$(wildcard $$*-bolumler/*.md) | figures
	if $(DIFF) && $(if $(PARENT),true,false); then
		branch2criticmark.zsh $(PARENT) $<
	else
		m4 $(filter %.m4,$^) $<
	fi |
		renumber_footnotes.pl |
		$(call criticToSile) |
		$(call md_cleanup) |
		$(call markdown_hook) > $@

%-ciftyonlu.pdf: %.pdf
	pdfbook --short-edge --suffix ciftyonlu --noautoscale true -- $< ||:

%-kirpilmis.pdf: %.pdf
	b=$$(echo "$(TRIM) * 283.465" | bc)
	w=$$(echo "$(call pagew,$<) * 100 - $$b * 2" | bc)
	h=$$(echo "$(call pageh,$<) * 100 - $$b * 2" | bc)
	podofobox $< $@ media $$b $$b $$w $$h
	$(addtosync)

define versioninfo
$(shell
	echo -en "$(call parse_bookid,$1)@"
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
		grep -f <(git ls-files | sed -e 's/$$/$$/;s#^#./#') |
		while read f; do
			grep -q "esyscmd.*cat.* $$(basename $$f)-bolumler/" $$f && continue # skip compilations that are mostly M4
			git diff-files --quiet -- $$f || exit 1 # die if this file has uncommitted changes
			$2 < $$f | sponge $$f
			git add -- $$f
		done
	git diff-index --quiet --cached HEAD || git ci -m "[auto] $3"
endef

.PHONY: lua_cleanup
lua_cleanup:
	$(call find_and_munge,*.lua,sed -e 's/function */function /g',Normalize Lua coding style)

.PHONY: md_cleanup
md_cleanup:
	$(call find_and_munge,*.md,msword_escapes.pl,Fixup bad MS word typing habits that Pandoc tries to preserve)
	$(call find_and_munge,*.md,lazy_quotes.pl,Replace lazy double single quotes with real doubles)
	$(call find_and_munge,*.md,smart_quotes.pl,Replace straight quotation marks with typographic variants)
	$(call find_and_munge,*.md,figure_dash.pl,Convert hyphens between numbers to figure dashes)
	$(call find_and_munge,*.md,unicode_symbols.pl,Replace lazy ASCI shortcuts with Unicode symbols)
	$(call find_and_munge,*.md,italic_reorder.pl,Fixup italics around names and parethesised translations)
	$(call find_and_munge,*.md,$(PANDOC) --atx-headers --wrap=preserve --to=markdown,Normalize and tidy Markdown syntax using Pandoc)
	#(call find_and_munge,*.md,reorder_punctuation.pl,Cleanup punctuation mark order, footnote markers, etc.)
	#(call find_and_munge,*.md,apostrophize_names.pl,Use apostrophes when adding suffixes to proper names)

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

define criticToSile
	sed -e 's#{==#\\criticHighlight{#g' -e 's#==}#}#g' \
		-e 's#{>>#\\criticComment{#g'   -e 's#<<}#}#g' \
		-e 's#{++#\\criticAdd{#g'       -e 's#++}#}#g' \
		-e 's#{--#\\criticDel{#g'       -e 's#--}#}#g'
endef

define strip_lang
	cat |
		perl -pne "
			s/\\\lang.{1,3}\{([^\}]+)}/\1/g
		"
endef

define markdown_hook
	cat -
endef

define pre_sile_markdown_hook
	cat -
endef

define sile_hook
	cat -
endef

%.toc: %.pdf ;

%.sil.tov: %.pdf ;

APPTARGETS = $(call pattern_list,$(TARGETS),.app)
.PHONY: $(APPTARGETS)
$(APPTARGETS): %.app: %-app.info promotionals

WEBTARGETS = $(call pattern_list,$(TARGETS),.web)
.PHONY: $(WEBTARGETS)
$(WEBTARGETS): %.web: %-manifest.yml %-epub-pankart.jpg promotionals renderings

%-app.info: %-app.toc %-app.pdf %-manifest.yml
	$(CASILEDIR)/bin/toc2breaks.lua $* $(filter %-app.toc,$^) $(filter %-manifest.yml,$^) $@ |
		while read range out; do
			pdftk $(filter %-app.pdf,$^) cat $$range output $$out
			ln -f $$out $(PUBDIR)/$$out
		done
	$(addtosync)

issue.info:
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

define skip_if_tracked
	git ls-files --error-unmatch -- $1 2>/dev/null && exit 0 ||:
endef

define skip_if_lazy
	$(LAZY) && $(if $(filter $1,$(MAKECMDGOALS)),false,true) && test -f $1 && { touch $1; exit 0 } ||:
endef

COVERBACKGROUNDS = $(call pattern_list,$(TARGETS),$(filter-out $(BINDINGS),$(PAPERSIZES)),-kapak-zemin.png)
git_background = $(shell git ls-files -- $(call strip_layout,$1) 2>/dev/null)
$(COVERBACKGROUNDS): %-kapak-zemin.png: $$(call git_background,$$@) $$(subst -kapak-zemin.png,-geometry.zsh,$$@)
	source $(filter %-geometry.zsh,$^)
	$(if $(filter %.png,$(call git_background,$@)),true,false) && $(MAGICK) $(filter %.png,$^) \
		-gravity $(COVERGRAVITY) \
		-extent  "%[fx:w/h>=$${coveraspect}?h*$${coveraspect}:w]x" \
		-extent "x%[fx:w/h<=$${coveraspect}?w/$${coveraspect}:h]" \
		-resize $${coverwpx}x$${coverhpx} \
		$(call magick_zeminfilter) \
		$@ ||:
	$(if $(filter %.png,$(call git_background,$@)),false,true) && $(MAGICK) \
		-size $${coverwpx}x$${coverhpx}^ $(call magick_zemin_kapak) -composite \
		$@ ||:

%-pankart.png: %-kapak.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< \
		-resize $${coverwpp}x$${coverhpp}^ \
		$(and $(filter epub,$(call parse_layout,$@)),-resize 1000x1600^) \
		$@

%-kapak.png: %-kapak-zemin.png %-fragman-kapak.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	@$(MAGICK) $< \
		\( -background none \
			-gravity center \
			-size $${coverwpx}x$${coverhpx} \
			xc: \
			$(call magick_kapak) \
		\) -compose overlay -composite \
		\( \
			-gravity center \
			$(word 2,$^) \
			-write mpr:metin-kapak \
		\) -compose over -composite \
		-gravity center \
		-size %[fx:u.w]x%[fx:u.h] \
		-composite \
		$@

# Gitlab projects need a sub 200kb icon image
%-icon.png: %-kare-pankart.png
	$(MAGICK) $< \
		-define png:extent=200kb \
		-resize 196x196 \
		-quality 9 \
		$@
	$(addtosync)

define magick_kapak
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
		\) -composite
endef

%-kapak.pdf: %-kapak.png %-kapak-metin.pdf %-geometry.zsh
	$(COVERS) || exit 0
	metin=$$(mktemp kapakXXXXXX.pdf)
	bg=$$(mktemp kapakXXXXXX.pdf)
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< \
		-density $(LODPI) \
		-compress jpeg \
		-quality 50 \
		+repage \
		$$bg
	pdftk $(filter %.pdf,$^) cat 1 output $$metin
	pdftk $$metin background $$bg output $@
	rm $$metin $$bg

BINDINGFRAGMENTS = $(call pattern_list,$(TARGETS),$(filter $(BINDINGS),$(PAPERSIZES)),-cilt-metin.pdf)
$(BINDINGFRAGMENTS): %-cilt-metin.pdf: $(CASILEDIR)/cilt.xml $$(call parse_bookid,$$@)-manifest.yml $(LUAINCLUDES) $$(subst -cilt-metin,,$$@) | $$(wildcard $$(call parse_bookid,$$@).lua) $$(wildcard $(PROJECT).lua) $(CASILEDIR)/layout-$$(call parse_layout,$$@).lua $(LUALIBS)
	cat <<- EOF > $*.lua
		versioninfo = "$(call versioninfo,$*)"
		metadatafile = "$(filter %-manifest.yml,$^)"
		spine = "$(call spinemm,$(filter %.pdf,$^))mm"
		$(foreach LUA,$(call reverse,$|),
		SILE.require("$(basename $(LUA))"))
	EOF
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) $(SILEFLAGS) -I <(echo "CASILE.include = '$*'") $< -o $@

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
		$(call magick_fragman_sirt) \
		-composite $@

COVERFRAGMENTS = $(call pattern_list,$(TARGETS),$(filter-out $(BINDINGS),$(PAPERSIZES)),-kapak-metin.pdf)
$(COVERFRAGMENTS): %-kapak-metin.pdf: $(CASILEDIR)/kapak.xml $$(call parse_bookid,$$@)-manifest.yml $(LUAINCLUDES) | $$(wildcard $$(call parse_bookid,$$@).lua) $$(wildcard $(PROJECT).lua) $(CASILEDIR)/layout-$$(call parse_layout,$$@).lua $(LUALIBS)
	cat <<- EOF > $*.lua
		versioninfo = "$(call versioninfo,$(call parse_bookid,$@))"
		metadatafile = "$(filter %-manifest.yml,$^)"
		$(foreach LUA,$(call reverse,$|),
		SILE.require("$(basename $(LUA))"))
	EOF
	$(eval export SILE_PATH = $(subst $( ),;,$(SILEPATH)))
	$(SILE) $(SILEFLAGS) -I <(echo "CASILE.include = '$*'") $< -o $@

%-fragman-kapak.png: %-kapak-metin.pdf
	$(MAGICK) -density $(HIDPI) $<[0] \
		$(call magick_fragman_kapak) \
		-composite $@

BINDINGIMAGES = $(call pattern_list,$(TARGETS),$(BINDINGS),-cilt.png)
$(BINDINGIMAGES): %-cilt.png: %-fragman-on.png %-fragman-arka.png %-fragman-sirt.png $$(call strip_layout,$$*-barkod.png) $(AVADANLIKDIR)/vc_sembol_renkli.svg $(AVADANLIKDIR)/vc_logo_renkli.svg %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	@$(MAGICK) -size $${imgwpx}x$${imghpx} -density $(HIDPI) \
		$(or $(and $(call git_background,$*-kapak-zemin.png),$(call git_background,$*-kapak-zemin.png) -resize $${imgwpx}x$${imghpx}!),$(call magick_zemin_cilt)) \
		$(call magick_kenar) \
		\( -gravity east -size $${coverwpx}x$${coverhpx} -background none xc: $(call magick_on) -splice $${bleedpx}x \) -compose overlay -composite \
		\( -gravity west -size $${coverwpx}x$${coverhpx} -background none xc: $(call magick_arka) -splice $${bleedpx}x \) -compose overlay -composite \
		\( -gravity center -size $${spinepx}x$${coverhpx} -background none xc: $(call magick_sirt) \) -compose overlay -composite \
		\( -gravity east $(word 1,$^) -splice $${bleedpx}x -write mpr:metin-on \) -compose over -composite \
		\( -gravity west $(word 2,$^) -splice $${bleedpx}x -write mpr:metin-arka \) -compose over -composite \
		\( -gravity center $(word 3,$^) -write mpr:metin-sirt \) -compose over -composite \
		$(call magick_sembol,$(word 5,$^))\
		$(call magick_barkod,$(word 4,$^)) \
		$(call magick_logo,$(word 6,$^)) \
		-gravity center -size %[fx:u.w]x%[fx:u.h] \
		-composite \
		$(call magick_cilt) \
		$@

%-cilt-printcolor.png: %-cilt.png
	$(MAGICK) $< $(call magick_printcolor) $@

%-cilt.svg: $(CASILEDIR)/cilt.svg %-cilt-printcolor.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	ver=$(subst @,\\@,$(call versioninfo,$@))
	perl -pne "
			s#IMG#$(filter %.png,$^)#g;
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

%-cilt.pdf:	%-cilt.svg %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(INKSCAPE) --without-gui \
		--export-dpi=$$hidpi \
		--export-area-page \
		--export-margin=$$trimmm \
		--file=$< \
		--export-pdf=$@
	$(addtosync)

newgeometry = $(shell grep -sq hidpi=$(HIDPI) $1 || echo force)
geometrybase = $(if $(filter $(BINDINGS),$(call parse_layout,$1)),$1.pdf $1-cilt-metin.pdf,$1-kapak-metin.pdf)

# Dial down trim/bleed for non-full-bleed output so we can use the same math
NONBOUNDGEOMETRIES = $(call pattern_list,$(TARGETS),$(filter-out $(CILTLI),$(PAPERSIZES)),-geometry.zsh)
$(NONBOUNDGEOMETRIES): BLEED = 0
$(NONBOUNDGEOMETRIES): TRIM = 0

# Hard coded list instead of plain pattern because make is stupid: http://stackoverflow.com/q/41694704/313192
GEOMETRIES = $(call pattern_list,$(TARGETS),$(PAPERSIZES),-geometry.zsh)
$(GEOMETRIES): %-geometry.zsh: $$(call newgeometry,$$@) $$(call geometrybase,$$*)
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
		' $(lastword $(filter %.pdf,$^))[0] || echo false)
	spinemm=$(call spinemm,$(firstword $(filter %.pdf,$^)))
	spinepx=$(call mmtopx,$(call spinemm,$(firstword $(filter %.pdf,$^))))
	spinepm=$(call mmtopm,$(call spinemm,$(firstword $(filter %.pdf,$^))))
	spinept=$(call mmtopt,$(call spinemm,$(firstword $(filter %.pdf,$^))))
	fbwmm=$$(($$coverwmm+$$bleedmm))
	fbwpx=$$(($$coverwpx+$$bleedpx))
	fbwpm=$$(($$coverwpm+$$bleedpm))
	fbwpt=$$(($$coverwpt+$$bleedpt))
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

define magick_zemin_kapak
	$(call magick_zemin)
endef

define magick_zemin_cilt
	$(call magick_zemin)
endef

define magick_zemin
	xc:darkgray
endef

define magick_zeminfilter
	-normalize
endef

define magick_kenar
	-fill none -strokewidth 1 \
	$(shell $(DRAFT) && echo -n '-stroke gray50' || echo -n '-stroke transparent') \
	-draw "rectangle $$bleedpx,$$bleedpx %[fx:w-$$bleedpx],%[fx:h-$$bleedpx]" \
	-draw "rectangle %[fx:$$bleedpx+$$coverwpx],$$bleedpx %[fx:w-$$bleedpx-$$coverwpx],%[fx:h-$$bleedpx]"
endef

define magick_sembol
	-gravity south \
	\( -background none \
		$1 \
		-resize "%[fx:min($$spinepx/100*(100-$$spinemm),$(call mmtopx,12))]"x \
		$(call magick_sembol_filter) \
		-splice x%[fx:$(call mmtopx,5)+$$bleedpx] \
	\) -compose over -composite
endef

define magick_sembol_filter
endef

define magick_logo
	-gravity southwest \
	\( -background none \
		$(AVADANLIKDIR)/vc_logo_renksiz.svg \
		-channel RGB -negate \
		-level 20%,60%!  \
		-resize $(call mmtopx,30)x \
		-splice %[fx:$$bleedpx+$$coverwpx*15/100]x%[fx:$$bleedpx+$(call mmtopx,10)] \
	\) -compose screen -composite
endef

define magick_barkod
	-gravity southeast \
	\( -background white \
		$1 \
		-resize $(call mmtopx,30)x \
		-bordercolor white \
		-border $(call mmtopx,2) \
		-background none \
		-splice %[fx:$$bleedpx+$$coverwpx+$$spinepx+$$coverwpx*15/100]x%[fx:$$bleedpx+$(call mmtopx,10)] \
	\) -compose over -composite
endef

define magick_crease
	-stroke gray95 -strokewidth $(call mmtopx,0.5) \
	\( -size $${coverwpx}x$${coverhpx} -background none xc: -draw "line %[fx:$1$(call mmtopx,8)],0 %[fx:$1$(call mmtopx,8)],$${coverhpx}" -blur 0x$(call scale,$(call mmtopx,0.2)) -level 0x40%! \) \
	-compose modulusadd -composite
endef

define magick_fray
	\( +clone \
		-alpha extract \
		-virtual-pixel black \
		-spread 2 \
		-blur 0x4 \
		-threshold 20% \
		-spread 2 \
		-blur 0x0.7 \
	\) -alpha off -compose copyopacity -composite
endef

define magick_emulateprint
	+level 0%,95%,1.6 \
	-modulate 100,75
endef

define magick_printcolor
	-modulate 100,140 \
	+level 0%,110%,0.7
endef

%-cilt-on.png: %-cilt.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< -gravity east -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! $@

%-cilt-arka.png: %-cilt.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< -gravity west -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! $@

%-cilt-sirt.png: %-cilt.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< -gravity center -crop $${spinepx}x$${coverhpx}+0+0! $@

%-pov-on.png: %-cilt-printcolor.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< \
		-gravity east -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! \
		$(call magick_emulateprint) \
		$(call magick_crease,0+) \
		$(call magick_fray) \
		$@

%-pov-arka.png: %-cilt-printcolor.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< \
		-gravity west -crop $${coverwpx}x$${coverhpx}+$${bleedpx}+0! \
		$(call magick_emulateprint) \
		$(call magick_crease,w-) \
		$(call magick_fray) \
		$@

%-pov-sirt.png: %-cilt-printcolor.png %-geometry.zsh
	source $(filter %-geometry.zsh,$^)
	$(MAGICK) $< \
		-gravity center -crop $${spinepx}x$${coverhpx}+0+0! \
		-gravity center \
		-extent 200%x100% \
		$(call magick_emulateprint) \
		$@

povtextures = %-pov-on.png %-pov-arka.png %-pov-sirt.png

BOOKSCENESINC = $(call pattern_list,$(TARGETS),$(LAYOUTS),.inc)
$(BOOKSCENESINC): %.inc: %-geometry.zsh | $(povtextures)
	source $(filter %-geometry.zsh,$^)
	cat <<- EOF > $@
		#declare CoverWMM = $$coverwmm;
		#declare CoverHMM = $$coverhmm;
		#declare SpineMM = $$spinemm;
		#declare CoverHWX = $$coverwmm;
		#declare CoverHPX = $$coverhmm;
		#declare FrontImg = "$(word 1,$|)";
		#declare BackImg = "$(word 2,$|)";
		#declare SpineImg = "$(word 3,$|)";
		#declare BookThickness = $$spinemm / $$coverwmm / 2;
		#declare HalfThick = BookThickness / 2;
	EOF

BOOKSCENES = $(call pattern_list,$(TARGETS),$(BINDINGS),-3b.pov)
$(BOOKSCENES): %-3b.pov: %-geometry.zsh %.inc | $(povtextures)
	source $(filter %-geometry.zsh,$^)
	cat <<- EOF > $@
		#declare DefaultBook = "$(filter %.inc,$^)";
		#declare Lights = $(call scale,8,2);
		#declare OutputAspect = $$coverwmm / $$coverhmm;
		#declare BookAspect = $$coverwmm / $$coverhmm;
		#declare BookThickness = $$spinemm / $$coverwmm / 2;
		#declare HalfThick = BookThickness / 2;
	EOF

SERIESSCENES = $(call pattern_list,$(PROJECT),$(BINDINGS),-3b.pov)
$(SERIESSCENES): $(PROJECT)-%-3b.pov: $(firstword $(TARGETS))-%-3b.pov $(call pattern_list,$(TARGETS),-%.inc)
	cat <<- EOF > $@
		#include "$<"
		#declare BookCount = $(words $(TARGETS));
		#declare Books = array[BookCount] {
		$(subst $(space),$(,)
		,$(foreach INC,$(call series_sort,$(filter %.inc,$^)),"$(INC)")) }
	EOF

define povray
	headers=$$(mktemp povXXXXXX.inc)
	cat <<- EOF < $2 < $3 > $$headers
		#version 3.7;
		#declare SceneLight = $(SCENELIGHT);
	EOF
	$(POVRAY) $(POVFLAGS) -I$1 -HI$$headers -W$(call scale,$5) -H$(call scale,$6) -Q$(call scale,11,4) -O$4
	rm $$headers
endef

%-3b-on.png: $(CASILEDIR)/kapak.pov %-3b.pov $(CASILEDIR)/on.pov $(povtextures)
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,6000,8000)

%-3b-arka.png: $(CASILEDIR)/kapak.pov %-3b.pov $(CASILEDIR)/arka.pov $(povtextures) | %-3b-on.png
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,6000,8000)

%-3b-istif.png: $(CASILEDIR)/kapak.pov %-3b.pov $(CASILEDIR)/istif.pov $(povtextures) | %-3b-arka.png
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,8000,6000)

$(PROJECT)-%-3b-montaj.png: $(CASILEDIR)/kapak.pov $(PROJECT)-%-3b.pov $(CASILEDIR)/montaj.pov
	$(call povray,$(word 1,$^),$(word 2,$^),$(word 3,$^),$@,8000,6000)

define pov_crop
	\( +clone \
		-virtual-pixel edge \
		-colorspace gray \
		-edge 3 \
		-fuzz 40% \
		-trim -trim \
		-set option:fuzzy_trim "%[fx:w*1.2]x%[fx:h*1.2]+%[fx:page.x-w*0.1]+%[fx:page.y-h*0.1]" \
		+delete \
    \) \
    -crop %[fuzzy_trim] \
    -resize $(call scale,4000)x
endef

%.jpg: %.png
	$(MAGICK) $< \
		$(if $(findstring 3b,$*),$(call pov_crop),) \
		-quality 85 \
		$@
	$(addtosync)

%.epub %.odt %.docx: %-processed.md %-manifest.yml %-epub-pankart.jpg
	$(PANDOC) \
		$(PANDOCARGS) \
		--epub-cover-image=$(lastword $^) \
		$(word 2,$^) \
		<($(call strip_lang) < $<) -o $@
	$(addtosync)

%.mobi: %.epub
	kindlegen $< ||:
	$(addtosync)

# This is obsoleted by YAML merger, but the code might prove useful someday
# because the results are more flexible that the perl class
# %.json: $(CASILEDIR)/casile.yml $(METADATA) $$(wildcard $(PROJECT).yml $$*.yml)
# 	jq -s 'reduce .[] as $$item({}; . + $$item)' $(foreach YAML,$^,<(yaml2json $(YAML))) > $@

%-manifest.yml: $(CASILEDIR)/casile.yml $(METADATA) $$(wildcard $(PROJECT).yml $$*.yml)
	perl -MYAML::Merge::Simple=merge_files -MYAML -E 'say Dump merge_files(@ARGV)' $^ |
		sed -e 's/~$$/nil/g;/^--- |/d;$$a...' \
		    -e '/\(own\|next\)cloudshare: [^"]/s/: \(.*\)$$/: "\1"/' > $@
	$(addtosync)

%-url.png: %-url.svg
	$(MAGICK) $< \
		-bordercolor White -border 10x10 \
		-bordercolor Black -border 4x4 \
		$@

%-url.svg:
	zint \
			--direct \
			--filetype=svg \
			--scale=10 \
			--barcode=58 \
			--data=$(call urlinfo,$@) \
		> $@

%-barkod.svg: %-manifest.yml
	zint --direct \
			--filetype=svg \
			--scale=5 \
			--barcode=69 \
			--height=30 \
			--data=$(shell $(CASILEDIR)/bin/isbn_format.py $< print) |\
		sed -e 's/Helvetica\( Regular\)\?/TeX Gyre Heros/g' \
		> $@

%-barkod.png: %-barkod.svg
	$(MAGICK) $< \
		-bordercolor white -border 10 \
		-font Hack-Regular -pointsize 36 \
		label:"ISBN $(shell $(CASILEDIR)/bin/isbn_format.py $*-manifest.yml print mask)" +swap -gravity center -append \
		-bordercolor white -border 0x10 \
		-resize $(call scale,1200)x \
		$@
	if [[ $(shell $(CASILEDIR)/bin/isbn_format.py $*-manifest.yml print) == 9786056644504 ]]; then
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

%-ayetler.json: %-processed.md
	# cd $(CASILEDIR)
	# yarn add bible-passage-reference-parser
	$(if $(HEAD),head -n$(HEAD),cat) $< |
		extract_references.js > $@

%-ayetler-sorted.json: %-ayetler.json
	jq 'sort_by(.seq)' $< > $@

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
		entr $(ENTRFLAGS) make DRAFT=true LAZY=true $(WATCHARGS)

diff:
	git diff --color=always --ignore-submodules --no-ext-diff
	git submodule foreach git diff --color=always --no-ext-diff
