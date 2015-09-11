#!/usr/bin/env bash

echo "Building..."
pandoc -s -H header.tex --listings -t beamer --latex-engine=xelatex -V theme:m slides/slides.md -o slides/adinapoli.pdf
if [ 0 == $? ]; then
  open slides/adinapoli.pdf
else
  echo "ko"
fi
