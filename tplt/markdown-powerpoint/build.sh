#!/usr/bin/env bash


cd "$(dirname "$0")"
pandoc ./presentation.md -o export.pptx
