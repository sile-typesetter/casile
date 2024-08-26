AC_PREREQ([2.69])
AC_INIT([casile], [m4_esyscmd(build-aux/git-version-gen .tarball-version)], [caleb@alerque.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AM_INIT_AUTOMAKE([foreign tar-pax dist-zstd dist-zip no-dist-gzip color-tests subdir-objects])
AM_SILENT_RULES([yes])

QUE_GIT_VERSION
QUE_TRANSFORM_PACKAGE_NAME
QUE_DEVELOPER_MODE
QUE_DIST_CHECKSUMS

# Build time deps
AC_PROG_AWK
AC_PROG_GREP
AC_PROG_SED
QUE_PROGVAR([find])
QUE_PROGVAR([sort])
QUE_PROGVAR([xargs])
QUE_PROGVAR([yarn])

QUE_RUST_BOILERPLATE
QUE_DOCKER_BOILERPLATE

AC_ARG_ENABLE([dependency-checks],                                                                                                                             │    │
              AS_HELP_STRING([--disable-dependency-checks],                                                                                                          │    │
                      [Disable build tooling dependency checks]))                                                                                                    │    │
AM_CONDITIONAL([DEPENDENCY_CHECKS], [test "x$enable_dependency_checks" != "xno"])

AC_ARG_WITH([luajit],
            AS_HELP_STRING([--without-luajit],
                           [Prefer LuaJIT over PUC Lua, even if the latter is newer]))
AM_CONDITIONAL([LUAJIT], [test "x$with_luajit" != "xno"])

AM_COND_IF([DEPENDENCY_CHECKS], [

    # Run time deps
    AC_PROG_EGREP
    AC_PROG_INSTALL
    AC_PROG_MKDIR_P
    QUE_PROGVAR([bc])
    QUE_PROGVAR([curl])
    QUE_PROGVAR([cut])
    QUE_PROGVAR([date])
    QUE_PROGVAR([decasify])
    QUE_PROGVAR([deepl])
    QUE_PROGVAR([diff])
    QUE_PROGVAR([entr])
    QUE_PROGVAR([epubcheck])
    QUE_PROGVAR([fcconflist], [fc-conflist])
    QUE_PROGVAR([flock])
    QUE_PROGVAR([git])
    QUE_PROGVAR([gitwarptime], [git-warp-time])
    QUE_PROGVAR([gs])
    QUE_PROGVAR([hostnamebin], [hostname])
    QUE_PROGVAR([inkscape])
    QUE_PROGVAR([jq])
    QUE_PROGVAR([kindlegen])
    QUE_PROGVAR([m4])
    QUE_PROGVAR([magick])
    QUE_PROGVAR([mdbook])
    QUE_PROGVAR([node])
    QUE_PROGVAR([pandoc])
    QUE_PROGVAR([parallel])
    QUE_PROGVAR([pcregrep])
    QUE_PROGVAR([pdfbook2])
    QUE_PROGVAR([pdfinfo])
    QUE_PROGVAR([pdfjam])
    QUE_PROGVAR([pdftk])
    QUE_PROGVAR([pgrep])
    QUE_PROGVAR([podofobox])
    QUE_PROGVAR([povray])
    QUE_PROGVAR([rg])
    QUE_PROGVAR([sassc])
    QUE_PROGVAR([sile])
    QUE_PROGVAR([sponge])
    QUE_PROGVAR([sqlite3])
    QUE_PROGVAR([stat])
    QUE_PROGVAR([truncate])
    QUE_PROGVAR([wc])
    QUE_PROGVAR([xcf2png])
    QUE_PROGVAR([xvfbrun], [xvfb-run])
    QUE_PROGVAR([yq])
    QUE_PROGVAR([zint])
    QUE_PROGVAR([zola])
    QUE_PROGVAR([zsh])

    AC_MSG_CHECKING(whether pandoc has SILE Writer)
    AS_IF([$PANDOC --list-output-formats | $GREP -qx sile],[
        AC_MSG_RESULT(yes)
    ],[
        AC_MSG_FAILURE([pandoc must have sile writer support])
    ])

    AX_PROG_LUA(5.1, [], [], AC_MSG_ERROR([lua interpreter is required]))
    AX_LUAROCKS_ROCK(cldr)
    AX_LUAROCKS_ROCK(cosmo)
    AX_LUAROCKS_ROCK(decasify)
    AX_LUAROCKS_ROCK(fluent)
    AX_LUAROCKS_ROCK(lpeg)
    AX_LUAROCKS_ROCK(lua-utf8)
    AX_LUAROCKS_ROCK(yaml)

    AC_PATH_PROG([PERL], [perl])
    AX_PROG_PERL_VERSION([5], [], AC_MSG_ERROR([perl interpreter is required]))
    AX_PERL_MODULE_VERSION([YAML 1.30], [], AC_MSG_ERROR(Need Perl YAML module))
    AX_PERL_MODULE_VERSION([YAML::Merge::Simple 0.01], [], AC_MSG_ERROR(Need Perl YAML::Merge::Simple module))

    AM_PATH_PYTHON([3.6])
    AX_PYTHON_MODULE(ruamel, true)
    AX_PYTHON_MODULE(isbnlib, true)
    AX_PYTHON_MODULE(pandocfilters, true)

    AX_FONT(Hack)
    AX_FONT(TeX Gyre Heros)
    AX_FONT(Libertinus Serif)
    AX_FONT(Libertinus Serif Display)
    AX_FONT(Libertinus Sans)

    # Developer tooling deps
    AM_COND_IF([DEVELOPER_MODE], [
        QUE_PROGVAR([checkmake])
        QUE_PROGVAR([docker])
        QUE_PROGVAR([luacheck])
        QUE_PROGVAR([ruff])
        QUE_PROGVAR([stylua])
        QUE_PROGVAR([tr])
        QUE_PROGVAR([typos])
    ])
])

# Avoid the need for configuring with the `--datarootdir=$(cd ..; pwd)` hack to
# run from the source directory when developer mode is enabled.
AM_COND_IF([DEVELOPER_MODE], [
    datarootdir="$(cd ..; pwd)"
])

AC_CONFIG_FILES([build-aux/list-distfiles.sh], [chmod +x build-aux/list-distfiles.sh])
AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([rules/casile.mk])
AC_CONFIG_FILES([lib/make-shell.zsh], [chmod +x lib/make-shell.zsh])
AC_CONFIG_FILES([lib/functions.zsh])
AC_CONFIG_FILES([lib/casile-entry.zsh], [chmod +x lib/casile-entry.zsh])

AC_DEFUN([CASILE_SCRIPT], [AC_CONFIG_FILES([scripts/$1], [chmod +x scripts/$1])])

# cd scripts; git ls-files '*.in' | sed -e 's/\.in$//'
CASILE_SCRIPT([branch2criticmark.zsh])
CASILE_SCRIPT([cover_title.py])
CASILE_SCRIPT([diff2marked.zsh])
CASILE_SCRIPT([extract_references.js])
CASILE_SCRIPT([figure_dash.pl])
CASILE_SCRIPT([flatten_chapters.zsh])
CASILE_SCRIPT([import.zsh])
CASILE_SCRIPT([isbn_format.py])
CASILE_SCRIPT([italic_reorder.pl])
CASILE_SCRIPT([lazy_quotes.pl])
CASILE_SCRIPT([link_verses.js])
CASILE_SCRIPT([list_related_files.zsh])
CASILE_SCRIPT([loadchapters.zsh])
CASILE_SCRIPT([msword_escapes.pl])
CASILE_SCRIPT([normalize_files.zsh])
CASILE_SCRIPT([normalize_references.js])
CASILE_SCRIPT([ordinal_spaces.pl])
CASILE_SCRIPT([renumber_footnotes.pl])
CASILE_SCRIPT([reorder_punctuation.pl])
CASILE_SCRIPT([series_sort.lua])
CASILE_SCRIPT([smart_quotes.pl])
CASILE_SCRIPT([split_chapters.zsh])
CASILE_SCRIPT([split_mdbook_src.zsh])
CASILE_SCRIPT([stats.zsh])
CASILE_SCRIPT([toc2breaks.lua])
CASILE_SCRIPT([unicode_symbols.pl])
CASILE_SCRIPT([worklog.zsh])

AC_OUTPUT
