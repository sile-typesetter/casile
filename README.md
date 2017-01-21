# CaSILE toolkit

The CaSILE toolkit is a collection of tools designed to automate book publishing from start to finish. The concept is to take very simple input and turn it into a finished product with as little manual intervention as possible. It transforms plain text document formats and meta data into press ready PDFs, E-Books, and rendered promotional materials.

CaSILE (pronounced like 'castle') started out life as a submodule called `avadanlik` included inside my book project repositories (avadanlık being a Turkish word for toolkit). AS most of the parts revolve around SILE, in my head at least CaSILE became **Caleb’in Avadanlığı ile Simon’s Improved Layout Engine**, roughly translating to “Caleb's SILE Toolkit”. Come to think of it that would have been a simpler way to arrive at the name, but the project has deep Turkish roots so I'm keeping the "a" in the name name as a nod to its origin.

## Dependencies

CaSILE glues together *a lot* of different tools to build a complete publishing tool chain. Behind the scenes this is messy business. In order to make everything work I've had to use an eclectic variety of software. All of these are open source and available across platforms, but to date I've only used at tested this process **on Linux**. Adapting it to run on Mac OS should be pretty straightforward but Windows support will almost certainly require some monkey business. [Not my circus, not my monkeys][nmcnmm].

All of the following are utilized in one way or another. Currently the toolkit assumes all the following are present, but as not all of them are used to build all resources it could be possible to make this more selective. For example not having the ray tracing engine would just mean no fancy 3D previews of book covers, but you could still build PDFs and other digital formats. Not having Node would mean no Bible verse format normalization, but you should still be able to build books. Not having ImageMagick would mean no covers, but you could still process the interior of books. On the other hand not having Pandoc would be fatal.

* The [SILE][sile] Typesetter (currently I'm assuming the git HEAD version) is the workhorse behind most of the text layout.
* [Pandoc][pandoc] (specifically with [my branch with SILE support][pandocsile]) converts between document types.
* [ImageMagick][im] handles raster image processing (v7 required).
* [POVRay][pov] is used to render 3 dimensional visualizations.
* [Zint][zint] generates ISBN barcodes, QR codes, etc.
* [Inkscape][inkscape] is used to convert SVG resources into other formats.
* [PDFTk][pdftk] is used for manipulating PDFs.
* [Podofo][podofo] is used to do more stuff with PDFs.
* [Kindlegen][kindlegen] is needed to generate Amazon's E-Book formats.
* [Popplar][popplar] is used to do even more stuff with PDFs.
* Perl, Python, Lua, Node, Zsh, and a few other language interpreters!
* Some other stuff (run `make dependencies` to check on them)

You'll probably want some other things like a PDF viewer that auto updates on file changes (I recommend [zathura][zathura]), and E-Book reader like [Calibre][calibre] but these would be run yourself and are not directly executed by the toolkit.

## Status

I've published a number of books this way already and have dozens more in progress. In other wards it Works for Me™ but at the moment I expect it *only* works for me. These tool started out as just some wiring around one book. Then I worked on another book and copied them over to get started. When I hit book number 3 I realized I should make this more modular and just include in in each of my book projects. About this time I knew I wanted to open source it if it proved useful for more than one _type_ of book. That day came and went. One day I just decided to throw it out there so that it would be easier to explain what I was doing. As such it's still pretty much hard coded to my needs and needs some adaption to be more generic before it will be much use to anybody else.

Major TODO items include:

- [ ] Remove hard coded resources specific to [Via Christus Publishers][viachristus] such as logos, default copyright notices, etc.
- [ ] Contribute the changes from my fork of Pandoc upstream.
- [ ] Make it usable in English (or any language?) instead of having all the options hard coded in Turkish.
- [ ] Integrate code from my _other_ toolkit that has Bible specific publishing tools.

## Usage

1. Include as a submodule to your book project's git repository.

        git submodule add -b master https://github.com/alerque/casile.git

    Note the `-b master` here tells git you want to track the master branch and update to that whenever it changes. This is what I use for my books while I'm working on them. When I publish (and want to be able to regenerate the same output again even if the toolkit changes) I commit the current version sha to the book repo and stop tracking the master branch.

2. Include the Makefile from your project's Makefile.

        include casile/makefile

3. Build whatever resources you need. Assuming you have a book source file `my_book.md` and accompanying meta data at `my_book.yml`, the general syntax for generating resources would be:

        make my_book-<layout>-<options>.<format>

    For example to build the press ready PDF for an Octavo size version:

        make my_book-octavo-cover.pdf

    Or to build a 3D rendering of the front cover at Halfletter size:

        make my_book-halfletter-3d-front.jpg

See also the [CaSILE demos][demos] repository for a sample book project layout.

### Input

CaSILE makes a number of assumptions about the content of your repository, but how exactly you organize your git repos is still flexible. For example I have some single books in their own repositoryies, some series of books where the repository hold the whole series, others with different books with the same publisher/copyright status lumped together (and worked on in branches), a set of tracts by assorted authors but published together in another repository, etc. CaSILE assumes there is some relation between sources in each repository so granular is going to be better, but do keep things together than share resources. Note that common publisher resources can be shared in another submodule (more documentation on this to come).

A book project would typically consist of at least the following:

* makefile
* my_book.md
* my_book.yml
* my_book-background.png

Optionally books may be split into chapters:

* my_book-chapters/000-preface.md
* my_book-chapters/001-chapterone.md
* my_book-chapters/002-chaptertwo.md

### Output

In return, CaSILE will output

* Press ready PDFs (high resolution, full bleed w/ crop marks) for the specified press format
  * my_book-a5.pdf
  * my_book-a5-cover.pdf
* User friendly PDFs (normal resolution, indexed, hyperlinked) for any specified size
  * my_book-a4.pdf
* Promotional images based on the cover
  * my_book-a5-front_cover.jgp
  * my_book-square-cover.jpg
* 3D renderings of finished book
  * my_book-a5-3d-front.jpg
  * my_book-a5-3d-back.jpg
  * my_book-a5-3d-stacks.jpg
* E-Book formats
  * my_book.epub
  * my_book.mobi

### Makefile options


* `LANG` sets the language for localized file names.

   The default is English, so you might run `make book-halfletter-3d-front.png`. Changing this to Turkish:

       LANG = tr

   will mean the command you run should be `make kitap-a5-3b-on..png` to generate the same resource for a similar project with localized filenames.

* `OUTPUTDIR` determines where published files will be placed.

    Ouput files are first created in the current project directory alongside sources. Optionally CaSILE can 'pubish' finished resources to some other location.

        OUTPUTDIR = /path/to/pub/folder

    The default is unset so `make publish` will do nothing.

[viachristus]: http://yayinlar.viachristus.com/
[sile]: http://sile-typesetter.org/
[pandoc]: http://pandoc.org/
[pandocsile]: https://github.com/alerque/pandoc/tree/sile4
[im]: http://imagemagick.org/
[pov]: http://www.povray.org/
[zint]: https://zint.github.io/
[inkscape]: https://inkscape.org/
[pdftk]: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
[podofo]: http://podofo.sourceforge.net/
[popplar]: https://poppler.freedesktop.org/
[kindlegen]: https://www.amazon.com/gp/feature.html?docId=1000234621
[nmcnmm]: https://duckduckgo.com/?q=%22Not+My+Circus%2C+Not+My+Monkeys%22&ia=images
[zathura]: https://pwmt.org/projects/zathura/
[calibre]: http://calibre-ebook.com/
[demos]: https://github.com/alerque/casile-demos
