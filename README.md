# CaSILE toolkit

The CaSILE toolkit is a collection of tools designed to automate a book publishing pipeline from very simple input to finished product with a little intervention as possible. It transforms plain text document formats and meta data into preses ready PDFs, E-Books, and rendered promotional materials.

## Dependencies

* [SILE][sile]
* [Pandoc][pandoc] ([forked][pandocsile])
* ImageMagick
* POVRay
* Zint
* Inkscape
* PDFTk
* Podofo
* Perl, Python, Lua, Node, Zsh, and a few other language interpreters!
* some other stuff (run `make dependencies` to check on them)

## Status

I've published a number of books this way but have only just decided to open source the whole thing as a toolkit. As such it needs some adaption to be more generic.

- [ ] Remove [Via Christus Publishers][viachristuus] specific resources such as Logos, default copyright notices, etc.
- [ ] Contribute the changes from my fork of Pandoc upstream.
- [ ] Make it usable in English (or any language?) instead of having all the options coded in Turkish.
- [ ] Integrate code from my _other_ toolkit that has Bible specific publishing tools.

## Usage

Include as a submodule to your book project's git repository. Include the Makefile from your project's Makefile.

    make my_book-<layout>-<options>.<format>

For example to build the press ready PDF for an Octavo size version:

    make my_book-octavo-cover.pdf

Or to build a 3D rendering of the front cover at Halfletter size:

    make my_book-halfletter-3d-front.jpg

### Input

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

[viachristus]: http://yayinlar.viachristus.com/
[sile]: http://sile-typesetter.org/
[pandoc]: http://pandoc.org/
[pandocsile]: https://github.com/alerque/pandoc/tree/sile4
