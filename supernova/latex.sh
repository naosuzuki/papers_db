#!/bin/sh

latex sndb
bibtex sndb
latex sndb
latex sndb

dvips -o sndb.ps sndb.dvi
ps2pdf sndb.ps sndb.pdf

rm -f sndb.aux
rm -f sndb.log
rm -f sndb.blg
rm -f sndb.dvi
