# oso2pdf

## Introduction

This computer program attempts to convert book chapters downloaded
from [Oxford Scholarship Online](http://www.oxfordscholarship.com/) to
PDF.  The PDFs are better than those the OSO website can generate: the
pages of the PDF correspond to the pages of the original book, and the
typography is nicer.  The hard work is done by
[Pandoc](http://pandoc.org/) and LaTeX.

**N.B.** This software is of use only to someone who has legitimate
access to Oxford Scholarship Online and has already downloaded a book
chapter to their own computer.  It **does not make any network
connections** to Oxford Scholarship Online and it **cannot assist in
breaking the license terms** Oxford Scholarship Online users are bound
by.

## Usage

Use your web browser to save a book chapter from Oxford Scholarship
Online to an HTML file, e.g. `my_chapter.html`.  Then run the command

    $ oso2pdf my_chapter.html

which will produce files `my_chapter-content.pdf` and
`my_chapter-notes.pdf`.  Optionally, specify the font for the
conversion; the default setting is

    $ oso2pdf --font="Liberation Serif" my_chapter.html

You may pass additional arguments to pandoc like this:

    $ oso2pdf --font="Times New Roman" my_chapter.html -- -V documentclass=pessay -V classoption=onehalf --template=pessay

In this example Pandoc is instructed to make use of the files
[~/.pandoc/templates/pessay.latex](https://github.com/spwhitton/dotfiles/blob/master/.pandoc/templates/pessay.latex)
and
[~/texmf/tex/latex/pessay/pessay.cls](https://github.com/spwhitton/dotfiles/blob/master/texmf/tex/latex/pessay/pessay.cls).
Indeed, any arguments passed after `--` will be ignored by oso2pdf and
handed on to invocations of Pandoc.

## Installation

Runtime dependencies:

- a working installation of Pandoc
- a working LaTeX installation, including XeLaTeX
- some XeLaTeX-compatible font, such as Liberation Serif

To build and install, first
[install stack](https://github.com/commercialhaskell/stack), and then

    $ git clone git@github.com:spwhitton/oso2pdf.git
    $ cd oso2pdf
    $ stack install

## Bugs

Please report bugs by e-mail to `<spwhitton@spwhitton.name>` or
`<spwhitton@email.arizona.edu>`.  I'd also appreciate hearing from you
if this program has been useful to you.
