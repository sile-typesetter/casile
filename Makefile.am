$(and $(word 2,$(MAKEFILE_LIST)),$(error This is not the makefile you should include in your project to run SILE, please use 'rules' instead.))

_casile != sed -e "$(program_transform_name)" <<< casile

licensedir = $(datarootdir)/licenses/$(_casile)
docdir = $(datarootdir)/doc/$(_casile)
datadir = $(datarootdir)/$(_casile)

dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE.txt

EXTRA_DIST = package.json yarn.lock

bin_PROGRAMS = casile

casile_SOURCES = Cargo.toml build.rs src/main.rs
EXTRA_casile_SOURCES = Cargo.lock

# use :read !git ls-files <pattern> to repopulate <pattern>_DATA vars

rulesdir = $(datadir)
dist_rules_DATA = rules makefile-functions makefile-en makefile-tr

scriptsdir = $(datadir)/bin
dist_scripts_DATA = bin/branch2criticmark.zsh bin/cover_title.py bin/diff2marked.zsh bin/extract_references.js bin/figure_dash.pl bin/functions.zsh bin/isbn_format.py bin/italic_reorder.pl bin/lazy_quotes.pl bin/link_verses.js bin/loadchapters.zsh bin/msword_escapes.pl bin/normalize_references.js bin/ordinal_spaces.pl bin/renumber_footnotes.pl bin/reorder_punctuation.pl bin/series_sort.lua bin/smart_quotes.pl bin/split_chapters.zsh bin/stats.zsh bin/toc2breaks.lua bin/unicode_symbols.pl bin/worklog.zsh

fontsdir = $(datadir)/fonts
dist_fonts_DATA = fonts/Almendra-Bold.otf fonts/Almendra-BoldItalic.otf fonts/Almendra-Italic.otf fonts/Almendra-Regular.otf fonts/AlmendraDisplay-Regular.otf fonts/AlmendraSC-Bold.otf fonts/AlmendraSC-BoldItalic.otf fonts/AlmendraSC-Italic.otf fonts/AlmendraSC-Regular.otf fonts/FeFlow2.otf fonts/NexaRustExtras-Free.otf fonts/NexaRustHandmade-Extended-Free.otf fonts/NexaRustSans-Black-Free.otf fonts/NexaRustScriptL-0-Free.otf fonts/NexaRustSlab-BlackShadow01-Free.otf fonts/Nymphette.ttf fonts/PrintersOrnamentsOne.ttf

filtersdir = $(datadir)/pandoc-filters
dist_filters_DATA = pandoc-filters/chapterid.lua pandoc-filters/epubclean.lua pandoc-filters/svg2pdf.py pandoc-filters/withoutfootnotes.lua pandoc-filters/withoutheadinglinks.lua pandoc-filters/withoutlinks.lua pandoc-filters/withverses.lua

packagesdir = $(datadir)/packages
dist_packages_DATA = packages/crop.lua packages/markdown.lua packages/verseindex.lua

if DEBUG_RELEASE
CARGO_RELEASE_ARGS=
else
CARGO_RELEASE_ARGS=--release
endif

CARGO_VERBOSE = $(cargo_verbose_$(V))
cargo_verbose_ = $(cargo_verbose_$(AM_DEFAULT_VERBOSITY))
cargo_verbose_0 =
cargo_verbose_1 = --verbose

casile$(EXEEXT): target/release/casile
	cp $< $@

target/release/casile: $(casile_SOURCES)
	cargo build $(CARGO_VERBOSE) $(CARGO_RELEASE_ARGS)

all: init

.PHONY:
init: node_modules

node_modules: yarn.lock
	yarn install --frozen-lockfile

yarn.lock: package.json
	yarn install

RELTYPE ?=

.PHONY: tagrelease
tagrelease:
	test -z $$(git tag --points-at HEAD) || exit 0 # end if we are already on a release tag
	git diff-index --quiet --cached HEAD || exit 1 # die if anything staged but not committed
	git diff-files --quiet || exit 1 # die if any tracked files have unstagged changes
	yarn run release $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release
release: tagrelease

.PHONY: docker
docker: Dockerfile build-aux/docker-entrypoint.sh
	docker build \
		--build-arg VCS_REF="$(VERSION)" \
		--tag siletypesetter/casile:HEAD \
		./

check-local:
	cargo test

clean-local:
	cargo clean
