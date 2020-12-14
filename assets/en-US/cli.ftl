help-description =
  The command line interface to the CaSILE toolkit,
  a book publishing workflow employing SILE and other wizardry

help-flags-debug =
  Enable debug mode flags

help-flags-language =
  Set language

help-flags-verbose =
  Enable verbose mode flags

# Currently hard coded, see clap issue #1880
help-subcommand-make =
  Build specified target(s) with ‘make’

# Currently hard coded, see clap issue #1880
help-subcommand-make-target =
  Target as defined by rules in CaSILE or project

help-subcommand-setup =
  Configure a publishing project repository

help-subcommand-setup-path =
  Path to book project repository

help-subcommand-status =
  Dump what we know about the repo

error-invalid-language =
  Could not parse BCP47 language tag.

error-invalid-resources =
  Could not find valid BCP47 resource files.

welcome =
  Welcome to CaSILE version { $version }!

make-header =
  Building target(s) using ‘make’

make-report-start =
  Starting make job for target: { $target }

make-report-end =
  Finished make job for target: { $target }

make-report-fail =
  Failed make job for target: { $target }

make-backlog-start =
  Dumping captured output of ‘make’

make-backlog-end =
  End dump

make-error-unknown-code =
  Make returned an action code CaSILE doesn't have a handler for.  The most
  likely cause is the shell helper script being out of sync with the CLI
  binary.  Needless to say this should not have happened. If you are not
  currently hacking on CaSILE itself please report this as a bug.

make-error =
  Failed to execute a subprocess for ‘make’.

make-error-unfinished =
  Make reported outdated targets were not built.

make-error-build =
  Make failed to parse or execute a build plan.

make-error-target =
  Make failed to execute a recipe.

make-error-unknown =
  Make returned unknown error.

setup-header =
  Setup CaSILE, “They said you were this great colossus!”

setup-error-not-git =
  Supplied path is not a Git repository.

setup-error-not-dir =
  Path is not a directory.

status-header =
  Project status report:

status-true =
  Yes

status-false =
  No

status-is-repo =
  Are we in a Git repository?

status-is-writable =
  Can we write to the project base directory?

status-is-make-executable =
 Can we execute the system's `make`?

status-is-make-gnu =
  Is the system's `make` GNU Make?

status-good =
  Everything is in place, it’s a happy CaSILE!

status-bad =
  Not everything is in place, please run `casile setup`.

