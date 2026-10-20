
# author: daniel rode
# dependencies: wl-clipboard
# created: 08 dec 2021
# updated: 19 oct 2026


import os
import sys
import json
import subprocess as sp
from pathlib import Path


# Retrieve clipboard contents
def p():
    proc = sp.Popen(['wl-paste'], stdout=sp.PIPE)
    return str(proc.communicate()[0], 'utf8').strip()


# Set clipboard contents
def c(content):
    proc = sp.Popen(['wl-copy'], stdin=sp.PIPE)
    proc.communicate(bytes(content, 'utf8'))
