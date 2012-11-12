#!/bin/sh

latex cosmologydb
bibtex cosmologydb
latex cosmologydb
latex cosmologydb

dvips -o cosmologydb.ps cosmologydb.dvi
ps2pdf cosmologydb.ps cosmologydb.pdf

rm -f cosmologydb.aux
rm -f cosmologydb.log
rm -f cosmologydb.blg
rm -f cosmologydb.dvi
