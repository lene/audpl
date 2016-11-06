#!/usr/bin/env python3

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

import os
from shutil import copy2

path = '.'
for root, dirs, files in os.walk(path):
    for file in files:
        if ' ' in file:
            newfile = file.replace(' ', '_')
            print(os.path.join(root, file), os.path.join(root, newfile))
            os.rename(os.path.join(root, file), os.path.join(root, newfile))