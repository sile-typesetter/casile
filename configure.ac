AC_PREREQ([2.69])
AC_INIT([casile], [m4_esyscmd(build-aux/git-version-gen .tarball-version)], [caleb@alerque.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AM_INIT_AUTOMAKE([foreign tar-pax dist-zstd dist-zip no-dist-gzip no-dependencies color-tests subdir-objects])
AM_SILENT_RULES([yes])

# Load up re-usable m4 bits shared across Caleb's projects
QUE_GIT_VERSION
QUE_TRANSFORM_PACKAGE_NAME
QUE_DEVELOPER_MODE
QUE_DIST_CHECKSUMS

# Check for and set variables for tooling used during our build process
AC_PROG_AWK
AC_PROG_GREP
AC_PROG_SED
AX_REQUIRE_PROG(cmp)
AX_REQUIRE_PROG(find)
AX_REQUIRE_PROG(jq)
AX_REQUIRE_PROG(sort)
AX_REQUIRE_PROG(xargs)
AX_REQUIRE_PROG(yarn)

QUE_DOCKER_BOILERPLATE
QUE_RUST_BOILERPLATE

AC_ARG_ENABLE([dependency-checks],
              AS_HELP_STRING([--disable-dependency-checks],
                      [Disable build tooling dependency checks]))
AM_CONDITIONAL([DEPENDENCY_CHECKS], [test "x$enable_dependency_checks" != "xno"])

# Assume true unless later checks prove otherwise, allows our checks for Lua to
# be run conditionally and hence skipped for e.g. docker only build pipelines.
AM_CONDITIONAL([LUAJIT], [true])

AM_COND_IF([DEPENDENCY_CHECKS], [

    # Run time deps
    AC_PROG_EGREP
    AC_PROG_INSTALL
    AC_PROG_MKDIR_P
    AX_REQUIRE_PROG(bc)
    AX_REQUIRE_PROG(curl)
    AX_REQUIRE_PROG(cut)
    AX_REQUIRE_PROG(date)
    AX_REQUIRE_PROG(decasify)
    AX_REQUIRE_PROG(deepl)
    AX_REQUIRE_PROG(diff)
    AX_REQUIRE_PROG(entr)
    AX_REQUIRE_PROG(epubcheck)
    AX_REQUIRE_PROG(fc-conflist)
    AX_REQUIRE_PROG(flock)
    AX_REQUIRE_PROG(git)
    AX_REQUIRE_PROG(git-warp-time)
    AX_REQUIRE_PROG(gs)
    AX_REQUIRE_PROG(hostname, HOSTNAMEBIN)
    AX_REQUIRE_PROG(inkscape)
    AX_REQUIRE_PROG(kindlegen)
    AX_REQUIRE_PROG(luarocks)
    AX_REQUIRE_PROG(m4)
    AX_REQUIRE_PROG(magick)
    AX_REQUIRE_PROG(mdbook)
    AX_REQUIRE_PROG(node)
    AX_REQUIRE_PROG(pandoc)
    AX_REQUIRE_PROG(parallel)
    AX_REQUIRE_PROG(pcregrep)
    AX_REQUIRE_PROG(pdfbook2)
    AX_REQUIRE_PROG(pdfinfo)
    AX_REQUIRE_PROG(pdfjam)
    AX_REQUIRE_PROG(pdftk)
    AX_REQUIRE_PROG(pgrep)
    AX_REQUIRE_PROG(podofobox)
    AX_REQUIRE_PROG(povray)
    AX_REQUIRE_PROG(rg)
    AX_REQUIRE_PROG(sassc)
    AX_REQUIRE_PROG(sile)
    AX_REQUIRE_PROG(sponge)
    AX_REQUIRE_PROG(sqlite3)
    AX_REQUIRE_PROG(stat)
    AX_REQUIRE_PROG(truncate)
    AX_REQUIRE_PROG(wc)
    AX_REQUIRE_PROG(xcf2png)
    AX_REQUIRE_PROG(xvfb-run)
    AX_REQUIRE_PROG(yq)
    AX_REQUIRE_PROG(zint)
    AX_REQUIRE_PROG(zola)
    AX_REQUIRE_PROG(zsh)

    AC_MSG_CHECKING(whether pandoc has SILE Writer)
    AS_IF([$PANDOC --list-output-formats | $GREP -qx sile],[
        AC_MSG_RESULT(yes)
    ],[
        AC_MSG_FAILURE([pandoc must have sile writer support])
    ])

    # We actually need both 5.1 and 5.4 for most of these, but for now assume this is good enough
    AX_PROG_LUA(5.1, [], [], AC_MSG_ERROR([lua interpreter matching SILE's version is required]), [always])
    AX_LUA_MODULE(cldr)
    AX_LUA_MODULE(cosmo)
    AX_LUA_MODULE(decasify)
    AX_LUA_MODULE(fluent)
    AX_LUA_MODULE(lpeg)
    AX_LUA_MODULE(luautf8, lua-utf8)
    AX_LUA_MODULE(yaml)

    AX_LUA_MODULE(decasify.sile)
    AX_LUA_MODULE(ptable.sile)

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

])

AM_COND_IF([DEVELOPER_TOOLS], [
    AX_REQUIRE_PROG(cargo-set-version)
    AX_REQUIRE_PROG(checkmake)
    AX_REQUIRE_PROG(luacheck)
    AX_REQUIRE_PROG(ruff)
    AX_REQUIRE_PROG(stylua)
    AX_REQUIRE_PROG(taplo)
    AX_REQUIRE_PROG(tr)
    AX_REQUIRE_PROG(typos)
])

# Avoid the need for `--datarootdir=$(cd ..; pwd)` to run directly from
# an uninstalled build in the source directory
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

# Avoid the perceived need to run automake again when building from source
# tarballs. The assorted AM include macros assume two passes are needed to
# generate a makefile since one pass has to generate the includes and the
# second one inlines them, but we're distributing a ready-to-use version and
# hence one pass is enough. We can skip ahead and assume the Makefile template
# is ready to go an this point, avoiding the need for autotools at all.
AM_COND_IF([SOURCE_IS_DIST], [touch -r aminclude.am Makefile.in])
