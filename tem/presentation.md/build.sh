#!/usr/bin/env bash


cd "$(dirname "$0")"
hunspell -l presentation.md | sort | uniq
pandoc ./presentation.md -o export.pptx
