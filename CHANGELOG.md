# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [0.2.0](https://github.com/sile-typesetter/casile/compare/v0.1.0...v0.2.0) (2020-04-23)

This release tag is to mark a point before I start moving all the cheese. The biggest change from previous releases is the Docker image with all the right dependencies to run CaSILE on any platform.

### Features

* Add Pandoc built with SILE-Writer to Docker ([9434759](https://github.com/sile-typesetter/casile/commit/9434759616a590b09fda00be03cc7dc8a9967f95))
* Add root as Lua search path, enables some CI usage ([831b9ae](https://github.com/sile-typesetter/casile/commit/831b9ae1a8c0ee4a5aa4bb93eb2f900c342319ec))
* Allow overriding the python executable ([1b220fa](https://github.com/sile-typesetter/casile/commit/1b220fae56270d27c96623fef0901b62cf625615))
* Introduce commitlint tooling for normalized releases ([4ac0262](https://github.com/sile-typesetter/casile/commit/4ac026246c917933d966ea1cc1df0d6467393e98))


### Bug Fixes

* **docker:** Work around fresh GNU coreutils bombing Docker Hub ([#53](https://github.com/sile-typesetter/casile/issues/53)) ([3a7e67d](https://github.com/sile-typesetter/casile/commit/3a7e67dcd4cbd24fc3fbba758d5d23c0d9ac2a08))
* Cast setback to length no matter what comes in ([1a868ec](https://github.com/sile-typesetter/casile/commit/1a868ec8df4362a2981ebf873318fa9d5fea0fbd))
* Mark file-per-chapter markdown sources as dependencies for book ([b0ad0db](https://github.com/sile-typesetter/casile/commit/b0ad0dbec11bbbf277f850872fdb592e775bcee9))
* Remove hard coded TR language tag from back cover template ([10f2ef7](https://github.com/sile-typesetter/casile/commit/10f2ef7935908e98d17577c0635561685d7e262f))
* **core:** Fix compatability with GNU Make >= 4.3 ([2465ce4](https://github.com/sile-typesetter/casile/commit/2465ce439acf30ff17b711879db0fbcfbc04d88f))
* **core:** Fix parallel job defaults now working in GNU-Make >= 4.3 ([74a389c](https://github.com/sile-typesetter/casile/commit/74a389ce1c125e0beb383b248bf977751f9f503a))
* **core:** Match SILE 0.10.x interface for typesetter ([bd72cc4](https://github.com/sile-typesetter/casile/commit/bd72cc4670fb61b034fbbd334b178b21c23576a2))
* **docker:** Disable policy check prohibiting GhostScript actions ([d621ba2](https://github.com/sile-typesetter/casile/commit/d621ba2d6fe61f620dbb12987b1c76fb2d465cb7))
* **style:** Overhaul font scaling ([f701b97](https://github.com/sile-typesetter/casile/commit/f701b97df452f4d46838ab75ec130536c2791a00)), closes [#50](https://github.com/sile-typesetter/casile/issues/50)
* **template:** Center rule under chapter headings ([#49](https://github.com/sile-typesetter/casile/issues/49)) ([cca7eda](https://github.com/sile-typesetter/casile/commit/cca7eda3eedadef5298878cf3063319f1cd2b0d5))
* Formats list uses plural 'pdfs' avoid circular dependency isssues ([fde99ce](https://github.com/sile-typesetter/casile/commit/fde99ce949f5704b0f288fdcb125a61bee56720f))
* Handle jq changes in null no epub builds with no meta data again ([2373508](https://github.com/sile-typesetter/casile/commit/23735086b6be3c72fbec5e2c92a03052e68ddbb4))
* Move executable overrides to before possible usages ([3adaaf6](https://github.com/sile-typesetter/casile/commit/3adaaf601ab17f6b6b84830c49578c3aed2c7384))
* Recent ImageMagick won't let us be naive any more ([05e221a](https://github.com/sile-typesetter/casile/commit/05e221a2d5a12d20bb7000ae85b99d01140e5a06))
* Remove circular (and unused) dependency for print layouts ([42f190c](https://github.com/sile-typesetter/casile/commit/42f190c48a10117b44e83fbbcdded31ed8ff5f90))
* Remove circular dependency trap for non-bound layouts ([b7f0d54](https://github.com/sile-typesetter/casile/commit/b7f0d54d44313f07ec142f917a5ddcfdfd26ed5a))
* Set quote setbacks in a way that works with sile 0.10.x ([a1d6571](https://github.com/sile-typesetter/casile/commit/a1d65715d0039e7d4b8ceb1b88cc61f003cd8da7))

## [0.1.0](https://github.com/sile-typesetter/casile/compare/v0.0.0...v0.1.0) (2020-01-18)

Moved project into the sile-typesetter namespace. At this point the toolkit is pretty mature and has been used for a couple dozen production projects and works for unmodified across all of them. It is very picky about how things are setup in the project and not very easy to get started with.

## [0.0.0](https://github.com/sile-typesetter/casile/compare/7d2cc11...v0.0.0) (2017-01-19)

Add first release tag just to document the state of affaris. At this point the toolkit has been used for several production projects, but always with a good deal of fiddling for each one.
