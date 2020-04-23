$(and $(word 2,$(MAKEFILE_LIST)),$(error This is not the makefile you should include in your project to run SILE, please use 'rules' instead.))

bin_PROGRAMS = casile$(EXEEXT)
casile_SOURCES = Cargo.toml build.rs src/main.rs
casile_EXTRA = Cargo.lock

EXTRA_DIST = $(casile_SOURCES) $(casile_EXTRA)

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
