
# -*- coding: utf-8 -*-
# Author: Daniel Rode
# Dependencies: wl-clipboard
# Created: 08 Dec 2021
# Updated: -


import subprocess as sp


# Retrieve clipboard contents
def p():
    proc = sp.Popen(['wl-paste'], stdout=sp.PIPE)
    return str(proc.communicate()[0], 'utf8').strip()


# Set clipboard contents
def c(content):
    proc = sp.Popen(['wl-copy'], stdin=sp.PIPE)
    proc.communicate(bytes(content, 'utf8'))
