AC_INIT([casile],
        m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [caleb@alerque.com])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_SILENT_RULES([yes])

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

AC_SUBST([RUST_TARGET_SUBDIR])

AC_CONFIG_FILES([Makefile])

AC_OUTPUT
