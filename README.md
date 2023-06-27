# CaSILE toolkit

[![Rust Test Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/casile/rust_test.yml?branch=master&label=Rust+Test&logo=Rust)](https://github.com/sile-typesetter/casile/actions?workflow=Rust+Test)
[![Docker Build Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/casile/deploy.yml?branch=master&label=Docker+Build&logo=Docker)](https://github.com/sile-typesetter/casile/pkgs/container/casile)
[![Rust Lint Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/casile/rust_lint.yml?branch=master&label=Rust+Lint&logo=Rust)](https://github.com/sile-typesetter/casile/actions?workflow=Rust+Lint)
[![Lua Lint Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/casile/luacheck.yml?branch=master&label=Luacheck&logo=Lua)](https://github.com/sile-typesetter/casile/actions?workflow=Luacheck)
![Reviewdog Lint Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/casile/shellcheck.yml?branch=master&label=Reviewdog&logo=eslint)<br />
[![Chat on Gitter](https://img.shields.io/gitter/room/sile-typesetter/casile?color=blue&label=Chat&logo=Gitter)](https://gitter.im/sile-typesetter/casile?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-blue.svg)](https://conventionalcommits.org)
[![Commitizen Friendly](https://img.shields.io/badge/Commitizen-friendly-blue.svg)](http://commitizen.github.io/cz-cli/)

The CaSILE toolkit is a build system that glues together a large collection of tools into a cohesive system that automates book publishing from start to finish.
The concept is to take very simple, easily edited content and configuration files as input and turn them into all the artifacts of a finished product with as little manual intervention as possible.
Plain text document formats and a small amount of meta data are transformed automatically into press ready PDFs, E-Books, and rendered promotional materials.

In traditional publishing workflows the closer a book is to production the harder becomes to work with.
The pipeline ‘narrows’ to more and more advanced (complex/expensive) software and more and more restricted access.
CaSILE completely eschews this limitation completely automating all the ‘later’ production stages.
By automating the production workflow from end to end all the normal sequence restrictions are removed.
Book exterior design can be done at any stage of the process.
Book interior design can be done at any stage of the process.
Copy editing can happen simultaneously by different editors on different parts of a book.
Because the pipeline doesn’t narrow as projects progress and the content is always front and center the only restrictions on the workflow are those dictated by *you* for the project, not by the tooling used.

CaSILE (pronounced /ˈkɑːs(ə)l/ just like ‘castle’) started out life as a submodule called `avadanlik` included inside my book project repositories (avadanlık being a Turkish word for something like a tackle box).
As most of the parts revolved around SILE, in my head at least CaSILE became **Caleb’in Avadanlığı birlikte SILE**, roughly translating to “SILE with Caleb’s Toolkit”.
Initially everything was hard coded in Turkish, but eventually I added localization for English and generalized most of the tooling so it can be used for books in nearly any language.

## Status

I’ve published dozens of books and other projects this way and have more in progress.
It’s now used by at least 3 publishing companies.
In other words it *Works for Me™* but your millage may vary.
This tool started out as just some scripts baked into one book project.
Then I worked on another book and copied the scripts over to get started.
When I hit book number 3, it dawned on me I should make my tools more modular and just include them in each project.
About this time I knew I wanted to open source it if it proved useful for more than one _type_ of book.
That day came and went.
One day I just decided to throw it out there so that it would be easier to explain what I was doing.
As such in many ways it is hard coded to my publishing needs any adaption to be more flexible only happens as people request or contribute the changes.

There are several different ways to use CaSILE, with or without installation.
Originally (through v0.2.x) CaSILE focused on use as a submodule to Git projects.
Beginning with v0.3.0 the primary focus has been on use as CLI tool completely separate from any project.

## Setup

CaSILE can be installed and run locally as a standard CLI program if you’re willing to setup the extensive list of [dependencies](#dependencies).

- Pros: Best (fastest) utilization of system hardware, ability to tinker with the dependencies as their own applications, shell goodies like autocompletion.
- Cons: System packages typically only support one version at a time, manual installation supports parallel versions but must be instantiated with the appropriate affix (.e.g. if installed with `./configure --program-suffix=-vN` then `casile make <target>` becomes `casile-vN make <target>`).

As an easier alternative to installing all the dependencies yourself, everything may be run prepackaged together [as a single Docker container](#docker-setup).

- Pros: No dependencies to setup and hence very easy to get started, easy to switch between versions including full matching dependency stack.
- Cons: Tricky to setup access to fonts or other resources available outside your project source, some overhead in startup time and reduced CPU and memory resources.

In addition to being run locally, CaSILE can also be run from nearly any remote CI platform.
If your book project is on GitHub, you can [add CaSILE to any workflow](#github-action-setup) as a GitHub [Action](https://github.com/marketplace/actions/casile).
If your book project is hosted on GitLab, you can easily [configure it to run in GitLab CI](#gitlab-ci-setup).

- Pros: Nothing to download or install locally, easy to share the results of each build.
- Cons: Long turn around time, must push repository to a supported remote host.

Of course it is also possible to mix and match.

### Local Native Setup

If you happen to be using Arch Linux the [casile][aur-casile] package on the AUR is all you need.
Also a [casile-git][aur-casile-git] recipe is available, and packages (including all dependencies) can be installed directly from [this repo][arch-alerque]) for easy setup.
For any other platform you’ll either need to be up for an adventure, see [building from source](#building-from-source) (or just use Docker).
It is possible to run on macOS if you spend some time pulling in dependencies from Homebrew and elsewhere.
Windows support will almost certainly require considerable monkey business; [not my circus, not my monkeys][nmcnmm].

### Local Docker Setup

Use of a Docker container can make it a lot easier to get up and running because you won’t need to have a huge collection of dependencies installed.
Ready made containers are available from either [Docker Hub][dockerhub] or [GitHub Container Registry][ghcr].
Download (or update) an image using  `docker pull docker.io/siletypesetter/casile:latest` or `docker pull ghcr.io/sile-typesetter/casile:latest`.
Note *latest* will be the most recent stable tagged release, or you may substitute a specific tag (e.g. *vX.Y.Z*), *master* for the more recent Git commit build, or `v0` for the more recent tagged release in that major series.

Optionally you may build a docker image yourself.
From any CasILE source directory (a Git clone extracted source package), configure using `./configure --disable-dependency-checks`, then build using `make docker`.
The resulting image will be available on your system as `sile-typesetter/casile:HEAD`.

In order to invoke CasILE from Docker you need to pass in your project files on a volume that will also serve as a place it can write it’s output.
The full Docker run command can be substituted anywhere you would invoke CaSILE.
For convenience you’ll probably want to give yourself an alias:

```bash
alias casile='docker run -it --volume "$(pwd):/data" ghcr.io/sile-typesetter/casile:latest
```

Save this in your shell’s rc file (e.g. `~/.bashrc`) to persist the alias.
This substitution should work anywhere and with any arguments you would have run `casile` for.

### GitHub Action Setup

Use as an Action follows the traditional GitHub Action configuration pattern.
You can specify the exact version you want, `v0` for the most recent tagged release in the same major version sequence, `latest` far the very latest tagged release of any sequence, or `master` for the latest development build.

```yaml
- name: CaSILE
  uses: sile-typesetter/casile@latest
```

If no arguments are passed, by the Action will default to running `casile make -- default`.
You can pass your own arguments using the `args` input parameter.
The `DISTDIR` value is output automatically and can be used to post artifacts from your build.
A complete workflow example `.github/workflows/casile.yml` with customized targets and artifact posting might look like this:

```yaml
name: CaSILE
on: [push, pull_request]
jobs:
  casile:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - id: casile
        uses: sile-typesetter/casile@latest
        with:
          args: make -- pdfs epub renderings
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: ${{ steps.casile.outputs.DISTDIR }}
          path: ${{ steps.casile.outputs.DISTDIR }}
```

Another useful paradigm is to run your steps inside the container:

```yaml
name: CaSILE
on: [push, pull_request]
jobs:
  casile:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/sile-typesetter/casile:latest
      options: --entrypoint=bash
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: make
        run: |
          casile make -- pdfs epub renderings
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: pub
          path: pub
```

If you are just starting from scratch, consider using the [casile-template][template] repository to initialize your project.
For more ideas and complex examples, check out the [casile-demos][demos] repository.

### GitLab CI Setup

Setup your job to use the CaSILE image and version of your choice, but disable the default entry point:

```yaml
image:
  name: "siletypesetter/casile:latest"
  entrypoint: [""]
script:
  - casile make
```

Unfortunately GitLab CI can’t name artifacts dynamically (see [upstream report](https://gitlab.com/gitlab-org/gitlab/-/issues/17096)), so you’ll need to define the `DISTDIR` variable yourself.
A complete pipeline example `.gitlab-ci.yaml` with customized targets and artifact posting might look like this:

```yaml
default:
  image:
    name: "siletypesetter/casile:latest"
    entrypoint: [""]
variables:
  DISTDIR: $CI_PROJECT_NAME-$CI_JOB_NAME_SLUG-$CI_COMMIT_SHORT_SHA
casile:
  script:
    - casile make -- pdfs epub renderings
  artifacts:
    name: $DISTDIR
    paths: [ ./$DISTDIR/* ]
```

### Dependencies

*Note if you use any of the distro packages, Docker containers, or CI configurations listed in [Setup](#setup) you don't need to worry about these dependencies.*

CaSILE glues together *a lot* of different open source tools to assemble a complete publishing tool chain.
Behind the scenes this is very messy business.
In order to make everything work I’ve had to use an eclectic variety of software.
All of these are open source and available across platforms, but I only personally test on Linux.

All of the following are utilized in one way or another.
Currently the toolkit assumes all the following are present, but as not all of them are used to build all resources it could be possible to make this more selective.
For example not having the ray tracing engine would just mean no fancy 3D previews of book covers, but you could still build PDFs and other digital formats.
Not having Node would mean no Bible verse format normalization, but you should still be able to build books.
Not having ImageMagick would mean no cover images, but you could still process the interior of books.
On the other hand not having GNU Make, Pandoc, or SILE would of course be fatal.

* The [SILE][sile] Typesetter is the workhorse behind most of the text layout.
  Tagged releases of CaSILE should work with latest released version of SILE, git versions may assume the latest Git HEAD versions of SILE.
* [Pandoc][pandoc] (specifically with [my branch with SILE support][pandocsile]) converts between document types.
* [ImageMagick][im] handles raster image processing (v7+ required).
* [POVRay][pov] is used to render 3 dimensional visualizations.
* [Inkscape][inkscape] is used to layout some cover resources and to convert SVG resources into other formats.
* [PDFTk][pdftk] is used to manipulate PDFs.
* [Podofo][podofo] is used to do more stuff with PDFs.
* [Kindlegen][kindlegen] is needed to generate Amazon’s E-Book formats.
* [Poppler][poppler] is used to do even more stuff with PDFs.
* [Zint][zint] generates ISBN barcodes, QR codes, etc.
* Perl, Python, Lua, Node, Zsh, and a few other language interpreters!
* Various modules for those languages like `lua-yaml`, `python-ruamel`, `python-isblib`, and `python-pandocfilters`.
* Up to date versions of assorted shell tools like `jq`, `yq`, `entr`, `bc`, and `sqlite`.
* The CLI utility variant of [git-warp-time][git-warp-time] (the library variant is also used by Cargo at build time).
* GNU Make (and assorted other GNU tools) glue everything together.
* The default book templates assume system installed versions of **Hack**, **Libertinus**, and **TeX Gyre** font sets.
* Some other stuff (`./configure` will warn you if your system doesn’t have something that’s required).

In addition to run-time dependencies, compiling the CLI interface (optional) requires a Rust build toolchain.
Once built the CLI requires no dependencies to run.

Until other distros have packages, perhaps the most definitive list of dependencies is the Arch Linux [package meta-dataa](https://aur.archlinux.org/cgit/aur.git/tree/.SRCINFO?h=casile-git).
You will need to translate the package names for your platform but everything is listed there.

### Companion tools

You’ll probably want some other things not provided by CaSILE as well.
CaSILE takes care of transforming sources to finished outputs, but leaves you to edit the sources and view the outputs yourself.
For starters a text editor for working with Markdown & YAML sources will be a must-have.
Options abound here and are mostly out of scope, but think Marktext, Zettlr, Atom, VSCode, Sublime, Vim, etc.
CaSILE also assumes your book project is tracked in Git, so a client such as the CLI tools or a GUI like GitAhead, Fork, Sourcetree, GitKraken, Tower, or a plugin specific to your editor of choice is a must-have.
Of course you’ll want a way to view generated PDFs.
I recommend one that auto updates on file changes; I use [zathura][zathura]), but Okular and quite a few others also support this.
An image viewer and an E-Book reader like [Calibre][calibre] are also useful.

### Building from Source

1. Clone the Git repository or download and extract a source archive or source release package.

2. Change to the directory, configure for your system, and build the tools:

    ```console
    # Only for git clones or source archives...
    $ ./bootstrap.sh

    # Configure & build
    $ ./configure
    $ make
    ```

    ```console
    $ make install
    ```

    Note if you don't plan to install to your system but would like to compile and run from the source directory (e.g. for development work on CaSILE itself), use `./configure --datarootdir=$(cd ..;pwd); make -B`, then add the CasILE source directory to your `$PATH`.

## Input

CaSILE makes a number of assumptions about the content of your project repository, but how exactly you organize your git repos is still flexible.
For example I have some single books in their own repositories, some series of books where the repository holds the whole series, others with different books with the same publisher/copyright status lumped together (and worked on in branches), a set of tracts by assorted authors but published together in another repository, etc.
CaSILE assumes there is some relation between sources in each repository so granular repositores give more complete control, but each resource in a single repository can also be customized.
You’ll have to consider your own workflow and how projects share resources.
Note that common resources, say defaults for a publisher, can be shared in another submodule(s).

A book project would minimally consist of at least the following:

* casile.mk
* my_book.md
* my_book.yml

There might be more related assets of course, for example a cover background image:

* my_book-background.png

Optionally books may be split into chapters:

* my_book.md
* my_book-chapters/000-preface.md
* my_book-chapters/001-chapterone.md
* my_book-chapters/002-chaptertwo.md

## Output

In return, CaSILE will output

* Press ready PDFs (high resolution, full bleed w/ crop marks) for the specified press format...
  * my_book-a5-paperback.pdf
  * my_book-a5-paperback-cover.pdf
* User friendly PDFs (normal resolution, indexed, hyperlinked) for any specified size...
  * my_book-a4-print.pdf
* Promotional images based on the cover...
  * my_book-a5-front_cover.jpg
  * my_book-square-cover.jpg
* 3D renderings of finished book...
  * my_book-a5-paperback-3d-front.jpg
  * my_book-a5-paperback-3d-back.jpg
  * my_book-a5-paperback-3d-stacks.jpg
* E-Book formats...
  * my_book.epub
  * my_book.mobi

## Usage

Build whatever resources you need.
Assuming you have a book source file `my_book.md` and accompanying meta data at `my_book.yml`, the general syntax for generating resources would be:

        $ casile make -- my_book-<layout>-<options>.<format>

    For example to build the press ready PDF for an Octavo size version:

        $ casile make -- my_book-octavo-hardback-cover.pdf

    Or to build a 3D rendering of the front cover at Halfletter size:

        $ casile make -- my_book-halfletter-paperback-3d-front.jpg

See also the [CaSILE demos][demos] repository for a sample book project layout.

### Settings

CaSILE has a lot of knobs to fiddle with, and almost anything can be changed.
The main trick is understanding where to make changes, because order matters.

As a broad overview from least specific to most:

* Compile time discovery.

  When CaSILE is configured it runs a bunch of discovery operations (during `./configure`).
  These detect where dependencies are installed and what versions they are.
  These can also be manually defined if you wish to substitute some program.

  This stage also generally sets up *where* CasILE will be run from.
  The configure stage reviews the system for where the package will be installed so it knows where to find itself.

* Baked in run time defaults.

  All settings have some default value baked in that will be used if nothing later overrides them.

* Project rules file.

  Each project may have one or more rules files that are injected intact into the GNU Make runtime. The filename `casile.mk` is suggested, but `rules.mk`, `Makefile`, `makefile`, and `GNUMakeFile` are also considered.

  Your project rules file is easily the most technical way to tie in, and Make’s syntax is often confusing.
  Many projects will not need this at all –or use it only for simple variable assignments– but almost anything goes.

* Publisher rules file.

  *to be implemented*

* Publisher mata data.

  *to be implemented*

* Project meta data.

  Each project is expected to have a main meta data file in YAML format.
  The file name should match the project name, which is usually the same name as the git repository directory.

* Book meta data.

  Each book in a project is expected to have a meta data file with book specific information.
  
  Note for projects with a single book, this may be the same as the project meta data file.

* Project CaSILE settings file.

  Each project may have a YAML file defining settings that override the defaults and save having to pass them manually on each invocation.

* Run time environment variables.

  Many settings can be set an environment variables and will be considered for each invocation of the CLI.

* Run time flags.

  Some settings have CLI flags that will override any other settings.

#### Project parameters

Most settings apply to a whole project (repository).
To override the defaults set them in your project’s `casile.mk`


* `LANGUAGE` sets the language for localized file names.

    The default is English, so you might run `casile make -- book-halfletter-3d-front.png`.
    Changing this to Turkish:

        LANGUAGE = tr

    will mean the command you run should be `casile make -- kitap-a5-3b-on.png` to generate the same resource for a similar project with localized filenames.
    At this time localizations are only included for Turkish, but they are easy enough to add to your project.
    Submitting them upstream would also me much appreciated.

* `TARGETS` is a list of all the books in a project.

    By default this is set by scanning the project directory and finding all the Markdown files that have matching YAML meta data files of the same name.
    This helps dodge things like `README.md` files that are not the focus of the meat of a project.
    You can manually set this with a list:

        TARGETS = book_1 book_2

    Or perhaps populate it with a list of _all_ markdown files.
    You don’t want the extentions here, just the basenames of books to be built:

        TARGETS = $(basename $(wildcard *.md))

* `PROJECT` is the name of the overall project (which might contain several books or other works).

    This defaults to the name of the repository directory.

        PROJECT = series_name

* `CASILEDIR` is where CaSILE is located.
    Path from which shared resource files are loaded from.
    Typically the value set automatically based on the CaSILE installation will be sufficient.
    This is mostly useful for doing development work on CaSILE itself.

* `PROJECTDIR` is where your project is located.
    Sources will be examined here and the build process will run here.

    Defaults to the root of the current Git repository.
    It is unlikely you would ever want to change this.

* `DISTDIR` determines where published files will be placed.

    Ouput files are first created in the current project directory alongside sources.
    Optionally CaSILE can ‘install’ finished resources to some other location.

        DISTDIR = /path/to/pub/$(PROJECT)

* `FORMATS` contains a list of output formats to build for from each input.

    By default this is set to `pdf epub`, but you may want to build less or more that this.
    To built "the works":

        FORMATS = pdf epub mobi odt docx app

    Note this only affects the formats that get built by default from the `default` or `all` targets, you can still build individual resources in any format manually withouth them being listed here.

* `BLEED` sets the bleed margin for press resources in mm.

    Defaults to 3.

        BLEED = 5

* `TRIM` sets the trim margin for press resources in mm.

    Defaults to 10.

        TRIM = 15

* `PAPERWEIGHT` sets the paperweight (in grams) used to calculate book thickness and hence spine width.

    Defaults to 60.

        PAPERWEIGHT = 80

* `COVERGRAVITY` tells the cover generator what direction to crop background images when adjusting for different aspect ration.

    Defaults to Center.
    Possible options are anything that ImageMagick understands, so South, SouthWest, NorthEast, etc.

        COVERGRAVITY = North

#### Build time settings

These settings are usually not changed except at run time.
You _may_ set them in your rules file such as `casile.mk` but they would typically be set as environment variables or on the command line to get other-than-default behaviour for a specific build.

* `DRAFT` enables draft mode builds for faster testing.

    This defaults to false, but may be set to true when executing make:

        casile make -- DRAFT=true book-a4-binding.pdf

    What this does will depend on the resource type.
    Books are only typeset in one pass, so TOC’s may be out of date, cover images are generated at 17th final resolution, 3D renderings are done with partial lighting for faster ray-tracing, etc.

    Note that `casile make -- watch ...` automatically enables this mode.

* `HIGHLIGHT_DIFF` enables highlighting differences between git branches.READ

    Defaults to false.

    Note this works in congunction with the `PARENT` variable.
    When pre-processing the source of books, the current commit will be comared to the branch (or commit) defined by PARENT.
    Any differences (at the character level) will be marked up using CriticMarkup sytax.
    Some output formats (notably PDF) will syntax highlight any additions/removals.

* `STATSMONTHS` sets the default time frame to report on activity.

    Defaults to 1.

    At the end of each month I run `casile make -- stats` to run a report of all commit activity on the content of books.
    This computes the current character and word counts and compares them with each previous commit and shows a report crediting the author of that commit.
    I use this to pay our translators, editors, etc.

    Override with `casile make -- STATSMONTHS=2 stats`.


* `DEBUG` enables extra output from various programs showing whats going on durring a build.

    Defaults to false, set to true to enable.

    This will be pretty verbose on the console.
    Shell scripts will run with `set -x`, programs that have them will be run with debug flags turned on, etc.

* `SILEDEBUG` sets the specific parts of the SILE typesetter to debug.
    See SILE documentation for details.

    Defaults to casile.

        SILEDEBUG = casile insertions frames

    Usage from the command line might be `casile make -- DEBUG=true SILEDEBUG=frames book-a4.pdf`.

* `COVERS` can be used to disable generating cover images.
    Raster image generation can take time, this skips those steps and just assumes no graphical covers are present.

    Defaults to true, set to false to disable.

* `HEAD` sets how many lines of input books to process.

    Default is unset.

    If setting this to an integer, only that many lines of an input book will be processed.
    This is useful when styling a book.
    You can work on the first chapter worth of lines and rebuild the book quickly, then turn it off to regenerate the whole book.

        casile make -- HEAD=50 book-octavo.pdf

* `SCALE` sets the factor by which to downsample resources while in draft mode.

    Defaults to 17. This brings 1200 dpi print resources down to 70 dpi.

* `HIDPI` sets the output resolution for press resources.

    Defaults to 1200 with scaling for draft mode enabled.

    This may be set to an another value with or without scaling.
    For example for a one off command you might run:

        casile make -- HIDPI=600 book-octavo-binding.pdf

    But to change the project default you might set this in your rules file:

        HIDPI = $(call scale,600)

* `LODPI` is much the same as `HIDPI` but used for regular discribution resources.

    Defaults to 300 with scaling for draft mode enabled.

#### Hooks

These are functions that can be defined in your project’s `Makefile` to add additionaly funtionality at various points in the process.
You make use either single or multiline syntax as desired, but note the input, output, and variables passed will be the same either way.
On the other hand each hook has its own usage so note the context it runs in.

[arch-alerque]: https://wiki.archlinux.org/index.php/Unofficial_user_repositories#alerque
[aur-casile-git]: https://aur.archlinux.org/packages/casile-git/
[aur-casile]: https://aur.archlinux.org/packages/casile/
[calibre]: http://calibre-ebook.com/
[demos]: https://github.com/sile-typesetter/casile-demos
[dockerhub]: https://hub.docker.com/repository/docker/siletypesetter/casile/
[ghcr]: https://github.com/orgs/sile-typesetter/packages/container/package/casile
[git-warp-time]: https://crates.io/crates/git-warp-time
[im]: http://imagemagick.org/
[inkscape]: https://inkscape.org/
[kindlegen]: https://www.amazon.com/gp/feature.html?docId=1000234621
[nmcnmm]: https://duckduckgo.com/?q=%22Not+My+Circus%2C+Not+My+Monkeys%22&ia=images
[pandoc]: http://pandoc.org/
[pandocsile]: https://github.com/jgm/pandoc/pull/6088
[pdftk]: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
[podofo]: http://podofo.sourceforge.net/
[poppler]: https://poppler.freedesktop.org/
[pov]: http://www.povray.org/
[sile]: https://sile-typesetter.org
[tempalte]: https://github.com/sile-typesetter/casile-template
[zathura]: https://pwmt.org/projects/zathura/
[zint]: https://zint.github.io/
