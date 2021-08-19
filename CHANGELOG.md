# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

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
