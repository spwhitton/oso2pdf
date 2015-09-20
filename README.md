# oso2pdf

## Introduction

This computer program attempts to convert book chapters downloaded
from [Oxford Scholarship Online](http://www.oxfordscholarship.com/) to
PDF.  The PDFs are better than those the OSO website can generate: the
pages of the PDF correspond to the pages of the original book, and the
typography is nicer.

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

## Installation

Runtime dependencies:

- a working installation of pandoc
- some XeLaTeX compatible font, such as Liberation Serif
- my
  [~/.pandoc/templates/pessay.latex](https://github.com/spwhitton/dotfiles/blob/master/.pandoc/templates/pessay.latex)
- my [~/texmf/tex/latex/pessay/pessay.cls](https://github.com/spwhitton/dotfiles/blob/master/texmf/tex/latex/pessay/pessay.cls)

To build and install, first
[install stack](https://github.com/commercialhaskell/stack), and then

    $ git clone git@github.com:spwhitton/oso2pdf.git
    $ cd oso2pdf
    $ stack install
