$(and $(word 2,$(MAKEFILE_LIST)),$(error This is not the makefile you should include in your project to run CaSILE, please use 'rules/casile.mk' instead.))

ACLOCAL_AMFLAGS = -I build-aux

.ONESHELL:
.SECONDARY:
.SECONDEXPANSION:
.DELETE_ON_ERROR:

docdir = $(datarootdir)/doc/$(TRANSFORMED_PACKAGE_NAME)
licensedir = $(datarootdir)/licenses/$(TRANSFORMED_PACKAGE_NAME)
datadir = $(datarootdir)/$(TRANSFORMED_PACKAGE_NAME)
pkgdatadir = $(datadir)

lang_key_files = rules/en.mk rules/tr.mk
reverse_lang_key_files = $(patsubst %.mk,%-reversed.mk,$(lang_key_files))

pkgdata_SCRIPTS = make-shell.zsh
dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE.md
dist_man_MANS =
nobase_data_DATA = rules/casile.mk $(reverse_lang_key_files)
nobase_dist_data_DATA = rules/rules.mk rules/functions.mk rules/translation.mk rules/utilities.mk $(lang_key_files)
nobase_dist_data_DATA += rules/ebooks.mk rules/mdbook.mk rules/renderings.mk rules/zola.mk
_casile_libs = src/lib.rs src/cli.rs src/config.rs src/i18n.rs
_casile_modules = src/make/mod.rs src/script/mod.rs src/setup/mod.rs src/status/mod.rs
_casile_assets = assets/en-US/cli.ftl assets/tr-TR/cli.ftl
bin_PROGRAMS = casile
casile_SOURCES = src/main.rs $(_casile_libs) $(_casile_modules) $(_casile_assets)
EXTRA_casile_SOURCES = tests/cli.rs
EXTRA_DIST = package.json yarn.lock requirements.txt
EXTRA_DIST += build-aux/action-updater.js build-aux/cargo-updater.js build-aux/git-version-gen
EXTRA_DIST += Dockerfile build-aux/bootstrap-docker.sh build-aux/docker-fontconfig.conf hooks/build

BUILT_SOURCES =

CLEANFILES =

include $(top_srcdir)/build-aux/rust_boilerplate.mk

# use :read !git ls-files <pattern> to repopulate <pattern>_DATA vars

luadir = $(datadir)
dist_lua_DATA = readmeta.lua

povdir = $(datadir)
dist_pov_DATA = back.pov book.pov front.pov montage.pov pile.pov

xmldir = $(datadir)
dist_xml_DATA = binding.xml cover.xml geometry.xml

sildir = $(datadir)
dist_sil_DATA = a5kesme.sil template.sil

svgdir = $(datadir)
dist_svg_DATA = binding.svg emblum.svg logo.svg

m4dir = $(datadir)
dist_m4_DATA = casile.m4

yamldir = $(datadir)
dist_yaml_DATA = casile.yml

templatesdir = $(datadir)
dist_templates_DATA = editorconfig gitlab-ci.yml zola_series.html zola_book.html zola_style.sass

namesdir = $(datadir)
dist_names_DATA = names.en.txt names.la.txt names.part.txt names.tr.txt names.und.txt names.xx.txt

seddir = $(datadir)
dist_sed_DATA = upgrade-lua.sed upgrade-make.sed upgrade-markdown.sed upgrade-yaml.sed

vimdir = $(datadir)
dist_vim_DATA = citation_audit.vim quotation_audit.vim

dist_data_DATA = functions.zsh

scriptsdir = $(datadir)/scripts
dist_scripts_SCRIPTS = scripts/branch2criticmark.zsh scripts/cover_title.py scripts/diff2marked.zsh scripts/extract_references.js scripts/figure_dash.pl scripts/isbn_format.py scripts/italic_reorder.pl scripts/lazy_quotes.pl scripts/link_verses.js scripts/list_related_files.zsh scripts/loadchapters.zsh scripts/msword_escapes.pl scripts/normalize_references.js scripts/ordinal_spaces.pl scripts/renumber_footnotes.pl scripts/reorder_punctuation.pl scripts/series_sort.lua scripts/smart_quotes.pl scripts/split_chapters.zsh scripts/split_mdbook_src.zsh scripts/stats.zsh scripts/toc2breaks.lua scripts/unicode_symbols.pl scripts/worklog.zsh

fontsdir = $(datadir)/fonts
dist_fonts_DATA = fonts/Almendra-Bold.otf fonts/Almendra-BoldItalic.otf fonts/Almendra-Italic.otf fonts/Almendra-Regular.otf fonts/AlmendraDisplay-Regular.otf fonts/AlmendraSC-Bold.otf fonts/AlmendraSC-BoldItalic.otf fonts/AlmendraSC-Italic.otf fonts/AlmendraSC-Regular.otf fonts/FeFlow2.otf fonts/NexaRustExtras-Free.otf fonts/NexaRustHandmade-Extended-Free.otf fonts/NexaRustSans-Black-Free.otf fonts/NexaRustScriptL-0-Free.otf fonts/NexaRustSlab-BlackShadow01-Free.otf fonts/Nymphette.ttf fonts/PrintersOrnamentsOne.ttf

filtersdir = $(datadir)/pandoc-filters
dist_filters_DATA = pandoc-filters/chapterid.lua pandoc-filters/epubclean.lua pandoc-filters/strip_for_mdbook.lua pandoc-filters/titlecase_titles.lua pandoc-filters/svg2pdf.py pandoc-filters/withoutfootnotes.lua pandoc-filters/withoutheadinglinks.lua pandoc-filters/withoutlinks.lua pandoc-filters/withverses.lua

classesdir = $(datadir)/classes
dist_classes_DATA = classes/cabook.lua classes/cabinding.lua classes/cageometry.lua

packagesdir = $(datadir)/packages
dist_packages_DATA = packages/casile.lua packages/covers.lua packages/crop.lua packages/dumpframes.lua packages/endnotes.lua packages/imprint.lua packages/calists.lua packages/markdown.lua packages/verseindex.lua
dist_packages_DATA += packages/cabook-commands.lua packages/cabook-inline-styles.lua packages/cabook-block-styles.lua

layoutsdir = $(datadir)/layouts
dist_layouts_DATA = layouts/a4.lua layouts/a4ciltli.lua layouts/a5trim.lua layouts/a6.lua layouts/a6trim.lua layouts/a7.lua layouts/a7kart.lua layouts/a7trimkart.lua layouts/app.lua layouts/banner.lua layouts/businesscard.lua layouts/cep.lua layouts/ekran.lua layouts/epub.lua layouts/halfletter.lua layouts/octavo.lua layouts/royaloctavo.lua layouts/square.lua layouts/wide.lua

assetsdir = $(datadir)
nobase_dist_assets_DATA = assets/en-US/casile.ftl assets/tr-TR/casile.ftl

CLEANFILES += $(bin_PROGRAMS) $(dist_scripts_SCRIPTS)

CARGO_FEATURE_ARGS = --all-features

%-reversed.mk: %.mk
	$(AWK) -F' := ' '/^_/ { gsub(/_/, "", $$1); print "__" $$2 " := " $$1 }' < $< > $@

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ ! -e .git ]] || $(GIT) clean -dxf assets

dist-hook:
	$(YARN) install --production --frozen-lockfile --modules-folder "$(distdir)/node_modules"

install-data-hook:
	$(YARN) install --production --frozen-lockfile --modules-folder "$(DESTDIR)$(datadir)/node_modules"

uninstall-hook:
	rm -rf "$(DESTDIR)$(datadir)/node_modules"

all: init

.PHONY:
init: node_modules

node_modules: yarn.lock
	$(YARN) install --frozen-lockfile

yarn.lock: package.json
	$(YARN) install

PHONY_DEVELOPER_TARGETS = lint luacheck checkmake ruff tagrelease release-preview release docker docker-dep-check docker-ghcr-to-hub docker-build-push
.PHONY: $(PHONY_DEVELOPER_TARGETS)

if DEVELOPER

lint: luacheck checkmake ruff ruff-format

luacheck:
	$(LUACHECK) .

checkmake:
	$(GIT) ls-files '*.mk' | $(XARGS) -n1 checkmake

ruff:
	$(GIT) ls-files '*.py' '*.py.in' | $(XARGS) $(RUFF) check

ruff-format:
	$(GIT) ls-files '*.py' '*.py.in' | $(XARGS) $(RUFF) format --check

RELTYPE ?=

tagrelease:
	test -z $$($(GIT) tag --points-at HEAD) || \
	$(GIT) diff-index --quiet --cached HEAD && \
	$(GIT) diff-files --quiet && \
	$(YARN) run release $(and $(RELTYPE),--release-as $(RELTYPE))

release-preview:
	$(YARN) run release --dry-run $(and $(RELTYPE),--release-as $(RELTYPE))

release: tagrelease

casile-%.md: CHANGELOG.md
	$(SED) -e '/\.\.\.v$*/,/\.\.\.v/!d' $< | \
		$(SED) -e '1,3d;N;$$!P;$$!D;$$d' > $@

export GHCR_REGISTRY ?= ghcr.io
export GHCR_REPO ?= sile-typesetter/$(TRANSFORMED_PACKAGE_NAME)

export DOCKER_REGISTRY ?= docker.io
export DOCKER_REPO ?= siletypesetter/$(TRANSFORMED_PACKAGE_NAME)
export DOCKER_TAG ?= HEAD

docker: Dockerfile hooks/build .version
	./hooks/build $(VERSION)

docker-dep-check: .docker_deps .aur_deps
	$(DIFF) -u $^

CLEANFILES += .docker_deps
.docker_deps: hooks/build
	$(SHELL) -c 'source <($(SED) -nE "/^(RUN|'"'"')/{s/.*=/echo /;p}" $<)' | \
		$(TR) ' ' '\n' | \
		$(SORT) > $@

CLEANFILES += .aur_deps
.aur_deps:
	$(CURL) -Ls 'https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=casile-git' | \
		$(SED) -nE '/\bdepends =/{s/.*= //;p}' | \
		$(GREP) -v 'so.$$' | \
		$(SORT) > $@

define docker_push =
	test -z "$(DOCKER_PAT)" || \
		$(DOCKER) login https://$(DOCKER_REGISTRY) -u $(DOCKER_USERNAME) -p $(DOCKER_PAT)
		$(DOCKER) push $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	if [[ "$(DOCKER_TAG)" == v*.*.* ]]; then \
		tag=$(DOCKER_TAG) ; \
		$(DOCKER) tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):latest ; \
		$(DOCKER) tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$${tag//.*} ; \
		$(DOCKER) push $(DOCKER_REGISTRY)/$(DOCKER_REPO):latest ; \
		$(DOCKER) push $(DOCKER_REGISTRY)/$(DOCKER_REPO):$${tag//.*} ; \
	fi
endef

docker-ghcr-to-hub:
	$(DOCKER) pull $(GHCR_REGISTRY)/$(GHCR_REPO):$(DOCKER_TAG)
	$(DOCKER) tag  $(GHCR_REGISTRY)/$(GHCR_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	$(docker_push)

docker-build-push: docker
	$(DOCKER) tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	$(docker_push)

else

$(PHONY_DEVELOPER_TARGETS):
	@: $(error "Please reconfigure using --enable-developer to use developer tooling")

endif
