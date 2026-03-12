#!/usr/bin/env python3
# author: daniel rode
# dependencies: typst, pandoc
# created: 11 mar 2026
# updated: -


import os
import sys
import subprocess as sp
from pathlib import Path


SRC_PATH = Path("./doc.typ")
OUT_PATH = Path("./export.pdf")


# Functions
def cd0() -> None:
    """Set working directory to the same location as the running script."""

    os.chdir(Path(__file__).resolve().parent)


# Set working directory
cd0()

# If watch mode, keep rendering PDF each time Typst document is updated
watch_mode = False
try:
    if sys.argv[1] == '--watch':
        watch_mode = True
except IndexError:
    pass

if watch_mode:
    print("CTRL+C to quit")
    while True:
        try:
            sp.run(['inotifywait', '--event', 'close_write', str(SRC_PATH)])
        except KeyboardInterrupt:
            break
        sp.run(__file__)
    sys.exit()

# Spell check
print("Spell check...")
cmd = (
    'podman',
    'run',
    '--interactive',
    'docker.io/pandoc/typst:latest',
    '--from=typst',
    '--to=plain',
)
src_plain = sp.run(
    cmd,
    check=True,
    text=True,
    input=SRC_PATH.read_text(),
    capture_output=True,
).stdout

spelling_errs = sp.run(
    ('hunspell', '-l'),
    check=True,
    text=True,
    input=src_plain,
    capture_output=True,
).stdout.strip().splitlines()
spelling_errs = set(spelling_errs)

for i in sorted(spelling_errs):
    print(i)

# Compile to PDF
print("Generating PDF...")
cmd = (
    "typst",
    "compile",
    str(SRC_PATH),
    str(OUT_PATH),
)
sp.run(cmd, check=True)

# Compile to Word DOCX
print("Generating Word doc...")
cmd = (
    'podman',
    'run',
    '--rm',
    '--interactive',
    '--volume', './:/data',
    'docker.io/pandoc/typst',
    '--output', OUT_PATH.stem + '.docx',
    # '--citeproc',
    # '--bibliography citations.bib',
    # '--csl "$csl_name"',
    # '--reference-doc style.docx',
    # '# --toc',
    # '--number-sections',
    # '# --lua-filter pagebreak.lua',
    # '# --variable title="TEST TITLE"',
    '--from=typst',
    '--to=docx',
)
sp.run(cmd, check=True, text=True, input=SRC_PATH.read_text())
