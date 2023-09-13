#!/usr/bin/env sh
set -e

incomplete_source () {
    printf '%s\n' \
        "$1. Please either:" \
        "* $2," \
        "* or use the source packages instead of a repo archive" \
        "* or use a full Git clone." >&2
    exit 1
}

# This enables easy building from Github's snapshot archives
if [ ! -e ".git" ]; then
    if [ ! -f ".tarball-version" ]; then
    incomplete_source "No version information found" \
        "identify the correct version with \`echo \$version > .tarball-version\`"
    fi
else
    # Just a head start to save a ./configure cycle
    ./build-aux/git-version-gen .tarball-version > .version
fi

# Autoreconf uses a perl script to inline includes from Makefile.am into
# Makefile.in before ./configure is even run ... which is where we're going to
# use AC_SUBST to setup project specific build options. We need to pre-seed
# a file to avoid a file not found error on first run. The configure process
# will rebuild this and also re-include it into the final Makefile.
touch build-aux/rust_boilerplate.am

autoreconf --install
