# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## [0.14.9](https://github.com/sile-typesetter/casile/compare/v0.14.8...v0.14.9) (2025-03-20)


### New Features

* **docker:** Build image with SILE v0.15.10 from upstream Arch Linux ([18f4b83](https://github.com/sile-typesetter/casile/commit/18f4b83e8ed6b9047a0d017753a1ea8c2decdd2a))

## [0.14.8](https://github.com/sile-typesetter/casile/compare/v0.14.7...v0.14.8) (2025-01-25)


### New Features

* **deps:** Update git2 crate to enable build against libgit2-1.9 ([7f51dd8](https://github.com/sile-typesetter/casile/commit/7f51dd8c8266313fcf1177c10d082a5e3de40512))


### Bug Fixes

* **covers:** Generate bindings with guides at final bounding size, dodge Inkscape bugs ([b44b865](https://github.com/sile-typesetter/casile/commit/b44b865f18c4f83e241ba6d4818bca64ef5ef285))

## [0.14.7](https://github.com/sile-typesetter/casile/compare/v0.14.6...v0.14.7) (2025-01-04)


### New Features

* **docker:** Build image with SILE v0.15.9 from upstream Arch Linux ([b13c4bb](https://github.com/sile-typesetter/casile/commit/b13c4bb048edca6a6a481c1a1e6203b2274a7749))


### Bug Fixes

* **build:** Set correct final permissions on intermediary shell completion artifacts ([a9be4e6](https://github.com/sile-typesetter/casile/commit/a9be4e6ab789b786cabf2b754776eec7850dda42))
* **rules:** Use un-deduplicated list so we catch top level content if used ([b506108](https://github.com/sile-typesetter/casile/commit/b50610863a307f3d0d5f36795e7c12b43f689ffb))

## [0.14.6](https://github.com/sile-typesetter/casile/compare/v0.14.5...v0.14.6) (2024-12-12)


### New Features

* **docker:** Build image with SILE v0.15.8 from upstream Arch Linux ([9d6ffd9](https://github.com/sile-typesetter/casile/commit/9d6ffd9b13f4ebf68577821bc006cf4e2de8dfb3))


### Bug Fixes

* **build:** Don't expect Lua if we're not using it ([5ada61d](https://github.com/sile-typesetter/casile/commit/5ada61d8ed15e0c8a1258089323e5fe471beb728))
* **build:** Fix typo in autoconf macro, actually depend on lua dep checks ([ff173e8](https://github.com/sile-typesetter/casile/commit/ff173e8ea42186d94394320cdc143b6fc3e7998b))
* **build:** Put developer tool checks behind related conditional ([40e05c6](https://github.com/sile-typesetter/casile/commit/40e05c6434cc117c209f5ba9b55dc2ca7c27f05d))
* **build:** Work around macros hoisting outside of conditional ([2d4ffd6](https://github.com/sile-typesetter/casile/commit/2d4ffd69157a2aa7819e789eb6c000892128f29a))
* **i18n:** Sync forked loadLanguage() from SILE v0.15.7 ([dd872ab](https://github.com/sile-typesetter/casile/commit/dd872ab3cae753df3baef8d52279eb91340aa345))

## [0.14.5](https://github.com/sile-typesetter/casile/compare/v0.14.4...v0.14.5) (2024-11-26)


### New Features

* **deps:** Make @Omikhleia's ptable package available by default ([0c3ebb7](https://github.com/sile-typesetter/casile/commit/0c3ebb7cefa7927b9138930951ced992f7a2b610))
* **docker:** Build image with SILE v0.15.7 from upstream Arch Linux ([f6b123b](https://github.com/sile-typesetter/casile/commit/f6b123be74ca019135c72df8cf40fce838f1d700))

## [0.14.4](https://github.com/sile-typesetter/casile/compare/v0.14.3...v0.14.4) (2024-11-14)


### New Features

* **docker:** Build image with SILE v0.15.6 from upstream Arch Linux ([719e330](https://github.com/sile-typesetter/casile/commit/719e330ccefc1fd5d207182b6951fe8e12a4daab))
* **import:** Add filter to guess headings from docx input ([f0aa6d7](https://github.com/sile-typesetter/casile/commit/f0aa6d75cf981729742ac2c292f51fbfb957ed3b))
* **import:** Assume italicized blockquotes are redundant inline formatting ([55a86ee](https://github.com/sile-typesetter/casile/commit/55a86ee79c62827e6269c81269eb8099f849feec))
* **import:** Setup DOCX import path ([5491eb0](https://github.com/sile-typesetter/casile/commit/5491eb0c7e9fed0fa3a1572fbde6074d9c9818d6))
* **packages:** Provide SILE decasify package ([12efab6](https://github.com/sile-typesetter/casile/commit/12efab6fae05f909187b74a9502cde5413653f5b))


### Bug Fixes

* **filters:** Keep TR verse abbreviations from wrapping sentences ([df925a1](https://github.com/sile-typesetter/casile/commit/df925a13f27785761f12f2ed62a1b10da25045bb))
* **import:** Don't nuke styling code when re-importing text ([bdd24e8](https://github.com/sile-typesetter/casile/commit/bdd24e8cd9507926260319641f2c4c5b4897e1c1))
* **mdbook:** Handle generation of mdbook when book has more than 1 primary author ([718fab2](https://github.com/sile-typesetter/casile/commit/718fab2c56e837eb9a975228757096354445f318))
* **rules:** Use tail instead of head to not truncate pipeline ([aa4c4a3](https://github.com/sile-typesetter/casile/commit/aa4c4a3a661ce957f0d0a54a84252e855c1e98f4))
* **scripts:** Make sure GNU parallel inherits full path of shell ([840cbd5](https://github.com/sile-typesetter/casile/commit/840cbd5b796eeb1d27e36ec90cd0748f4c773768))
* **utilities:** Avoid false positives upgrading SILE settings API stuff ([a4dd7b0](https://github.com/sile-typesetter/casile/commit/a4dd7b0638e93a6cace052d913916787a6a20a54))

## [0.14.3](https://github.com/sile-typesetter/casile/compare/v0.14.2...v0.14.3) (2024-09-23)


### Bug Fixes

* **action:** Work around GH's Action marketplace syntax quoting shell args ([b82591f](https://github.com/sile-typesetter/casile/commit/b82591fc450dc7540b2ab070a2bfda3d0d368e1c))
* **rules:** Update method of passing GitHub CI variables to current API ([dfb4b3d](https://github.com/sile-typesetter/casile/commit/dfb4b3d16220d7eaec6687a7df825ab3985e78ad))

## [0.14.2](https://github.com/sile-typesetter/casile/compare/v0.14.1...v0.14.2) (2024-09-05)


### New Features

* **cli:** Setup editorconfig on project setup ([43cfac4](https://github.com/sile-typesetter/casile/commit/43cfac4f18d38e3436fa2f5bca1d18de7c50dec8))
* **cli:** Setup Lua LSP config in project setup ([c3f8304](https://github.com/sile-typesetter/casile/commit/c3f8304f0315c72e5b9d4e332d1f97112a0c4ec5))
* **cli:** Setup Luacheck config in project setup ([e03b1f0](https://github.com/sile-typesetter/casile/commit/e03b1f0adb0c3566360dfe1769f40c8c635aab10))


### Bug Fixes

* **ebooks:** Fix Google Play Books metadata generation with empty sources and subtitles ([2fa6798](https://github.com/sile-typesetter/casile/commit/2fa6798ae169f20ca62fab61b2830529b7ae454e))
* **ebooks:** Fix handling of ISBN input as number or text ([d10ee84](https://github.com/sile-typesetter/casile/commit/d10ee842cff1bdcea7b87bb15856eb22500f3823))
* **layouts:** Fixup halfletter frameset in new class design ([a6ac22d](https://github.com/sile-typesetter/casile/commit/a6ac22d6b737845a72f23095211537cc8a174496))
* **layouts:** Fixup octavo and royaloctavo framesets in new class design ([63a0098](https://github.com/sile-typesetter/casile/commit/63a0098df9155dc4fbc1c6a47879f8c32476aa12))
* **mdbook:** Correctly apply pandoc filter arguments ([3cf8f89](https://github.com/sile-typesetter/casile/commit/3cf8f89de4ca9dfe1f479005fb62c91d425115eb))
* **rules:** Fixup argument errors when exporting to odt ([c6b70cd](https://github.com/sile-typesetter/casile/commit/c6b70cd023082508177aefe819e11ec344e84632))

## [0.14.1](https://github.com/sile-typesetter/casile/compare/v0.14.0...v0.14.1) (2024-08-31)


### New Features

* **utilities:** Add utility function to simplify adding toolkits to projects ([23aadc7](https://github.com/sile-typesetter/casile/commit/23aadc7beda69185774bec09f3c7866d06679dd1))


### Bug Fixes

* **build:** Avoid the perceived need for an extra automake cycle in dist tarball ([43814e9](https://github.com/sile-typesetter/casile/commit/43814e9e96cc011efaa362c5cc2a3252b447ee8a))
* **rules:** Fix project-local font directory handling ([098ad34](https://github.com/sile-typesetter/casile/commit/098ad34b51c49d678a704ed71f0bcbcd231e54b8))

## [0.14.0](https://github.com/sile-typesetter/casile/compare/v0.13.4...v0.14.0) (2024-08-29)


### ⚠ BREAKING CHANGES

* **scripts:** Books with split source files are now compiled
automatically without the loadchapters macro shenanigans. This requires
the sources to be sortable and any interleaved content needs to be in
sequential files.
* **rules:** The $(BUILDDIR) vaiable used in many make targets can
no longer by set by make rules, it must be set via the builddir option
via YAML configs or ENV vars. This makes it easier to use in scripts
that may not run as a child process of make.
* **cli:** Rename 'path' argument to 'project'

### New Features

* **cli:** Add passthrough mode to interface ([3bc8b08](https://github.com/sile-typesetter/casile/commit/3bc8b08bdf3f971be5066096ab2f42776d04721f))
* **cli:** Add type hints for autocompletion of some args ([801f566](https://github.com/sile-typesetter/casile/commit/801f56699e5cbf4f184c1af57ab1862cf03cd24e))
* **filters:** Add filter to format Markdown with line-per-sentence ([48ec935](https://github.com/sile-typesetter/casile/commit/48ec93589441d4305e9ef30dc618bb85ff258f9b))
* **filters:** Add some English language smarts to sentence wrapper ([8d4001b](https://github.com/sile-typesetter/casile/commit/8d4001ba74e7a724e700e2068838b7d731f22434))
* **filters:** Add Turkish language smarts to sentence wrapper, closes [#170](https://github.com/sile-typesetter/casile/issues/170) ([af4a32e](https://github.com/sile-typesetter/casile/commit/af4a32e155c799224892101f053c82441f4050e0))
* **filters:** Catch English dates as exception to sentence filter ([3b222aa](https://github.com/sile-typesetter/casile/commit/3b222aa779fd9789b5467dfb55d2722b342c29fb))
* **filters:** Catch sentance-leading abreviations in Turkish so footnotes don't wrap ([9c6ad26](https://github.com/sile-typesetter/casile/commit/9c6ad26599d2f3e594c126aba0e0022a7e1d4a7a))
* **filters:** Extend sentence wrapping to catch quotations ([e031a7d](https://github.com/sile-typesetter/casile/commit/e031a7d565ad8886f5c0005e567a601f015eeacb))
* **filters:** Extend sentence wrapping to more block types ([6f8df04](https://github.com/sile-typesetter/casile/commit/6f8df04d037aabb91b3f3fce412c522266dd75e0))
* **import:** Add Lua filter for reading unformatted text ([f2dfc14](https://github.com/sile-typesetter/casile/commit/f2dfc1478e212f181027cf351653e6742019610d)), closes [/github.com/jgm/pandoc/issues/6393#issuecomment-962694810](https://github.com/sile-typesetter//github.com/jgm/pandoc/issues/6393/issues/issuecomment-962694810)
* **import:** Add part and rough epigraph handling ([22c2631](https://github.com/sile-typesetter/casile/commit/22c263144d07576071f9de3293a50be8b0e7b7ee))
* **import:** Add script for importing other formats ([da48c14](https://github.com/sile-typesetter/casile/commit/da48c144d6c06d9fb9134e9d44e41b80012afdef))
* **rules:** Add intermediate processing for easy access to flattened markdown ([993f5b4](https://github.com/sile-typesetter/casile/commit/993f5b40588ec636fc6b353994f10e5a59fb389e))
* **rules:** Start wrapping paragraphs by sentence in normalization by default ([9cde697](https://github.com/sile-typesetter/casile/commit/9cde6978466da2bfbb10e8d782ae7a735d98f653))
* **scripts:** Add script to flatted split files into single source ([66fb87c](https://github.com/sile-typesetter/casile/commit/66fb87c87fd18c3535634d132ea277ade0486f2a))
* **scripts:** Allow override of dependencies at runtime as well as build time ([3279586](https://github.com/sile-typesetter/casile/commit/3279586e0e8df840da8bdd614788f297a20958ba))
* **utilities:** Support splitting documents into sections ([05fedb4](https://github.com/sile-typesetter/casile/commit/05fedb43bcb54acb7b7ed61ff5c9e02a604eeeca))


### Bug Fixes

* **build:** Drop duplicate targets supplied by reusable include ([18331d5](https://github.com/sile-typesetter/casile/commit/18331d5687d5416d692b9b894c28778400a1ad40))
* **build:** Note grep is a build-time dependency, not just runtime ([d1f2035](https://github.com/sile-typesetter/casile/commit/d1f20350dc78826a4f05b27628281f042c8ee2d8))
* **cli:** Avoid Unicode direction isolation marks in CLI output ([5ea0038](https://github.com/sile-typesetter/casile/commit/5ea0038cf899c1ba4bac10a5949742625e67e550))
* **cli:** Cleanup help message to be more accurate ([54787eb](https://github.com/sile-typesetter/casile/commit/54787eb3015d608b185ca073aa54c9caed305449))
* **filters:** Separate pandoc filter arguments from normalization arguments ([c17ae03](https://github.com/sile-typesetter/casile/commit/c17ae039fbddb85404f0dd9d78f58c91ff2144ff))
* **i18n:** Add missing translation for paper size names ([664cf32](https://github.com/sile-typesetter/casile/commit/664cf32fcc62ceda69dfae1b6be9c556699dcbbe))
* **rules:** Correct parse error in font search directory handling ([819edb5](https://github.com/sile-typesetter/casile/commit/819edb5cb7c080f193431ab6478d5a898d6e962b))
* **rules:** Unscramble project-wide manifest creation targets ([78faebe](https://github.com/sile-typesetter/casile/commit/78faebe66bff13c26b4e14e3ca7f69a8509b844e))


### Changes

* **cli:** Rename 'path' argument to 'project' ([190a3c9](https://github.com/sile-typesetter/casile/commit/190a3c942490a02281dc3ec6d8e21a709833c60f))
* **rules:** Drop BUILDDIR as a make variable and make it a config option ([69bdbea](https://github.com/sile-typesetter/casile/commit/69bdbeab65786ec0346ba59cbcee7b9386d55f78))
* **scripts:** Redo split chapter file loading ([7f3401b](https://github.com/sile-typesetter/casile/commit/7f3401b896bebfa2af2063ebdb2ec959f0d80b73))


### Optimizations

* **import:** Use parallel to multi-thread normalizing lots of files ([4691d1f](https://github.com/sile-typesetter/casile/commit/4691d1ffdf2c2ecd3958d1dcdce1be6947a8aa3d))

## [0.13.4](https://github.com/sile-typesetter/casile/compare/v0.13.3...v0.13.4) (2024-06-28)


### New Features

* **docker:** Build image with SILE v0.15.4 from upstream Arch Linux ([6973d64](https://github.com/sile-typesetter/casile/commit/6973d640d85fc12a3efdd24a9bf3f3fa068963ea))

## [0.13.3](https://github.com/sile-typesetter/casile/compare/v0.13.2...v0.13.3) (2024-06-10)


### New Features

* **build:** Overhaul autoconf with modular components from other projects ([e02c68d](https://github.com/sile-typesetter/casile/commit/e02c68d49c4d45495b87eca0059d45ecda591d3c))
* **build:** Switch from XZ to ZST for release artifacts ([708bc9f](https://github.com/sile-typesetter/casile/commit/708bc9f9ba1df3e4950aef69a47455122ec4d320))
* **utilities:** Add automatic upgrades for many things deprecated in SILE v0.15 ([69201cd](https://github.com/sile-typesetter/casile/commit/69201cdc285548d65f20f2ed0e1b379ebd7fdded))

## [0.13.2](https://github.com/sile-typesetter/casile/compare/v0.13.1...v0.13.2) (2024-06-10)


### New Features

* **cli:** Add alternative plain interface to the CLI ([1753ad3](https://github.com/sile-typesetter/casile/commit/1753ad32e2b85a4fbd30186732ceaf77d5f2f00d))
* **cli:** Don't hide intermediate output artifacts in verbose or debug modes ([b61a0f7](https://github.com/sile-typesetter/casile/commit/b61a0f71080e8e7aa77c8c36c4670235818f4c03))
* **cli:** Gracefully handle errors with make outputting status for unwrapped jobs ([a58857a](https://github.com/sile-typesetter/casile/commit/a58857a5f87b3a9ea4d49ec9c295212c5ececc4a))
* **cli:** Monkey-patch ZSH completions to include existing files as make targets ([eb73105](https://github.com/sile-typesetter/casile/commit/eb73105285ed5a1c1d2f5bcf5ed7cd8b52adc3f2))
* **docker:** Enable data for all provided tools that support system locales ([d07d587](https://github.com/sile-typesetter/casile/commit/d07d58751e42ed9db0278e80668bee0b81b91453))
* **docker:** Install sudo to let users install stuff in CI runners ([0bf89ae](https://github.com/sile-typesetter/casile/commit/0bf89aefc90405267c2ab593b9de753606b86ddb))
* **rules:** Add dedicated format target for manifests ([969c4a5](https://github.com/sile-typesetter/casile/commit/969c4a51f1e0335a5e55d4bd9a6eec208d607b1b))
* **rules:** Include cropped versions of PDFS in pdfs build by default ([9b74394](https://github.com/sile-typesetter/casile/commit/9b74394e4b33d112e243f25b8367e5a00d50cc11))


### Bug Fixes

* **build:** Get lunamark fork installed in packaging ([1aa0225](https://github.com/sile-typesetter/casile/commit/1aa0225c670ff1028a9b80a18eaf2f40fd4660ac))
* **covers:** Put selectable text behind rendered covers ([2859958](https://github.com/sile-typesetter/casile/commit/28599582d25cd870850bbb9dd2e21d9a247fdc8d))
* **docker:** Strip spaces from paths so minimalistic envs can't cause path issues ([baef98e](https://github.com/sile-typesetter/casile/commit/baef98e258c8104199db43db759cfff31767284a))
* **functions:** Don't let requireSpace function force blank pages ([02fcb54](https://github.com/sile-typesetter/casile/commit/02fcb546497be24e4ba9d658f5e575c2c0aed2d8))
* **layouts:** Correct square promotianals to not be a bound layout ([c394e99](https://github.com/sile-typesetter/casile/commit/c394e99132d2cc1b0446f55170ee8a8ffc8848a9))
* **layouts:** Revamp pocket book layout matching a5trim usage ([c9b551f](https://github.com/sile-typesetter/casile/commit/c9b551f366dace119d117d82de675f58265c28da))
* **layouts:** Set non-bound page formats to get regular covers not front-back ones ([5ec9c76](https://github.com/sile-typesetter/casile/commit/5ec9c76613a19afb286bc7372106881f830b5240))
* **renderings:** Bring dark color support back to soft-cover crease emulator ([4b5ea00](https://github.com/sile-typesetter/casile/commit/4b5ea005bf3bfdd2d99a9d159d6513c9ebae6823))
* **rules:** Fix mapping absolute paths to CWD to be Lua module specs ([5a5802e](https://github.com/sile-typesetter/casile/commit/5a5802e1c2b6e3c8e3d4cb4dd7c424b1efb93a4b))
* **rules:** Work around PNG conversion issue in current ImageMagick ([a6408c3](https://github.com/sile-typesetter/casile/commit/a6408c364bb44b17931ac1011235293ff0a98c43))

### [0.13.1](https://github.com/sile-typesetter/casile/compare/v0.13.0...v0.13.1) (2024-03-23)


### Bug Fixes

* **docker:** Install clang/mold in Docker builder ([59d0c17](https://github.com/sile-typesetter/casile/commit/59d0c17abaeb78da23d51f2c7ee3ae8babc9f519))
* **release:** Install clang/mold in CI workflows so release artifacts build ([9764f4c](https://github.com/sile-typesetter/casile/commit/9764f4cc163fe2da0ce69b959c31f17e044bc0b3))

## [0.13.0](https://github.com/sile-typesetter/casile/compare/v0.12.2...v0.13.0) (2024-03-23)


### Features

* **cli:** Add duration timer to main runner ([004fcae](https://github.com/sile-typesetter/casile/commit/004fcaeee96256a7465c075ad392707d85268052))
* **cli:** Hide build status messages for successful builds of intermediate targets ([160423c](https://github.com/sile-typesetter/casile/commit/160423c40e083c792dff636cc0b2daaa6207b662))
* **cli:** Redo output using progress widgets to reduce total output ([43f7453](https://github.com/sile-typesetter/casile/commit/43f7453a1229ba4df3398be1c239878e9a49858f))
* **docker:** Rebuild image to have Caleb's current GPG public key ([4d3a521](https://github.com/sile-typesetter/casile/commit/4d3a521bb30a0ded17e8aee2af28d81570ebba98))
* **packages:** Add watermark package and trigger from build variable ([bff34e9](https://github.com/sile-typesetter/casile/commit/bff34e9b50c0b42485919ccc9faa8f105592e9c1)), closes [#154](https://github.com/sile-typesetter/casile/issues/154)
* **zola:** Use relative links for internal references for easier hosting ([90085a9](https://github.com/sile-typesetter/casile/commit/90085a92e5cc62feabc455d535b8bffbef95967b))


### Bug Fixes

* **build:** Correct configure flag so debug builds are not release mode ([1236b2a](https://github.com/sile-typesetter/casile/commit/1236b2a845e2d35d4e241594d9ae7f231e47be83))
* **classes:** Keep vertical box out of horizontal tags ([b457a2d](https://github.com/sile-typesetter/casile/commit/b457a2d4028c38a56b7e95ebbba99b7ef905eed8))
* **cli:** Add a space to target names so wordwise copy-paste can't catch formatting ([f54ae9d](https://github.com/sile-typesetter/casile/commit/f54ae9d2aa53fbeff4cd71831b0efcbabf2b289c))
* **docker:** Drop bogus lua dependency, only mention is example code ([1823286](https://github.com/sile-typesetter/casile/commit/182328643c96fa14d9b428b2d8f7acba5aea74e2))
* **docker:** Restore provision of Lua colors library ([8cff649](https://github.com/sile-typesetter/casile/commit/8cff6499ec7365be2f7baf19036f8a2e784877b5))
* **rendering:** Improve paper finish properties to get more realistic colors ([d031f2a](https://github.com/sile-typesetter/casile/commit/d031f2adb8c60c51731d2123ee8257ae5b0ba4a8))
* **renderings:** Update soft-cover crease emulator color/location ([bab24f0](https://github.com/sile-typesetter/casile/commit/bab24f08fd5dd42b849c91bffc140690df58f300))


### Performance Improvements

* **build:** Use mold linker by default for x86_64 ([76d4a11](https://github.com/sile-typesetter/casile/commit/76d4a11135717064ee9b0c44056822824352a54f))

### [0.12.2](https://github.com/sile-typesetter/casile/compare/v0.12.1...v0.12.2) (2024-02-07)


### Features

* **docker:** Build image with SILE v0.14.17 from upstream Arch Linux ([ee0dd0d](https://github.com/sile-typesetter/casile/commit/ee0dd0dc83ab2b9875010d4a2e13573015048dc6))

### [0.12.1](https://github.com/sile-typesetter/casile/compare/v0.12.0...v0.12.1) (2024-01-30)


### Features

* **docker:** Build image with SILE v0.14.16 from upstream Arch Linux ([3eb6d50](https://github.com/sile-typesetter/casile/commit/3eb6d503c28f3e60128595317e73c9ec09bdb108))

## [0.12.0](https://github.com/sile-typesetter/casile/compare/v0.11.4...v0.12.0) (2024-01-13)


### ⚠ BREAKING CHANGES

* **cli:** The fact that subcommands are not all verbs has been
bothering me for a while. Several times I've sat down recently and had
to look up what the subcommand was. This is more along the lines of what
I seem to expect every time I'm away from it for a while. This choice
makes all the subcommands into verbs. Alternatives like 'execute' and
'do' were considered, this is just seemingly the most obvious
alternative.

### Features

* **build:** Default to LuaJIT like SILE, provide option for switching ([77496ed](https://github.com/sile-typesetter/casile/commit/77496edd222fda7c8444cf5b07492c04bf1233d4))
* **build:** Provide mechanism to skip only font checks at build time ([7ae3ca8](https://github.com/sile-typesetter/casile/commit/7ae3ca82b54c9c70952757d8c31524970530d56a))
* **docker:** Build image with SILE v0.14.14 from upstream Arch Linux ([e41cab2](https://github.com/sile-typesetter/casile/commit/e41cab2a1d2e46e4d9554fa3be696583d90d0c42))
* **packages:** Adjust \book:numbering override to handle Fluent messages like SILE ([1886475](https://github.com/sile-typesetter/casile/commit/1886475fbd507a04bc539416493085211e97ab7b))
* **rules:** Add error mechanism for filters expecting undefined edits ([7334745](https://github.com/sile-typesetter/casile/commit/73347453ed0ccf25e39459fad3dda5ec0ef0bddd))
* **scripts:** Use all regular m4 filters when generating branch diffs ([c05caff](https://github.com/sile-typesetter/casile/commit/c05caffcb183925127664525b11d403062c3fd7e))


### Bug Fixes

* **classes:** Load package required by settings handler into geometry class ([6a4dbcf](https://github.com/sile-typesetter/casile/commit/6a4dbcfb9aa4ddd3d89d2916f1db1d917ef76086))
* **covers:** Work around Inkscape 1.3 bug ([9c92650](https://github.com/sile-typesetter/casile/commit/9c9265082eedcd3cffe6409d4e8f6ea92a516bf9))
* **filters:** Only set a default titlecase style guide for English ([87bd685](https://github.com/sile-typesetter/casile/commit/87bd6859242fda2d9f8d63f9e184dcfd67f7732b))
* **i18n:** Add missing translation for paper size name ([c1e6c56](https://github.com/sile-typesetter/casile/commit/c1e6c56011b6449a694d5df6f23479b7af7ad351))
* **packages:** Keep crop mark package from initializing a frame nobody may use ([17a6bb8](https://github.com/sile-typesetter/casile/commit/17a6bb89fb5b79736665c66f07470e70e82a3406))
* **rules:** Update specialty module loader using update use syntax ([8614ad7](https://github.com/sile-typesetter/casile/commit/8614ad71d69b813e5a486eea50f7e4a77df08065))


### Code Refactoring

* **cli:** Rename 'script' subcommand to 'run' ([a6a0b8f](https://github.com/sile-typesetter/casile/commit/a6a0b8fa7d4ebc9170d73f33960c386fdfe9f7b3))

### [0.11.4](https://github.com/sile-typesetter/casile/compare/v0.11.3...v0.11.4) (2023-10-30)


### Features

* **build:** Allow builds --enable-developer to run remotely from source directory ([de47b88](https://github.com/sile-typesetter/casile/commit/de47b88d7146b9af74b6f1f307ba5f222bdf5b76))
* **core:** Add vendored lunamark fork removed from SILE upstream ([9b92dd1](https://github.com/sile-typesetter/casile/commit/9b92dd173f5e6fb58d58417faa2015500b1b037b))
* **core:** Extend SILE paths to toolkit and project-rocks ([eda4346](https://github.com/sile-typesetter/casile/commit/eda434662ef5345cfb5cd95267816de067262ce7))
* **i18n:** Add missing translation key for epub format output ([865924c](https://github.com/sile-typesetter/casile/commit/865924c9adf82c61b2288aeeed7424b341675685))
* **rules:** Extend rather than obliterate user-specified SILE_PATH ([f605617](https://github.com/sile-typesetter/casile/commit/f605617750f5cf55c7a28ad23c764c9966a69fd8))
* **scripts:** Export CaSILE's build dir for scripts that may use it outside of the project dir ([d488856](https://github.com/sile-typesetter/casile/commit/d4888566737d0dd49b6fd05b4c0987e032ee0f12))
* **scripts:** Prepend publisher toolkit scripts dir to path ([d149efb](https://github.com/sile-typesetter/casile/commit/d149efb80afb867805d4e5c801f2c28f9e18e3e8))


### Bug Fixes

* **build:** Correct Rust dependency calculations in make target ([862b69f](https://github.com/sile-typesetter/casile/commit/862b69fed116373c4b982c9de4d2d7e585697778))
* **build:** Move build-time dependency checks out of runtime dep check configure flag ([eedd6a4](https://github.com/sile-typesetter/casile/commit/eedd6a4c06075c83ad0cb487e538858a9a53f05b))
* **docker:** Update container dependencies with upstream Arch Linux package changes ([3c0fcb9](https://github.com/sile-typesetter/casile/commit/3c0fcb9c5ea925e4113327224c41e145b3c27e8b))
* **rules:** Don't trip on ebook metadata when source identified but not with a title ([51cb99c](https://github.com/sile-typesetter/casile/commit/51cb99c743f41fd4fffe7e58390ee847622b74fb))

### [0.11.3](https://github.com/sile-typesetter/casile/compare/v0.11.2...v0.11.3) (2023-09-22)


### Features

* **cli:** Generate man page ([90b604a](https://github.com/sile-typesetter/casile/commit/90b604a850d44c7b53159f9b747576ea46b4b5c9))

### [0.11.2](https://github.com/sile-typesetter/casile/compare/v0.11.1...v0.11.2) (2023-08-23)


### Features

* **docker:** Rebuild image with SILE v0.14.11 from upstream Arch Linux ([622a184](https://github.com/sile-typesetter/casile/commit/622a1846516cf418391aaff74fc72c02662ede54))
* **filters:** Allow style guide meta data to impact title case normalization ([9f2d4f5](https://github.com/sile-typesetter/casile/commit/9f2d4f5143e3f7c3c0fe5933c65983b46c7bfa40))

### [0.11.1](https://github.com/sile-typesetter/casile/compare/v0.11.0...v0.11.1) (2023-07-12)


### Bug Fixes

* **build:** Include new script subcommand sources in source package ([ddbb5ea](https://github.com/sile-typesetter/casile/commit/ddbb5ea8d130efa5b5933d5764559d3786d9df29))

## [0.11.0](https://github.com/sile-typesetter/casile/compare/v0.10.17...v0.11.0) (2023-07-11)


### Features

* **filters:** Add filter to fix title-casing of headings ([2abf654](https://github.com/sile-typesetter/casile/commit/2abf654b4c77a05fb6bdb47acbf2f6a029a7808e))
* **rules:** Add machine translation targets using DeepL ([2a9a6e2](https://github.com/sile-typesetter/casile/commit/2a9a6e24c13ae593ff0ff7167b2223d66cb87263))
* **rules:** Add post-processing no Pandoc normalization to restore CriticMark stuff ([9c579db](https://github.com/sile-typesetter/casile/commit/9c579db20615a433ca3d3d1d5bf5c38e0c677aa8))
* **rules:** Allow munge command to be a whole pipeline instead of one entry ([25b2d3a](https://github.com/sile-typesetter/casile/commit/25b2d3a30f4eaf2b67a5f5cd7c1d1d1f755cf2b2))
* **rules:** Apply four_space_rule extension for easier list editing in some editors ([e591701](https://github.com/sile-typesetter/casile/commit/e5917019d5faa874376b5c87de5f9b9f25dd6ad6))
* **scripts:** Add helper script for finding related files ([2295a65](https://github.com/sile-typesetter/casile/commit/2295a65a2f0fcadb310b02a50d2219dd17c56f84))


### Bug Fixes

* **docker:** Install all of texlive, we need the biggest (font) packages anyway ([aea24f5](https://github.com/sile-typesetter/casile/commit/aea24f590b51be48cf506a83104156b6f91f80ba))
* **docker:** Update Arch repositories post upstream re-org ([5af30eb](https://github.com/sile-typesetter/casile/commit/5af30eb78cd0d53521207c3ded3908ccc927e03b))
* **docker:** Update Docker deps to canonical distro package name ([dee0c76](https://github.com/sile-typesetter/casile/commit/dee0c76b481ff71c46ea97d0ba89e8b22904fb66))
* **docker:** Update Docker deps with Arch Linux podofo package split ([8131675](https://github.com/sile-typesetter/casile/commit/8131675834733b489d2141640e86334acc73beaf))
* **functions:** Catch new chapter loader syntax so operation isn't duplicated ([e40563e](https://github.com/sile-typesetter/casile/commit/e40563e21206aa56dacfb245febdbb7929d815fc))
* **functions:** Handle splitting more than one base book per project ([9f9eca2](https://github.com/sile-typesetter/casile/commit/9f9eca2e8500af4d24adf742259f21a081c4cea9))
* **rules:** Fix worklog reports reading correct database file ([b7307ad](https://github.com/sile-typesetter/casile/commit/b7307ad3f8e6255518b5fcb2a60bb6581443b359))

### [0.10.17](https://github.com/sile-typesetter/casile/compare/v0.10.16...v0.10.17) (2023-04-13)


### Features

* **docker:** Build image with SILE v0.14.9 from upstream Arch Linux ([67f506c](https://github.com/sile-typesetter/casile/commit/67f506c704f6ec042a3e35f051a3b602af59fe37))

### [0.10.16](https://github.com/sile-typesetter/casile/compare/v0.10.15...v0.10.16) (2023-03-14)


### Features

* **classes:** Add edition handler as class option ([5821e3d](https://github.com/sile-typesetter/casile/commit/5821e3d063d31dfa9081a2bc2ab676d89fab9461))
* **deps:** Make sassc available to projects to ease plain html and epub styling ([24b32c0](https://github.com/sile-typesetter/casile/commit/24b32c0f2defc062af7e4b971ae872d9a4b490d7))
* **ebooks:** Allow building different edits/editions as epub ([032584b](https://github.com/sile-typesetter/casile/commit/032584bd28d507e2924cc0c613fd665a328dca01))
* **mdbook:** Markup numbered vs. unnumbered chapters in TOC ([56f4b6d](https://github.com/sile-typesetter/casile/commit/56f4b6dbfd57f46eef36324932e72952bb61dc1f))
* **mdbook:** Split sections into subchapters ([21391ac](https://github.com/sile-typesetter/casile/commit/21391acfc9fe09518a96e4c3f45a75d99be2cfc7))
* **rules:** Add plain standalone output format ([67107cb](https://github.com/sile-typesetter/casile/commit/67107cb3e026c7db1dfc9f72a37880d6348447dd))
* **rules:** Add targets for covers and renderings of edits/editions ([076a762](https://github.com/sile-typesetter/casile/commit/076a7628a28704677240968eb440c301331e8568))
* **rules:** Add targets for rendering resources with edits/editions ([978ffd8](https://github.com/sile-typesetter/casile/commit/978ffd814a8587a895600d631756a10c68e3e137))
* **rules:** Allow mdbook output format with edits ([8663ac2](https://github.com/sile-typesetter/casile/commit/8663ac24821370638f3151bc3c2d38f244a9825c))
* **rules:** Allow plain document output formats with edits ([86aa621](https://github.com/sile-typesetter/casile/commit/86aa6212e0b95f0d6b695ffe42552f5a773931a1))
* **rules:** Expand pattern_list funuction from 5 to 7 segment handling ([473f0f4](https://github.com/sile-typesetter/casile/commit/473f0f40d86ad0ff804afd39a4e98c12b4860f70))
* **rules:** Separate EDITS from EDITIONS so both can be used ([736e921](https://github.com/sile-typesetter/casile/commit/736e921c57e2fc8d05a8a626f29f3506a483fd3a))
* **rules:** Use `flock` for more robust locking of single-thread jobs ([d1b9eda](https://github.com/sile-typesetter/casile/commit/d1b9edac7a2e5b4e0cc86013e696cd27a4de545c))
* **templates:** Pass edit option to SIL template for use by document class ([c7db40c](https://github.com/sile-typesetter/casile/commit/c7db40c96e59d086de898a2c80bf68c711ca1482))
* **zola:** List more possible output formats in zola resources links ([82e1963](https://github.com/sile-typesetter/casile/commit/82e1963b39ca798b19eb488858df1f1f3433166f))
* **zola:** Output resource links to edits in all formats ([133dee3](https://github.com/sile-typesetter/casile/commit/133dee39168b7d2dbb35fed9b6ec17e5f798bf74))


### Bug Fixes

* **classes:** Make sure promotials use full-page covers ([1eb3598](https://github.com/sile-typesetter/casile/commit/1eb3598cd663ab1e7aa1f2df5cae98b13dc6f68f))
* **docker:** Give Pandoc filters access to system Lua modules ([d7d0f28](https://github.com/sile-typesetter/casile/commit/d7d0f289fa0e7d0d977bd8285f42a637da05ab06))
* **filters:** Update verses filter for current Pandoc API ([7b85712](https://github.com/sile-typesetter/casile/commit/7b85712683aa7550bb30d131d959b6a51836a38b))
* **layouts:** Correct background option usage for app layouts ([2284bde](https://github.com/sile-typesetter/casile/commit/2284bde4d14b86e205896b924cc8f57d75f9bfea))
* **layouts:** Fixup frame math race condition in app layout ([abf9751](https://github.com/sile-typesetter/casile/commit/abf975166c2e9c99da44a1b01359307d8c3a8286))
* **mdbook:** Export 'books' that have no chapters in a navigable way ([e5d59ef](https://github.com/sile-typesetter/casile/commit/e5d59ef35255cd741fa7f5b78c2cd0e47dcfcf2d))
* **packages:** Cast TOC entries to strings (actually this time) ([4443a94](https://github.com/sile-typesetter/casile/commit/4443a94be47d2454000b69c3085f5dc194fd0cab))
* **packages:** Load required packges for default back cover function ([573dfc2](https://github.com/sile-typesetter/casile/commit/573dfc2480858a437a8f8db8dd486543277f582b))
* **rules:** Allow 'with verses' builds even if no references found ([f33c534](https://github.com/sile-typesetter/casile/commit/f33c534344999f8173047a9ed2933509f36b4228))
* **rules:** Allow mdbook generation when no author data present ([88f6925](https://github.com/sile-typesetter/casile/commit/88f6925fd32e70908c32658d0de42f646a716dd7))
* **rules:** Fix conflicting xargs args to avoid warning ([4c861e2](https://github.com/sile-typesetter/casile/commit/4c861e25c8184b8a3bffb80435b3cbce5ff2ac75))
* **rules:** Fix pattern nesting so editions plus edits work on the same outputs ([293a833](https://github.com/sile-typesetter/casile/commit/293a833a0df473387823da1db025f3eef20783aa))
* **rules:** Suppress div wrappers that mess up footnote placement in some output formats ([e2d1961](https://github.com/sile-typesetter/casile/commit/e2d1961835ffd0237aa73c44287610eca362129e))
* **rules:** Work around XVFB issues with parallel inscapes ([a8a7cf8](https://github.com/sile-typesetter/casile/commit/a8a7cf8bd125fd579fc1755413ca02ca20397fbe))
* **scripts:** Fix footnote marker order normalization after en/em-dashes ([9a06ca6](https://github.com/sile-typesetter/casile/commit/9a06ca66c251d9b16e66047852069b79d08d3a17))

### [0.10.15](https://github.com/sile-typesetter/casile/compare/v0.10.14...v0.10.15) (2023-02-07)


### Features

* **cli:** Enable CaSILE debug mode if GH Actions debug logging is enabled ([24a41c5](https://github.com/sile-typesetter/casile/commit/24a41c5790e81fcb7b04d7f171b2fb8e92482d3a))
* **rules:** Redo make target shell wrapper to be GNU Make 4.4+ compatible ([73933dd](https://github.com/sile-typesetter/casile/commit/73933dd96c45302c2c84e1d7bba58f4b1d557aa7))


### Bug Fixes

* **cli:** Surface STDERR in CI runners when verbose enabled ([aff9dc7](https://github.com/sile-typesetter/casile/commit/aff9dc7cfe5987b9d4d5757e836fb3f2819e231e))
* **docker:** Avoid tripping on new Ghostscript safety restrictions ([51403f6](https://github.com/sile-typesetter/casile/commit/51403f69f4ccfa7576365383ea583c3a25e3d6a5))
* **rules:** Avoid multiple shell runs to calculate ISBNs ([e073fdd](https://github.com/sile-typesetter/casile/commit/e073fdd2c651fc49d5b1c9c66e641b53bfcebcc3))
* **rules:** Drop draft builds being forced when run from editor ([9015aca](https://github.com/sile-typesetter/casile/commit/9015acae87bcb73e6c796935b513f7914a1fc0b7))
* **rules:** Make .SHELLFLAGS usage compatible with GNU Make 4.4 ([cbb7aa8](https://github.com/sile-typesetter/casile/commit/cbb7aa80b24221e0dfbc1d9c6ee38f7e05d30dac))

### [0.10.14](https://github.com/sile-typesetter/casile/compare/v0.10.13...v0.10.14) (2023-02-01)


### Features

* **cli:** Handle cases where system has the 'c' locale as 'en' ([15a081b](https://github.com/sile-typesetter/casile/commit/15a081bc15d2ca13decf7373da3f084ed4124308))


### Bug Fixes

* **cli:** Correct env variable typo ([3d0027e](https://github.com/sile-typesetter/casile/commit/3d0027eecbda5083c21ccbe6f5814822e85baa79))
* **docker:** Set a sane default system language in container ([7e0ac93](https://github.com/sile-typesetter/casile/commit/7e0ac93dc3b3260c8686ae7236cbf9af675f3d41))
* **rules:** Correct location of jacket artifacts ([c95c2c8](https://github.com/sile-typesetter/casile/commit/c95c2c8c4e06b7ac2b572655ca3d6e31806edc2f))

### [0.10.13](https://github.com/sile-typesetter/casile/compare/v0.10.12...v0.10.13) (2023-01-31)


### Features

* **docker:** Switch effective user to owner of directory ([f3881ac](https://github.com/sile-typesetter/casile/commit/f3881ace6926becd3a33e4977d872557be59abc6))


### Bug Fixes

* **docker:** Add workaround new Git security policy ([79d6249](https://github.com/sile-typesetter/casile/commit/79d62498fab4e034b4be3c4ed213f041e81ec966))
* **docker:** Set system level Git safe directory to our working dir ([0d1f4b8](https://github.com/sile-typesetter/casile/commit/0d1f4b8190fa75091f0766fb79cd92b00611e26c))
* **docker:** Update workaround for new Git safe.diroctory restrictions ([a18f752](https://github.com/sile-typesetter/casile/commit/a18f752d4e2503f4017579b502279046e6c81b8c))

### [0.10.12](https://github.com/sile-typesetter/casile/compare/v0.10.11...v0.10.12) (2023-01-31)


### Bug Fixes

* **build:** Fixup missing utility dependencies ([1fc998f](https://github.com/sile-typesetter/casile/commit/1fc998fea5102ecd20ab430a5e11170f0a7f501a))
* **cabook:** Only attempt to run numbering :pre & :post hooks if they exist ([9fb57c4](https://github.com/sile-typesetter/casile/commit/9fb57c48d1e89c09c646dbe328f92b6924c24bb7))
* **ci:** Fix Docker deploy ([f9d0645](https://github.com/sile-typesetter/casile/commit/f9d064541fbed6a8b2f35231a3c9fcb26b2c23bf))
* **covers:** Don't fail to render covers if no abstract is present ([533f621](https://github.com/sile-typesetter/casile/commit/533f6212251827a14d42097f5928d569a61552ea))
* **imprint:** Pass string not table to processMarkdown() ([e1c57b3](https://github.com/sile-typesetter/casile/commit/e1c57b3122ad7113562a726fd0c35ea7d32a4b43))

### [0.10.11](https://github.com/sile-typesetter/casile/compare/v0.10.10...v0.10.11) (2023-01-31)


### Features

* **rules:** Include project and publisher directory vars in debug output ([7537474](https://github.com/sile-typesetter/casile/commit/7537474d6ea31e5bcc881d7fc436d426f1c0b4b2))


### Bug Fixes

* **layouts:** Default crop to off for printout layouts ([9038364](https://github.com/sile-typesetter/casile/commit/90383641ec6b1c3182b896e8e7e7c841b105a647))
* **packages:** Cast TOC entries to strings ([6f52662](https://github.com/sile-typesetter/casile/commit/6f5266259ee20bafade768f535845b5742647c4b))
* **packages:** Don't occlude SILE's lists package ([a81586d](https://github.com/sile-typesetter/casile/commit/a81586d58db4bf21b3af57799ebf04e06769bd07))
* **packages:** Fixup requireSpace() to properly compare measurements ([871d8a6](https://github.com/sile-typesetter/casile/commit/871d8a6d789584fbf2973b8fb8038f32a30d785e))
* **packages:** Use cabook class font styling in endnotes package ([35ac6c2](https://github.com/sile-typesetter/casile/commit/35ac6c2f5900bd1380fd2f9651f50fb578703bf0))
* **rules:** Handle explosion of ignores in larger projects ([b326121](https://github.com/sile-typesetter/casile/commit/b326121493141bea9d17854bd716548ba1590d7d))

### [0.10.10](https://github.com/sile-typesetter/casile/compare/v0.10.9...v0.10.10) (2023-01-12)


### Features

* **rules:** Include layouts data in manifests ([21acdc4](https://github.com/sile-typesetter/casile/commit/21acdc48a4bb27b579dc025e4bd0ea6fc422cd6d))
* **rules:** Include version and url info in manifest files ([bcee49e](https://github.com/sile-typesetter/casile/commit/bcee49e9ddbf4ce7e6f006c5e9a9dcd4c7811728))

### [0.10.9](https://github.com/sile-typesetter/casile/compare/v0.10.8...v0.10.9) (2022-11-11)


### Bug Fixes

* **docker:** Force rebuild to get fixed ImageMagick packages ([fb7a270](https://github.com/sile-typesetter/casile/commit/fb7a2703f24d662be46aaebd5033eeaff45e9b09))

### [0.10.8](https://github.com/sile-typesetter/casile/compare/v0.10.7...v0.10.8) (2022-11-03)


### Bug Fixes

* **packages:** Correct endnotes usage of counters package ([8235283](https://github.com/sile-typesetter/casile/commit/82352839b2071c6f4e6bce8692f3c46ee06cbc38))
* **rules:** Scale ISBN label to match resolution ([15a2530](https://github.com/sile-typesetter/casile/commit/15a25300e7174f85eb80d34da30dbf8cf73b4324))

### [0.10.7](https://github.com/sile-typesetter/casile/compare/v0.10.6...v0.10.7) (2022-09-06)


### Bug Fixes

* **layouts:** Fixup setting command defaults from layouts again ([5f92dd6](https://github.com/sile-typesetter/casile/commit/5f92dd63baae3e6675142036f8869f622f540c21))
* **layouts:** Initialize crop package after layout is known ([e958e5b](https://github.com/sile-typesetter/casile/commit/e958e5bb25512af45e7ab34aa68daac14d1b8781))
* **packages:** Redo how mirror & crop work (at least for a5trim so far) ([bbad2c5](https://github.com/sile-typesetter/casile/commit/bbad2c54a13401e2559725269614ef4e9837a2ed))
* **packages:** Redo how mirror & crop work (at least for rest of layouts) ([6bdf239](https://github.com/sile-typesetter/casile/commit/6bdf239909d38aee5c7058b249aa60cf93cf2048))

### [0.10.6](https://github.com/sile-typesetter/casile/compare/v0.10.5...v0.10.6) (2022-09-02)


### Bug Fixes

* **cli:** Avoid panic on invalid UTF-8 (sometimes thrown by kindlegen) ([b69612d](https://github.com/sile-typesetter/casile/commit/b69612daf32cdf888771ef33f2102f518a67d920))

### [0.10.5](https://github.com/sile-typesetter/casile/compare/v0.10.4...v0.10.5) (2022-09-02)


### Features

* **rules:** Allow for localized layout names ([bc3fea8](https://github.com/sile-typesetter/casile/commit/bc3fea855a25c5ff7ca9959985d4932478ce0e2b))


### Bug Fixes

* **build:** Fixup GHCR to Docker Hub image shuffle ([7b3022d](https://github.com/sile-typesetter/casile/commit/7b3022db19a38747b0a2ba7b39eb7cdce875e771))
* **classes:** More effectively disable TOC write attempts in cabinding class ([a7183a8](https://github.com/sile-typesetter/casile/commit/a7183a8488f7231fe82c6bd2cf3a5e8da8cecef1))
* **rules:** Correct location of intermediate artifact ([d843373](https://github.com/sile-typesetter/casile/commit/d843373b31e89210bc1536daf8ad648c18902114))

### [0.10.4](https://github.com/sile-typesetter/casile/compare/v0.10.3...v0.10.4) (2022-09-01)


### Features

* **docker:** Make luarocks available at runtime for package installation in CI ([fd10b5d](https://github.com/sile-typesetter/casile/commit/fd10b5ddbdff979c034bfe5029a697593fd56958))
* **rules:** Make configured lua & luarocks paths available to targets ([aa6131b](https://github.com/sile-typesetter/casile/commit/aa6131b5cfbec3fbe97db725333d71c7fca4524c))

### [0.10.3](https://github.com/sile-typesetter/casile/compare/v0.10.2...v0.10.3) (2022-09-01)


### Features

* **functions:** Use new SILE Turkish apostrophe hyphenation support ([739c3f6](https://github.com/sile-typesetter/casile/commit/739c3f607486d45ed5447260e469c68476e0c86c))


### Bug Fixes

* **classes:** Sync toc function with upstream to get numbering right again ([3b984ee](https://github.com/sile-typesetter/casile/commit/3b984eec0a41ea637ddaa13bb81f933595775f4c))
* **class:** Reconnect our layout option to upstream masters package ([0fc1ff8](https://github.com/sile-typesetter/casile/commit/0fc1ff8276fb0bd6f263cfd24a14bb83770bb484))
* **packages:** Correct odd page miss-match after first-use ([8c1e57a](https://github.com/sile-typesetter/casile/commit/8c1e57a414a86d389b6867d51b152d8c1f109107))

### [0.10.2](https://github.com/sile-typesetter/casile/compare/v0.10.1...v0.10.2) (2022-08-12)


### Bug Fixes

* **build:** Package missing Lua files ([98cf1d7](https://github.com/sile-typesetter/casile/commit/98cf1d76f9176330c1d8a7a5a67acf99d821302a))

### [0.10.1](https://github.com/sile-typesetter/casile/compare/v0.10.0...v0.10.1) (2022-08-12)


### Features

* **packages:** Add package to dump frame info ([6a4730f](https://github.com/sile-typesetter/casile/commit/6a4730f278c3bfa8eb8e6e53237d89098d913589))
* **packages:** Allow passing options through to dropcap package ([4e6c721](https://github.com/sile-typesetter/casile/commit/4e6c7218fde7a817fcd8f1ec24cde9f16da7f632))
* **packages:** Facilitate parsing or processing of markdown in stages ([29f101e](https://github.com/sile-typesetter/casile/commit/29f101e571f2789bcb59dad84d7588c43f686f12))


### Bug Fixes

* **classes:** Stop duplicate unit registration ([a7d8ad5](https://github.com/sile-typesetter/casile/commit/a7d8ad55531bdd3e898e1c762d573bb626e0d457))

## [0.10.0](https://github.com/sile-typesetter/casile/compare/v0.9.0...v0.10.0) (2022-08-06)


### Features

* **utilities:** Add new SILE API updates to Lua upgrader ([9c0eb8d](https://github.com/sile-typesetter/casile/commit/9c0eb8d43c7d745bdcdcc9f2974fbd2bb119e2cd))


### Bug Fixes

* **classes:** Setup cabook class to be minimally v0.14.x compliant ([37b5f94](https://github.com/sile-typesetter/casile/commit/37b5f9462e207df9e5f62ee5c2b89df9603f2bb5))
* **class:** Work around classes not being able to stuff content ([e64bdf1](https://github.com/sile-typesetter/casile/commit/e64bdf1dc4fe46aa93076260b84dfb0763956647))

## [0.9.0](https://github.com/sile-typesetter/casile/compare/v0.8.1...v0.9.0) (2022-06-09)


### Features

* **deps:** Support SILE v0.13.0 ([da6b96f](https://github.com/sile-typesetter/casile/commit/da6b96fde238a41d795c6e356dff9537c8d6248f))

### [0.8.1](https://github.com/sile-typesetter/casile/compare/v0.8.0...v0.8.1) (2022-04-13)


### Features

* **build:** Detect xvfb-run at configure time and allow overriding ([4940552](https://github.com/sile-typesetter/casile/commit/4940552c66540461d6c91cbdef40361a9533635d))
* **build:** Make it possible to override paths to mkdir/install ([e78d253](https://github.com/sile-typesetter/casile/commit/e78d253559837ff2bdcded90e54eb0db6b846199))
* **covers:** Reduce default resource resolution to 600dpi ([7a75c4d](https://github.com/sile-typesetter/casile/commit/7a75c4d9b7d9dec3210b04bd8ddd691348b782b6))
* **deps:** Make xcf2png available to all builds ([7ffce9c](https://github.com/sile-typesetter/casile/commit/7ffce9cbbe04d677b6bfc998365f03a14e9c8f75))
* **docker:** Make zmv available in container root shell ([6b505d2](https://github.com/sile-typesetter/casile/commit/6b505d2d4f87e6bf2bbc9a004d63c0bf86bb8cbd))
* **pages:** Split series vs. book static site templates ([a8352f0](https://github.com/sile-typesetter/casile/commit/a8352f0b2901a3313763a26ce3aabb7fe7d4a41e))
* **renderings:** Limit number of books in file renderings ([19bf804](https://github.com/sile-typesetter/casile/commit/19bf8041c1804a7c1639611589897fb649d78d00))
* **renderings:** Scale POV textures relative to DRAFT mode ([0058dcf](https://github.com/sile-typesetter/casile/commit/0058dcf12c1e1f0a677da62704c995b15af33017))


### Bug Fixes

* **covers:** Avoid conflict with existing virtual frame buffers ([90ed2ed](https://github.com/sile-typesetter/casile/commit/90ed2ed63d5dd90b3099483683b30406719d8980))
* **functions:** Avoid project filenames being parsed as regular expressions ([fbcae80](https://github.com/sile-typesetter/casile/commit/fbcae80b21b3c6ea363426e2132e9afb1b9cc87e))
* **renderings:** Adjust light fade to blowout plane and avoid background gradient ([d8a5e73](https://github.com/sile-typesetter/casile/commit/d8a5e7395eff583ea2f644bccd7dd8b6700ede06))
* **rules:** Don't assume travis will be used for CI on all upgrades ([291beaf](https://github.com/sile-typesetter/casile/commit/291beafcc7d5c211befbf01f3c874033a289bf4c))

## [0.8.0](https://github.com/sile-typesetter/casile/compare/v0.7.4...v0.8.0) (2022-04-08)


### Features

* **mdbook:** Strip out input elements mdbook can't handle ([ec1de6b](https://github.com/sile-typesetter/casile/commit/ec1de6bd445e792628bfe90b89e6295bce7c777d))
* **pages:** Add default template for static book page ([0cfcd4e](https://github.com/sile-typesetter/casile/commit/0cfcd4e8edd9da520e962d86a8465c4ef243bc52))
* **pages:** Add mobi output to static site resources ([9ae5846](https://github.com/sile-typesetter/casile/commit/9ae5846a37978971ce31b48a585eb7c47ae61fc7))
* **pages:** Add PDF outputs to static site resources ([61cf7d3](https://github.com/sile-typesetter/casile/commit/61cf7d3fba9fbcc5a6b65f9c52b2966afdf60a8f))
* **rules:** Add mdbook output format ([2d326fd](https://github.com/sile-typesetter/casile/commit/2d326fdcaa15b4965df8e2d65686ae3e6fd44a17))
* **rules:** Add mechanism to output whole dirs to distribution ([838eb6f](https://github.com/sile-typesetter/casile/commit/838eb6fcaf062c1c1ad1f2edfc9e83d94cfaf70e))
* **rules:** Add target for static html index page for books ([9e43fc1](https://github.com/sile-typesetter/casile/commit/9e43fc139882bfb8beafa1e8125f6da8ce12d014))
* **scripts:** Add script for generating mdbook src chapters ([5a7f483](https://github.com/sile-typesetter/casile/commit/5a7f483ceed36e58c86571b5495b53afe72b4de1))
* **utilities:** Automatically migrate more deprecated Lua functions ([48bfb78](https://github.com/sile-typesetter/casile/commit/48bfb78c7e5787128693b60c2f6c9d2022044d54))


### Bug Fixes

* **cli:** Default CASILE_SINGLEPOVJOB to true, POV can be a machine killer ([b5e2740](https://github.com/sile-typesetter/casile/commit/b5e2740d639dd28579f0cba7a7e8212f1b21905d))
* **deps:** Check for required curl dependency on configure ([0322e1e](https://github.com/sile-typesetter/casile/commit/0322e1e06e81c8d5440d431f74e379b13e80582c))
* **mdbook:** Avoid double-linking TOCs with robust title/slug parsing ([fe2d343](https://github.com/sile-typesetter/casile/commit/fe2d3438f20f7f056556cfc347d2ba0feda1dcb6))
* **packages:** Correct length math calculation in endnotes package ([1024881](https://github.com/sile-typesetter/casile/commit/1024881c289d6ec401894a350b0b671a27e12dfa))
* **rules:** Expand array before shell expansion to dedup list ([f6fca73](https://github.com/sile-typesetter/casile/commit/f6fca73ad58981c9f26c516151a6862df87a1c32))
* **rules:** Fix pandoc filter for link-free processed source variant ([5fe4233](https://github.com/sile-typesetter/casile/commit/5fe42333d8f69aa91fb2b72d3d3c0fd74c966a89))
* **rules:** Limit forcing rebuilds to when *relevant* makefile changes ([5ff8005](https://github.com/sile-typesetter/casile/commit/5ff80058395543db7b5de0690cc63cb4355a24be))

### [0.7.4](https://github.com/sile-typesetter/casile/compare/v0.7.3...v0.7.4) (2022-03-17)


### Features

* **covers:** Run inkscape in an X virtual frame buffer ([292d87d](https://github.com/sile-typesetter/casile/commit/292d87d1bbcc3d0ee019cfed8f754c227a57c38c))
* **docker:** Let non-privileged container users install deps with su ([0d14dcf](https://github.com/sile-typesetter/casile/commit/0d14dcf89382c193b14b266ef985e36eb31f7c16))


### Bug Fixes

* **docker:** Install compatible lua-colors fork ([70c8b2d](https://github.com/sile-typesetter/casile/commit/70c8b2de95f6d782178c6542517c90540966272a))
* **rules:** Guard versioninfo characters that might look like shell globs ([ef00978](https://github.com/sile-typesetter/casile/commit/ef00978996919cd627b74f7eaf8d076e931ba02f))

### [0.7.3](https://github.com/sile-typesetter/casile/compare/v0.7.2...v0.7.3) (2022-03-16)


### Bug Fixes

* **cli:** Check for deep clone and skip warp-time if not ([dc9c7e0](https://github.com/sile-typesetter/casile/commit/dc9c7e08f77c1dbe0f01e03a82503368004c8094)), closes [#140](https://github.com/sile-typesetter/casile/issues/140)
* **cli:** Don't force install-dist target on setup / .gitignore regen ([06d2ca3](https://github.com/sile-typesetter/casile/commit/06d2ca37077deb0869b4e92437fb37978ffe891e))
* **rules:** Avoid race condition creating fresh BUILDDIR ([c1e507b](https://github.com/sile-typesetter/casile/commit/c1e507b465635711b026f643f270b189992fbde5))
* **rules:** Only calculate PARENT once and don't die if it's the same as BRANCH ([fbd05f8](https://github.com/sile-typesetter/casile/commit/fbd05f852ffe7bed6cb14c670a2478fdada09ea1))

### [0.7.2](https://github.com/sile-typesetter/casile/compare/v0.7.1...v0.7.2) (2022-03-16)


### Features

* **cli:** Put parallel pov job execution behind CASILE_SINGLEPOVJOB env flag ([c48aee5](https://github.com/sile-typesetter/casile/commit/c48aee57ee30a41f4d142d6cb0eb6a5ad851d635))


### Bug Fixes

* **cli:** Don't force install-dist target if debug is first target ([e13d9bb](https://github.com/sile-typesetter/casile/commit/e13d9bb9a1c55c5c0f050e40c241954c3ba7bbb3))

### [0.7.1](https://github.com/sile-typesetter/casile/compare/v0.7.0...v0.7.1) (2022-03-15)


### Features

* **rules:** Add ability to eval Make code after default rules ([fccf315](https://github.com/sile-typesetter/casile/commit/fccf315b2946a5ed74e4152187dcdfa763f0c484))
* **utilities:** Handle chapter splitting for sources with footnotes in sections ([3d5e7b5](https://github.com/sile-typesetter/casile/commit/3d5e7b54b9b51635440ce480d92cde25cd471b05))


### Bug Fixes

* **layouts:** Only mark verse positions if creating a verse index ([4535a5c](https://github.com/sile-typesetter/casile/commit/4535a5ceaf5af16566bf897e4ee9cc6fe7a74769))
* **rules:** Correct Pandoc template override variable ([#138](https://github.com/sile-typesetter/casile/issues/138)) ([4314008](https://github.com/sile-typesetter/casile/commit/43140084ec994d19596ee678ad53c2c165c7a22f))
* **utilities:** Correct shell quoting on generated chapter concatenater ([d72bb91](https://github.com/sile-typesetter/casile/commit/d72bb915e7e0854214f1e2501cccffa049699302))

## [0.7.0](https://github.com/sile-typesetter/casile/compare/v0.6.4...v0.7.0) (2022-01-13)


### ⚠ BREAKING CHANGES

* **class:** The open-page function has been removed, but
open-spread is not a drop in replacement for all previous usage because
it will force an even page opening if odd is false.
* **class:** The dropcap function formerly provided by CaSILE used
frames (via frametricks) and needed constant tweaking. The new upstream
package is *much* better suited to this task, but since the
implementation is almost completely different most book projects that
used this will need to adjust.

### Features

* **class:** Add \skipto command for frame relative absolute skips ([7c24f73](https://github.com/sile-typesetter/casile/commit/7c24f73d55e3a8866a7cf21560bfd4d2240fd1ee))
* **class:** Disable folios when disabling headers on speads ([ec2dda6](https://github.com/sile-typesetter/casile/commit/ec2dda6bb1bb9c3e126f910b766e304faa47878f))
* **class:** Typeset section/subsection titles as raggedright ([fd84d26](https://github.com/sile-typesetter/casile/commit/fd84d26d9534475e72bc4a1372b0126c188c591d))
* **rules:** Handle project-local fonts transparently ([2cdfd9b](https://github.com/sile-typesetter/casile/commit/2cdfd9ba4af18c7dec0607ea4c0822d91c5d01cb))
* **templates:** Add alternative float implementation for dropcaps ([9474307](https://github.com/sile-typesetter/casile/commit/9474307fa0584585f71ee896fe2a1f8129341a8d))
* **templates:** Allow using a custom pandoc template ([0d34177](https://github.com/sile-typesetter/casile/commit/0d341771fecaa4486861acee81e84904f9219e3f))
* **templates:** Use LPEG to parse Turkish (non-ansi) dropcaps ([7d9c7bf](https://github.com/sile-typesetter/casile/commit/7d9c7bffb2bc356a3714f2527f958bd24441e9c8))


### Bug Fixes

* **build:** Swap unportable ‘cp -bf’ for ‘install’ ([ef64ca5](https://github.com/sile-typesetter/casile/commit/ef64ca5f3aad5b9eafa9d0d2a2bab5995258f541))
* **covers:** Enable Inkscape access to DISPLAY (temporary) ([e8ac51a](https://github.com/sile-typesetter/casile/commit/e8ac51a4b9604d1d867ba9c58927892579c32812))
* **templates:** Avoid Turkish apostrophe-hyphen hack being dropped after dropcaps ([b6d0137](https://github.com/sile-typesetter/casile/commit/b6d0137bc88ca87c79da5bc4c4986fa7e80f7601))
* **templates:** Detect Turkish alphabet as part of dropcap characters ([cb5353c](https://github.com/sile-typesetter/casile/commit/cb5353cdc8c4809d008079405e7399c76efb7bf6))


### Miscellaneous Chores

* **class:** Drop custom dropcap function, use new SILE package ([cddd698](https://github.com/sile-typesetter/casile/commit/cddd698f0a40bc09e30af35dcfa696a83f377e57))


### Code Refactoring

* **class:** Replace open-page with open-spread ([0338f17](https://github.com/sile-typesetter/casile/commit/0338f17e5b8b7ce131f74e87b245af95403fbe69))

### [0.6.4](https://github.com/sile-typesetter/casile/compare/v0.6.3...v0.6.4) (2021-08-24)


### Bug Fixes

* **docker:** Add missing Docker dep needed for some renderings ([08ec084](https://github.com/sile-typesetter/casile/commit/08ec084ca5a322b7dfa06841b4ca119c8ed371c0))
* **scripts:** Handle BUILDDIR in series sort script without trailing slash ([21a1552](https://github.com/sile-typesetter/casile/commit/21a1552e7918093b9a58420111200fd530e052c0))

### [0.6.3](https://github.com/sile-typesetter/casile/compare/v0.6.2...v0.6.3) (2021-08-19)


### Bug Fixes

* **rules:** Correct sembol→emblum in filter hook name to match function ([6e7d204](https://github.com/sile-typesetter/casile/commit/6e7d2043885dfc336e924bb09b0567f3f7647c6e))
* **rules:** Remove trailing path from default BUILDDIR ([8ef0579](https://github.com/sile-typesetter/casile/commit/8ef0579ad47c4821f7c5cff5df8e324609bc1ef4))

### [0.6.2](https://github.com/sile-typesetter/casile/compare/v0.6.1...v0.6.2) (2021-07-21)


### Bug Fixes

* **build:** Don't expect release tarballs to be Git repos ([b95e6a3](https://github.com/sile-typesetter/casile/commit/b95e6a35e6f3c8d30d92f453b6edc2ffe1df6ab2))

### [0.6.1](https://github.com/sile-typesetter/casile/compare/v0.6.0...v0.6.1) (2021-07-20)


### Bug Fixes

* **docker:** Use a keyserver that is alive ([82c37c3](https://github.com/sile-typesetter/casile/commit/82c37c39c86820c66dfbaecd895896d196102481))
* **rules:** Disambiguate `hostname` vs. $HOSTNAME ([846332d](https://github.com/sile-typesetter/casile/commit/846332dad6c867e9fc0b17967ce3d313fe048246))

## [0.6.0](https://github.com/sile-typesetter/casile/compare/v0.5.2...v0.6.0) (2021-06-02)


### Features

* **class:** Add left padded hbox function ([3c6793d](https://github.com/sile-typesetter/casile/commit/3c6793da8f0845cef1759afd16ff7e2833bab76c))
* **class:** Make rule after TOC optional ([aa5ca7f](https://github.com/sile-typesetter/casile/commit/aa5ca7f386987b88b39dde37e829e94165723087))
* **class:** Pass chapter numbering information to TOC functions ([cb9f541](https://github.com/sile-typesetter/casile/commit/cb9f541307186dfca70c8ccfaccebe96d41d28e1))
* **cli:** Reset file timestamps on ‘fontship setup’ ([41eedbd](https://github.com/sile-typesetter/casile/commit/41eedbdde9e8cf7610c974fe3cd550a8b9cb2d34))
* **rules:** Generate gitignore list based on distfiles ([4a6ca71](https://github.com/sile-typesetter/casile/commit/4a6ca712f64f403905c8760cf884cefd4f9c2334))
* **rules:** Include project-specific tagged messages to debug output ([c43a627](https://github.com/sile-typesetter/casile/commit/c43a6279a74c6c3b84767b88a8b4e9d6e0b31491))
* **tooling:** Add luacheck to lint matching CI jobs ([a9ed6d0](https://github.com/sile-typesetter/casile/commit/a9ed6d00aac15a5e6abb6ca632e4a12c5e210660))


### Bug Fixes

* **cli:** Handle no target data for Make $(shell ...) invocations ([98c9486](https://github.com/sile-typesetter/casile/commit/98c9486ef9e7962a3dda2cf89eda8f406418bc99))
* **rules:** Bring cropped PDFs back to distfiles ([ff6cdd4](https://github.com/sile-typesetter/casile/commit/ff6cdd4a0c3b7936a5e67ab2a2b5e7a4fb318691))
* **rules:** Include series content in book content dependencies ([c1dfac2](https://github.com/sile-typesetter/casile/commit/c1dfac2cb400a35331f2bbe8e1d0595f83018f89))

### [0.5.2](https://github.com/sile-typesetter/casile/compare/v0.5.1...v0.5.2) (2021-03-26)


### Bug Fixes

* **actions:** Strip refs clutter from branch name declared by GHA ([acc5cbc](https://github.com/sile-typesetter/casile/commit/acc5cbc65eba9b7996c77444312938f68a1805e7))
* **rules:** Don't die in CI if asked to install but nothing is built ([84d99e6](https://github.com/sile-typesetter/casile/commit/84d99e618f4fd6271e3b4ec610d2dcdb27a8f2e8))

### [0.5.1](https://github.com/sile-typesetter/casile/compare/v0.5.0...v0.5.1) (2021-03-23)


### Bug Fixes

* **rules:** Reinstate parent branch discovery, overzealously removed in 113d51f ([907d2e9](https://github.com/sile-typesetter/casile/commit/907d2e9027c396802f49046194fac7a6221ec942))

## [0.5.0](https://github.com/sile-typesetter/casile/compare/v0.4.7...v0.5.0) (2021-03-23)


### Features

* **cli:** Abort if being run on CaSILE sourec repo ([82f81fd](https://github.com/sile-typesetter/casile/commit/82f81fdfbba42d5864822d102a2f2ff971c78607))
* **gitlab:** Add runtime detection of GitLab CI ([7421a22](https://github.com/sile-typesetter/casile/commit/7421a228934e7fac471ee6f610c228f0c4cb3480))
* **gitlab:** Export dotenv vars for GHA feature parity ([e29d124](https://github.com/sile-typesetter/casile/commit/e29d124e881dda711b51cf86cd91a125191ad479))
* **gitlab:** Output dist artifacts by default if run in CI job ([55cf1bd](https://github.com/sile-typesetter/casile/commit/55cf1bdffcbfcb7a9aa34ad5e5b85883fae8d453))
* **gitlab:** Pass dotenv variables on a per-job basis ([8494aec](https://github.com/sile-typesetter/casile/commit/8494aec7c02986c20f60c0491e15b279f4ae1055))


### Bug Fixes

* **cli:** Return correct state for status checks ([b13e6f6](https://github.com/sile-typesetter/casile/commit/b13e6f6875b6e1493147f5bdea56cedf898dd2b7))
* **rules:** Avoid unintended shell globbing ([746c8f7](https://github.com/sile-typesetter/casile/commit/746c8f70227b416a109a6653fdf51353494b0d23))
* **rules:** Correct path to TOC file intermediary target ([6ca7e54](https://github.com/sile-typesetter/casile/commit/6ca7e547ca4e305c25237a7bad9c68c6bbfaaa5c))
* **rules:** Deduplicate file list on local install ([29fc67b](https://github.com/sile-typesetter/casile/commit/29fc67bf3b830483c669493a5244de2a50784216))
* **rules:** Don't pass empty target variable make wrapper ([364a959](https://github.com/sile-typesetter/casile/commit/364a959212c5faaacfe619a21e00cd96ddbd9fa8))
* **rules:** Remove troublesome force from draft mode ([6dce1e4](https://github.com/sile-typesetter/casile/commit/6dce1e410e140cfc8ba5e365bb9f593407723348))

### [0.4.7](https://github.com/sile-typesetter/casile/compare/v0.4.6...v0.4.7) (2021-03-19)


### Bug Fixes

* **actions:** Inject GHA specific targets in time to execute ([43995c6](https://github.com/sile-typesetter/casile/commit/43995c62481649f8481bfddf6ab10f397e22d81d))
* **actions:** Work around over-aggressive quoting ([348ad62](https://github.com/sile-typesetter/casile/commit/348ad628202e7343b0b02ea7183297eb8c0081bd))

### [0.4.6](https://github.com/sile-typesetter/casile/compare/v0.4.5...v0.4.6) (2021-03-17)


### Features

* **actions:** Allow customizing args from GHA ([71e10f4](https://github.com/sile-typesetter/casile/commit/71e10f4b737eb8500dae9e257f028b3582849b32))
* **actions:** Always invoke install-dist when run as action ([d87b89b](https://github.com/sile-typesetter/casile/commit/d87b89befc51a33b515fd42a7eab829732920568))
* **rules:** Resolve deps for ‘dist’ targets in single invocation ([a848824](https://github.com/sile-typesetter/casile/commit/a8488245a696605e6822ebdd7c100424dda748d6))


### Bug Fixes

* **actions:** Use same default targets in GH Actions as CLI ([1c5d753](https://github.com/sile-typesetter/casile/commit/1c5d753366441838233138b1c3546e0de107ece6))

### [0.4.5](https://github.com/sile-typesetter/casile/compare/v0.4.4...v0.4.5) (2021-03-16)


### Features

* **actions:** Use prebuilt image at matching version ([41848b4](https://github.com/sile-typesetter/casile/commit/41848b4047a61a054ecf6b8d2d23c970b5878012))
* **docker:** Switch to GitHub container registry beta ([808c9e4](https://github.com/sile-typesetter/casile/commit/808c9e44ae9de131c63a9b2011909fcc93558645))


### Bug Fixes

* **ci:** Deploy all release tag formats to GHPR ([321a098](https://github.com/sile-typesetter/casile/commit/321a09883883e4f9c31aa638f50afad747ed291f))
* **docker:** Add missing ‘v’ to GHPR image tags ([08a20ad](https://github.com/sile-typesetter/casile/commit/08a20ad662d7e376980964adc7bd248f118bbe6b))

### [0.4.4](https://github.com/sile-typesetter/casile/compare/v0.4.3...v0.4.4) (2021-03-16)


### Bug Fixes

* **ci:** Authenticate to publish on GH Packages Repository ([754a061](https://github.com/sile-typesetter/casile/commit/754a0616882a8b177c09b761c933ee13287b9670))

### [0.4.3](https://github.com/sile-typesetter/casile/compare/v0.4.2...v0.4.3) (2021-03-16)

### [0.4.2](https://github.com/sile-typesetter/casile/compare/v0.4.1...v0.4.2) (2021-03-15)


### Features

* **docker:** Enable font resource directory mounting ([fb68d25](https://github.com/sile-typesetter/casile/commit/fb68d2542b1896cd20a6fe0c9ef0c36411664349))


### Bug Fixes

* **docker:** Switch to BuildKit ([e5e5f5e](https://github.com/sile-typesetter/casile/commit/e5e5f5e477510ab4ebb7e52bed82309d0a814b34))
* **docker:** Work around archaic host kernels on Docker Hub ([9aef2e2](https://github.com/sile-typesetter/casile/commit/9aef2e2348230a04fe2440914e64b76519dee17c))
* **metadata:** Handle YAML keys that start with digits as strings ([3d96da3](https://github.com/sile-typesetter/casile/commit/3d96da33fb3d269eb77261854d46234bd8928cb0))
* **renderings:** Teach series title sort how to work in BUILDDIR ([8d22ce0](https://github.com/sile-typesetter/casile/commit/8d22ce0f82286e3a2ef46f73f18a1654766818b8))

### [0.4.1](https://github.com/sile-typesetter/casile/compare/v0.4.0...v0.4.1) (2021-02-04)


### Features

* **cli:** Merge config values from casile.yml ([55f0b6b](https://github.com/sile-typesetter/casile/commit/55f0b6b0a4b175538ed1f7d9dca6ea8426d75eac))


### Bug Fixes

* **cli:** Allow --version to work outside of a repo ([e751125](https://github.com/sile-typesetter/casile/commit/e75112569026ff83e4676618e5012a7504a1aca1))

## [0.4.0](https://github.com/sile-typesetter/casile/compare/v0.3.2...v0.4.0) (2021-01-26)


### ⚠ BREAKING CHANGES

* **rules:** Deprecate PUBDIR mechanism

### Features

* **actions:** Setup for use *as* GitHub Action ([4ed6be5](https://github.com/sile-typesetter/casile/commit/4ed6be5d9a8503f55f7f9f488747c4b8d8a94a3e))
* **rules:** Add default urlinfo function for simpler initial setup ([97a9729](https://github.com/sile-typesetter/casile/commit/97a9729711fd956c8f28853cc5d40b3f7b8b2024))
* **rules:** Cobble together a ‘dist’ target to package final products ([7744fa4](https://github.com/sile-typesetter/casile/commit/7744fa4cde66fe3f22c071f98486a787d0a36a64))


### Bug Fixes

* **rules:** Be more forgiving of path overrides in default rules ([99eac26](https://github.com/sile-typesetter/casile/commit/99eac26292c5e44609a9cd789214885a188c2868))
* **rules:** Don't try to build Play Books without ISBNs ([215dcf1](https://github.com/sile-typesetter/casile/commit/215dcf1b41ca67d359b92d012b2ea79dc0f7a9d3))
* **scripts:** Allow building ebooks without author metadata ([1139788](https://github.com/sile-typesetter/casile/commit/11397886fa67392bf1d40346c0aa846b1e539b9f))


### Code Refactoring

* **rules:** Deprecate PUBDIR mechanism ([2750ce9](https://github.com/sile-typesetter/casile/commit/2750ce92bc3b8ea34846466ea9bf62542e715119))

### [0.3.2](https://github.com/sile-typesetter/casile/compare/v0.3.1...v0.3.2) (2021-01-19)


### Bug Fixes

* **build:** Distribute version gen script used in configure ([a9fba92](https://github.com/sile-typesetter/casile/commit/a9fba92ef3bf4f06a9a31b09a2834492a888b703))
* **docker:** Add missing dependencies ([80aec68](https://github.com/sile-typesetter/casile/commit/80aec681fe31ab21da767fd686e99c9be8a748ab))

### [0.3.1](https://github.com/sile-typesetter/casile/compare/v0.3.0...v0.3.1) (2021-01-19)


### Bug Fixes

* **build:** Add missing developer dependency for release tooling ([889de70](https://github.com/sile-typesetter/casile/commit/889de70bd72a577722f73e798816fa210e04179d))
* **build:** Don't distribute completions, generated when building cli ([62c57ba](https://github.com/sile-typesetter/casile/commit/62c57ba1327c1005593164d553e2fcbcd8c97d26))
* **ci:** Correct name of GH package repository where releases are pushed ([023b06a](https://github.com/sile-typesetter/casile/commit/023b06a76ac544447c626eae70d7484377f7538b))

## [0.3.0](https://github.com/sile-typesetter/casile/compare/v0.2.0...v0.3.0) (2021-01-18)


### ⚠ BREAKING CHANGES

* Rename primary CaSILE include from makefile to rules

### Features

* **build:** Allow multiple side-by-side system installations ([af20612](https://github.com/sile-typesetter/casile/commit/af206121328e63b401b15165572038984308ffa3))
* **build:** Automatically bump Rust CLI version on releases ([bc8c8b2](https://github.com/sile-typesetter/casile/commit/bc8c8b281b70817809a8fa6d73a8d8e35016d691))
* **build:** Finish up renameable build support ([75d3929](https://github.com/sile-typesetter/casile/commit/75d39299343a64a302f18afdf74f66303b0c209a))
* **ci:** Add 'standard' sliding GH‌ Actions major version tags ([525c6fe](https://github.com/sile-typesetter/casile/commit/525c6fec31f171e0287c4f8e38cde82b13786fd2))
* **ci:** Deploy to GH package registry ([f9643bd](https://github.com/sile-typesetter/casile/commit/f9643bd53c112be5b3fe023fd14d5b19fb1206d3))
* **cli:** Add basic CLI arg parsing features ([c7240d4](https://github.com/sile-typesetter/casile/commit/c7240d46398d69cc3ea47daabaa7af888a3e8451))
* **cli:** Add Elvish & Powershell completion output (not installed) ([22c888c](https://github.com/sile-typesetter/casile/commit/22c888cb41486981ee310d1c3a72609dfb46e9c4))
* **cli:** Add feedback to CLI showing that commands are unimplemented ([4204511](https://github.com/sile-typesetter/casile/commit/4204511cc344bc1277d5ac36abd8ff0c154ae518))
* **cli:** Add interactive shell option and pass in some ENVs ([fd2b462](https://github.com/sile-typesetter/casile/commit/fd2b4621a6010e0084def463410769e80f5b9f12))
* **cli:** Add language parameter and parse for supported languages ([afea579](https://github.com/sile-typesetter/casile/commit/afea579c645e6e1fc54093344e3e609479cc3164))
* **cli:** Add status sub-command ([a419436](https://github.com/sile-typesetter/casile/commit/a4194366b3ee8e4fced17c7155f2d37cd79ee430))
* **cli:** Allow any CLI flag to be set from the ENV via CASILE_<flag> ([3a9e815](https://github.com/sile-typesetter/casile/commit/3a9e8158adbdad75830d51176896eb4c33abaf63))
* **cli:** Copy make target wrapper from Fontship ([cf49ea5](https://github.com/sile-typesetter/casile/commit/cf49ea56ed79ad2b5242c4a7a8d14f9b0cc47155))
* **cli:** Detect casile.mk file as project specific rules ([06cab6a](https://github.com/sile-typesetter/casile/commit/06cab6a0aa8d1480b029769ccf9a69e5953baf65))
* **cli:** Execute make targets and pass through shell commands ([9ddec52](https://github.com/sile-typesetter/casile/commit/9ddec521fbdeeda7bce3a0794d68a83d340e41c9))
* **cli:** Generate Bash, Fish, & ZSH completions ([7f79676](https://github.com/sile-typesetter/casile/commit/7f796768a15c94ddb6547ab3b443bf4833c333e8))
* **cli:** Implement custom error type with localized messages ([4249cde](https://github.com/sile-typesetter/casile/commit/4249cde67bf190ed441e4526f3bb33a7eba5d9cd))
* **cli:** Initialize Rust app for main CLI ([7d87fd6](https://github.com/sile-typesetter/casile/commit/7d87fd696265ce141b2be262524a4d04d2626ede))
* **cli:** Negotiate language and store in config at runtime ([3882c01](https://github.com/sile-typesetter/casile/commit/3882c011115555a81cd2b66efc87098e29306f58))
* **cli:** Split CLI into function for subcommands and validate args ([1f46ea2](https://github.com/sile-typesetter/casile/commit/1f46ea2909f9e1e9af85c4337141236eb8496fd4))
* **i18n:** Replace placeholders in TR translation with real strings ([080270a](https://github.com/sile-typesetter/casile/commit/080270aae11197241341d411c373de54c38a8a72))
* **renderings:** Adapt series renderings to work without metadata ([4766929](https://github.com/sile-typesetter/casile/commit/47669290f0c0094406b3a74ee6d7ab9518f06c9d))
* **rules:** Add default rule to build default formats ([6031209](https://github.com/sile-typesetter/casile/commit/603120918096dfb944da459398a619f96dda7d13))
* **rules:** Allow all formats to work as target groups ([33fe350](https://github.com/sile-typesetter/casile/commit/33fe3500acdd49da1241bbbffd37270a72abfdbb))
* **rules:** Pass some universal arguments to all IM runs ([425b5ba](https://github.com/sile-typesetter/casile/commit/425b5ba2b3aa4542e2fc288238835d293e99f076))
* Swap LGPL for AGPL license ([48b3ec4](https://github.com/sile-typesetter/casile/commit/48b3ec48792355316dc7b30989fbe1fb2ee4fe09))


### Bug Fixes

* **build:** Distribute actual completion scripts, not copies of bin ([2b686e7](https://github.com/sile-typesetter/casile/commit/2b686e72faf391fb5206d084aa73af2ca5272596))
* **build:** Don't fail on subsequent rebuilds ([980ecf3](https://github.com/sile-typesetter/casile/commit/980ecf3e550cc6812d03030fa00f5996487035a5))
* **build:** Install scripts somewhere with execute permissions ([2cb0947](https://github.com/sile-typesetter/casile/commit/2cb09473f28569cee5fae461ee7c1a6a68f9d15e))
* **build:** Keep automake inside the bumpers ([2441125](https://github.com/sile-typesetter/casile/commit/244112551b28393baf581723879f58222f7e6c9f))
* **build:** Use full path for hashbangs ([7f316a5](https://github.com/sile-typesetter/casile/commit/7f316a598788128b56677c63d661f0e63c14c261))
* **build:** Use new path to scripts ([43765bd](https://github.com/sile-typesetter/casile/commit/43765bdd6086f0a96f0b127ebcb659143e8a5f78))
* **ci:** Correct syntax for commitlint CI job ([40224be](https://github.com/sile-typesetter/casile/commit/40224beaf4f2c5b55ee9c60accecb2b3fec66816))
* **classes:** Undo 3 year old bug in cabook, blast c63a84c ([68dbed5](https://github.com/sile-typesetter/casile/commit/68dbed56bcb19f5c4396d698f75dac7ec4dcd749))
* **cli:** Correct shell flag syntax ([4853d68](https://github.com/sile-typesetter/casile/commit/4853d68237f7b686614932444d08e5d40a8efa3e))
* **cli:** Don't glob expand PDF page number arguments ([5672b43](https://github.com/sile-typesetter/casile/commit/5672b434728a47b552cb7ecc5766ddf295186b19))
* **cli:** Don't grab write lock in threads until results ready ([7b9770b](https://github.com/sile-typesetter/casile/commit/7b9770b1e482dfc079022ff0b5a5e6eaa26a8542))
* **cli:** Pass language flag through to make targets ([67cdac0](https://github.com/sile-typesetter/casile/commit/67cdac0d6e95ba1f83ffaa0d95f552a3e68f0cbf))
* **docker:** Add missing dependency for IM to work with PDFs ([345c9bc](https://github.com/sile-typesetter/casile/commit/345c9bc256c5d1d1478ec918d31e70fb20de1806))
* **docker:** Work around GH Actions env limitations, copied from Fontship ([66cfbaf](https://github.com/sile-typesetter/casile/commit/66cfbafa68a4f30ed26fc11811a75c419621c769))
* **i18n:** Pass only language not locale to make environment ([2c6201e](https://github.com/sile-typesetter/casile/commit/2c6201eeaadeabed205e91adad34eb11d619f05a))
* **promotionals:** Correct targets for series promotionals ([cec9d81](https://github.com/sile-typesetter/casile/commit/cec9d8176cabba9ac76a1a0ba3f0a684b6e90fb9))
* **renderings:** Avoid too-thin books from rendering inside-out ([8f0e595](https://github.com/sile-typesetter/casile/commit/8f0e595e23b8665d8a5b9f67637f11e4e19d1bb6))
* **renderings:** Block povray instances to run in serial ([67e3deb](https://github.com/sile-typesetter/casile/commit/67e3deb68f51b7fed32bb4353a534df548136858))
* **renderings:** Composite covers only based on extant layers ([eb542c1](https://github.com/sile-typesetter/casile/commit/eb542c16a3398ea3dab50fd2b6b032aba09124b2))
* **renderings:** Try harder to block parallel execution of povray ([59fed0c](https://github.com/sile-typesetter/casile/commit/59fed0c24531a99d7ef2e3e3acdf3629ba556067))
* **rules:** Move project specific Lua code out of order-only prerequisites ([d40cd88](https://github.com/sile-typesetter/casile/commit/d40cd88cb66a44023989588104e811d5f9511346))
* **rules:** Sort IM argument orders ([296dfad](https://github.com/sile-typesetter/casile/commit/296dfadbf5c4c9bbe9ed8599b3fe4080cb14f610))
* **scripts:** Correct build time variables with bin names ([ea27c43](https://github.com/sile-typesetter/casile/commit/ea27c43a0f1e8a2dda5c7d3c4920032c4c8659a6))
* **templates:** Disable TOC functions in unwritable directories ([541a63f](https://github.com/sile-typesetter/casile/commit/541a63f91d7ea2a98be0bdebad69aeabdfc75179))
* Fix order so we can't possibly measure an empty stack ([#72](https://github.com/sile-typesetter/casile/issues/72)) ([971964e](https://github.com/sile-typesetter/casile/commit/971964e564fb03db6bd9e9b9d775572b053c6b39))
* Only pass anonymous functions as content ([4f3c1d9](https://github.com/sile-typesetter/casile/commit/4f3c1d9e962730883955d90a4fbf588b3af36167))


### Code Refactoring

* Rename primary CaSILE include from makefile to rules ([2441622](https://github.com/sile-typesetter/casile/commit/24416224ad76c322cc4466a0864618a96a52e1b0))

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
