ACLOCAL_AMFLAGS = -I build-aux
AM_DISTCHECK_CONFIGURE_FLAGS = --enable-developer-mode

.ONESHELL:
.SECONDARY:
.SECONDEXPANSION:
.DELETE_ON_ERROR:

docdir = $(datarootdir)/doc/$(TRANSFORMED_PACKAGE_NAME)
licensedir = $(datarootdir)/licenses/$(TRANSFORMED_PACKAGE_NAME)
datadir = $(datarootdir)/$(TRANSFORMED_PACKAGE_NAME)
pkgdatadir = $(datadir)

# Since we can't use $(wildcard ...) in automake file lists, we generate a file
# with a script that builds our dynamic file lists instead. This is tricky,
# because if we just include the file automake will flatten this include. By
# using $(wildcard ...) to include it (the very function we couldn't use because
# of the race condition it creates) we actually keep it from being flattened and
# hence evaluated when we want it to be. Since the file always exists (see
# BUILT_SOURCES and EXTRA_DIST) this doesn't induce a race.
include $(wildcard $(top_srcdir)/Makefile-distfiles)

lang_key_files = rules/en.mk rules/tr.mk
reverse_lang_key_files = $(patsubst %.mk,%-reversed.mk,$(lang_key_files))

dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE.md
dist_man_MANS =
nobase_data_DATA = rules/casile.mk $(reverse_lang_key_files)
nobase_dist_data_DATA = rules/rules.mk rules/functions.mk rules/translation.mk rules/utilities.mk $(lang_key_files)
nobase_dist_data_DATA += rules/ebooks.mk rules/mdbook.mk rules/renderings.mk rules/zola.mk
nobase_dist_pkgdata_DATA = $(LUALIBRARIES)
_casile_libs = src/lib.rs src/cli.rs src/config.rs src/i18n.rs src/ui.rs src/ui_indicatif.rs src/ui_ascii.rs
_casile_modules = src/make/mod.rs src/run/mod.rs src/setup/mod.rs src/status/mod.rs
_casile_assets = assets/en-US/cli.ftl assets/tr-TR/cli.ftl
bin_PROGRAMS = casile
casile_SOURCES = src/main.rs $(_casile_libs) $(_casile_modules) $(_casile_assets)
EXTRA_casile_SOURCES = tests/cli.rs
EXTRA_DIST = package.json yarn.lock requirements.txt
EXTRA_DIST += build-aux/action-updater.js build-aux/cargo-updater.js build-aux/git-version-gen
EXTRA_DIST += Dockerfile build-aux/bootstrap-docker.sh build-aux/docker-fontconfig.conf hooks/build

BUILT_SOURCES = Makefile-distfiles

CLEANFILES =

DISTCLEANFILES = @AMINCLUDE@

# A classical use of the autoconf-archive include macro would expand
# INC_AMINCLUDE here, but the perl script that inlines include statements
# runs before the automake that organizes logic and performs substitution.
# Consequentially with a substitution here it becomes impossible to use
# automake conditionals and substitutions in the included Makefile fragments.
# By entering the expanded value directly we are ready in time for the inlining
# functionality and hence can use conditionals in included makefile fragments.
include $(top_srcdir)/aminclude.am

Makefile-distfiles: $(wildcard .version .tarball-version)
	$(SHELL) build-aux/list-distfiles.sh > $@

# use :read !git ls-files <pattern> to repopulate <pattern>_DATA vars

povdir = $(datadir)
dist_pov_DATA = $(POVDATA)

xmldir = $(datadir)
dist_xml_DATA = $(XMLDATA)

sildir = $(datadir)
dist_sil_DATA = $(SILDATA)

svgdir = $(datadir)
dist_svg_DATA = $(SVGDATA)

m4dir = $(datadir)
dist_m4_DATA = casile.m4

yamldir = $(datadir)
dist_yaml_DATA = casile.yml

templatesdir = $(datadir)
dist_templates_DATA = \
	editorconfig \
	gitlab-ci.yml \
	luacheckrc \
	luarc.json \
	zola_book.html \
	zola_series.html \
	zola_style.sass

namesdir = $(datadir)
dist_names_DATA = $(NAMESDATA)

seddir = $(datadir)
dist_sed_DATA = $(SEDDATA)

vimdir = $(datadir)
dist_vim_DATA = $(VIMDATA)

datalibdir = $(datadir)/lib
dist_datalib_DATA = $(DATALIBLIBS)

scriptlibdir = $(datadir)/lib
dist_scriptlib_SCRIPTS = $(SCRIPTLIBLIBS)

scriptsdir = $(datadir)/scripts
dist_scripts_SCRIPTS = $(SCRIPTSSCRIPTS)

fontsdir = $(datadir)/fonts
dist_fonts_DATA = $(FONTSDATA)

filtersdir = $(datadir)/pandoc-filters
dist_filters_DATA = $(PANDOCFILTERS)

classesdir = $(datadir)/classes
dist_classes_DATA = $(SILECLASSFILES)

packagesdir = $(datadir)/packages
dist_packages_DATA = $(SILEPACKAGEFILES)

layoutsdir = $(datadir)/layouts
dist_layouts_DATA = $(SILELAYOUTFILES)

assetsdir = $(datadir)
nobase_dist_assets_DATA = $(ASSETDATA)

CLEANFILES += $(bin_PROGRAMS) $(dist_scripts_SCRIPTS)

CARGO_FEATURE_ARGS = --all-features

%-reversed.mk: %.mk
	$(AWK) -F' := ' '/^_/ { gsub(/_/, "", $$1); print "__" $$2 " := " $$1 }' < $< > $@

luarc.json: .luarc.json
	cp $< $@

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ ! -e .git ]] || $(GIT) clean -dxf assets

dist-hook: dist-hook-yarn

.PHONY: dist-hook-yarn
dist-hook-yarn:
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

dist: casile-$(VERSION).md

casile-%.md: CHANGELOG.md
	$(SED) -e '/\.\.\.v$*/,/\.\.\.v/!d' $< | \
		$(SED) -e '1,3d;N;$$!P;$$!D;$$d' | \
	$(or $(filter cat,$(TYPOS)),$(TYPOS) --write-changes -) > $@

PHONY_DEVELOPER_TARGETS  = checkmake lint luacheck ruff ruff-format stylua typos
PHONY_DEVELOPER_TARGETS += tagrelease release-preview release
PHONY_DEVELOPER_TARGETS += docker docker-dep-check docker-ghcr-to-hub docker-build-push
.PHONY: $(PHONY_DEVELOPER_TARGETS)

if DEVELOPER_MODE

lint: luacheck checkmake ruff ruff-format stylua typos

luacheck:
	$(LUACHECK) .

checkmake:
	$(GIT) ls-files 'rules/*.mk' 'rules/*.mk.in' | $(XARGS) -n1 checkmake

ruff:
	$(GIT) ls-files '*.py' '*.py.in' | $(XARGS) $(RUFF) check

ruff-format:
	$(GIT) ls-files '*.py' '*.py.in' | $(XARGS) $(RUFF) format --check

stylua:
	$(STYLUA) --check --respect-ignores -g '!lua-libraries*' -g '!lua_modules/*' -g '*.lua' -g '*.lua.in' .

typos:
	$(TYPOS) .

RELTYPE ?=

tagrelease:
	test -z $$($(GIT) tag --points-at HEAD) || \
	$(GIT) diff-index --quiet --cached HEAD && \
	$(GIT) diff-files --quiet && \
	$(YARN) run release --preMajor $(and $(RELTYPE),--release-as $(RELTYPE))

release-preview:
	$(YARN) run release --preMajor --dry-run $(and $(RELTYPE),--release-as $(RELTYPE))

release: tagrelease

export GHCR_REGISTRY ?= ghcr.io
export GHCR_REPO ?= sile-typesetter/$(TRANSFORMED_PACKAGE_NAME)

export DOCKER_REGISTRY ?= docker.io
export DOCKER_REPO ?= siletypesetter/$(TRANSFORMED_PACKAGE_NAME)
export DOCKER_TAG ?= HEAD

docker: Dockerfile hooks/build .version
	./hooks/build $(VERSION)

docker-dep-check: .docker_deps .aur_deps
	$(DIFF) -u $^

.docker_deps: hooks/build
	$(SHELL) -c 'source <($(SED) -nE "/^(RUN|'"'"')/{s/.*=/echo /;p}" $<)' | \
		$(TR) ' ' '\n' | \
		$(SORT) > $@

CLEANFILES += .docker_deps

.aur_deps:
	$(CURL) -Ls 'https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=casile-git' | \
		$(SED) -nE '/\bdepends =/{s/.*= //;p}' | \
		$(GREP) -vxE '(lua-.*|.*\.so|git|glibc)' | \
		$(SORT) > $@

CLEANFILES += .aur_deps

docker-ghcr-to-hub:
	$(DOCKER) pull $(GHCR_REGISTRY)/$(GHCR_REPO):$(DOCKER_TAG)
	$(DOCKER) tag  $(GHCR_REGISTRY)/$(GHCR_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	$(docker_push)

else !DEVELOPER_MODE

$(PHONY_DEVELOPER_TARGETS):
	@: $(error "Please reconfigure using --enable-developer-mode to use developer tooling")

endif !DEVELOPER_MODE
