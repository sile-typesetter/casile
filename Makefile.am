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

check-local:
	cargo test

clean-local:
	cargo clean
