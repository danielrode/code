#!/usr/bin/env bash


cd "$(dirname "$0")"
hunspell -l presentation.md
pandoc ./presentation.md -o export.pptx
