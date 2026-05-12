#!/usr/bin/env python3
# author: daniel rode
# dependencies: typst, pandoc
# created: 11 mar 2026
# updated: -


import os
import re
import sys
import subprocess as sp
from pathlib import Path


os.chdir(Path(__file__).parent)


PWD = Path.cwd()
SRC_PATH = Path("./doc.typ")
OUT_PATH = Path("./export.pdf")
SPELLING_EXCEPTIONS = set(i.strip() for i in """
abiotic
abiotically
blindspots
biotic
metacommunity
CSU
ChatGPT
overfishing
invasives
""".strip().splitlines())


# Functions
def pandoc(args):
    cmd = (
        'podman',
        'run',
        '--rm',
        '--interactive',
        '--volume={}:{}:ro'.format(PWD, PWD),
        '--workdir={}'.format(PWD),
        'docker.io/pandoc/typst:latest',
        *(str(a) for a in args),
    )
    return sp.run(
        cmd,
        check=True,
        text=True,
        capture_output=True,
    ).stdout


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

bib_words = set((
    re.sub('[^A-Za-z-]', '', i)  # Remove non-alpha chars
    for i in pandoc((
        '--bibliography=citations.bib',
        '--citeproc',
        '--to=plain',
        'citations.bib',
    )).replace('\n', ' ').strip().split(' ')
    if not re.search('[0-9]', i)  # "Word" must not contain numbers
))

src_plain = ' '.join(pandoc((
    '--bibliography=citations.bib',
    '--citeproc',
    '--from=typst',
    '--to=plain',
    str(SRC_PATH),
)).replace('’s', '').split('-'*72)[:-1])
print(src_plain)

spelling_errs = sp.run(
    ('hunspell', '-l'),
    check=True,
    text=True,
    input=src_plain,
    capture_output=True,
).stdout.strip().splitlines()
spelling_errs = set(spelling_errs)

for i in sorted(spelling_errs):
    if i not in (SPELLING_EXCEPTIONS | bib_words):
        print('-', i)

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



# TODO look at /home/daniel/union/edu/.../spell.py

