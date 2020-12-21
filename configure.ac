AC_INIT([casile],
        m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [caleb@alerque.com])
AM_INIT_AUTOMAKE([foreign tar-pax dist-xz dist-zip no-dist-gzip subdir-objects color-tests])
AM_SILENT_RULES([yes])

AC_CONFIG_MACRO_DIRS([build-aux])

# Check that we have rust stuff
AC_CHECK_PROG(CARGO, [cargo], [yes], [no])
AS_IF(test x$CARGO = xno,
    AC_MSG_ERROR([cargo is required.  Please install the Rust toolchain])
)
AC_CHECK_PROG(RUSTC, [rustc], [yes], [no])
AS_IF(test x$RUSTC = xno,
    AC_MSG_ERROR([rustc is required.  Please install the Rust toolchain])
)

# Add --enable-debug flag to change Rust build mode
AC_ARG_ENABLE(debug,
              AC_HELP_STRING([--enable-debug],
                             [Build Rust code with debugging information [default=no]]),
              [debug_release=$enableval],
              [debug_release=no])

AC_MSG_CHECKING(whether to build Rust code with debugging information)
if test "x$debug_release" = "xyes" ; then
    AC_MSG_RESULT(yes)
    RUST_TARGET_SUBDIR=debug
else
    AC_MSG_RESULT(no)
    RUST_TARGET_SUBDIR=release
fi
AM_CONDITIONAL([DEBUG_RELEASE], [test "x$debug_release" = "xyes"])

AC_ARG_WITH([bash-completion-dir],
    AS_HELP_STRING([--with-bash-completion-dir[=PATH]],
        [Install the bash auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_bash_completion_dir=yes])
if test "x$with_bash_completion_dir" = "xyes"; then
    PKG_CHECK_MODULES([BASH_COMPLETION], [bash-completion >= 2.0],
        [BASH_COMPLETION_DIR="`pkg-config --variable=completionsdir bash-completion`"],
        [BASH_COMPLETION_DIR="$datadir/bash-completion/completions"])
else
    BASH_COMPLETION_DIR="$with_bash_completion_dir"
fi
AC_SUBST([BASH_COMPLETION_DIR])
AM_CONDITIONAL([ENABLE_BASH_COMPLETION],[test "x$with_bash_completion_dir" != "xno"])

AC_ARG_WITH([fish-completion-dir],
    AS_HELP_STRING([--with-fish-completion-dir[=PATH]],
        [Install the fish auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_fish_completion_dir=yes])
if test "x$with_fish_completion_dir" = "xyes"; then
    PKG_CHECK_MODULES([FISH_COMPLETION], [fish >= 3.0],
        [FISH_COMPLETION_DIR="`pkg-config --variable=completionsdir fish`"],
        [FISH_COMPLETION_DIR="$datadir/fish/vendor_completions.d"])
else
    FISH_COMPLETION_DIR="$with_fish_completion_dir"
fi
AC_SUBST([FISH_COMPLETION_DIR])
AM_CONDITIONAL([ENABLE_FISH_COMPLETION],[test "x$with_fish_completion_dir" != "xno"])

AC_ARG_WITH([zsh-completion-dir],
    AS_HELP_STRING([--with-zsh-completion-dir[=PATH]],
        [Install the zsh auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_zsh_completion_dir=yes])
if test "x$with_zsh_completion_dir" = "xyes"; then
    ZSH_COMPLETION_DIR="$datadir/zsh/site-functions"
else
    ZSH_COMPLETION_DIR="$with_zsh_completion_dir"
fi
AC_SUBST([ZSH_COMPLETION_DIR])
AM_CONDITIONAL([ENABLE_ZSH_COMPLETION],[test "x$with_zsh_completion_dir" != "xno"])

AC_SUBST([RUST_TARGET_SUBDIR])

AC_CHECK_PROG(YARN, yarn, yes)
test "x$YARN" == "xyes" || AC_MSG_ERROR([yarn is required])

AC_CHECK_PROG(SILE, sile, yes)
test "x$SILE" == "xyes" || AC_MSG_ERROR([sile is required])

AC_PROG_GREP
AC_PATH_PROG(PANDOC, pandoc)
test "x$PANDOC" != "x" || AC_MSG_ERROR([pandoc is required])
AC_MSG_CHECKING(whether pandoc has SILE Writer)
AS_IF([$PANDOC --list-output-formats | $GREP -qx sile],[
    AC_MSG_RESULT(yes)
],[
    AC_MSG_FAILURE([pandoc must have sile writer support])
])

AC_CHECK_PROG(MAGICK, magick, yes)
test "x$MAGICK" == "xyes" || AC_MSG_ERROR([magick is required])

AC_CHECK_PROG(POVRAY, povray, yes)
test "x$POVRAY" == "xyes" || AC_MSG_ERROR([povray is required])

AC_CHECK_PROG(JQ, jq, yes)
test "x$JQ" == "xyes" || AC_MSG_ERROR([jq is required])

AC_CHECK_PROG(ZINT, zint, yes)
test "x$ZINT" == "xyes" || AC_MSG_ERROR([zint is required])

AC_CHECK_PROG(PDFINFO, pdfinfo, yes)
test "x$PDFINFO" == "xyes" || AC_MSG_ERROR([pdfinfo is required])

AC_CHECK_PROG(PDFTK, pdftk, yes)
test "x$PDFTK" == "xyes" || AC_MSG_ERROR([pdftk is required])

AC_CHECK_PROG(INKSCAPE, inkscape, yes)
test "x$INKSCAPE" == "xyes" || AC_MSG_ERROR([inkscape is required])

AC_CHECK_PROG(PODOFOBOX, podofobox, yes)
test "x$PODOFOBOX" == "xyes" || AC_MSG_ERROR([podofobox is required])

AC_CHECK_PROG(SPONGE, sponge, yes)
test "x$SPONGE" == "xyes" || AC_MSG_ERROR([sponge is required])

AC_CHECK_PROG(M4, m4, yes)
test "x$M4" == "xyes" || AC_MSG_ERROR([m4 is required])

AC_CHECK_PROG(ENTR, entr, yes)
test "x$ENTR" == "xyes" || AC_MSG_ERROR([entr is required])

AC_CHECK_PROG(PCREGREP, pcregrep, yes)
test "x$PCREGREP" == "xyes" || AC_MSG_ERROR([pcregrep is required])

AC_CHECK_PROG(NODE, node, yes)
test "x$NODE" == "xyes" || AC_MSG_ERROR([node is required])

AC_CHECK_PROG(BC, bc, yes)
test "x$BC" == "xyes" || AC_MSG_ERROR([bc is required])

AC_CHECK_PROG(ZSH, zsh, yes)
test "x$ZSH" == "xyes" || AC_MSG_ERROR([zsh is required])

AC_CHECK_PROG(epubcheck, epubcheck, yes)
test "x$epubcheck" == "xyes" || AC_MSG_ERROR([epubcheck is required])

AC_CHECK_PROG(sqlite3, sqlite3, yes)
test "x$sqlite3" == "xyes" || AC_MSG_ERROR([sqlite3 is required])

AX_PROG_LUA(5.1, , , AC_MSG_ERROR([lua interpreter is required]))
AX_LUAROCKS_ROCK(yaml)

AC_PATH_PROG([PERL], [perl])
AX_PROG_PERL_VERSION(5, ,AC_MSG_ERROR([perl interpreter is required]))
AX_PERL_MODULE_VERSION(YAML 1.30, , AC_MSG_ERROR(Need Perl YAML module))
AX_PERL_MODULE_VERSION(YAML::Merge::Simple 0.01, , AC_MSG_ERROR(Need Perl YAML::Merge::Simple module))

AX_PYTHON
AX_PYTHON_MODULE(ruamel, true)
AX_PYTHON_MODULE(isbnlib, true)
AX_PYTHON_MODULE(pandocfilters, true)

AX_FONT(Hack)
AX_FONT(TeX Gyre Heros)
AX_FONT(Libertinus Serif)
AX_FONT(Libertinus Serif Display)
AX_FONT(Libertinus Sans)

AC_CONFIG_FILES([Makefile])

AC_OUTPUT
