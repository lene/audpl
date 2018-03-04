#!/usr/bin/python3
from os import listdir, walk
from os.path import isfile, join
from re import match, IGNORECASE
from subprocess import call
from pickle import dump, load

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

PICTURE_DIR = '/home/lene/Pictures/Chicks'
PROGRESS_FILE = 'done.pickle'

present_wallpapers = [
    f for mypath in ('00-Large/', '00-Small/', '.') for f in listdir(mypath)
    if isfile(join(mypath, f))
]

try:
    with open(PROGRESS_FILE, 'rb') as progress_file:
        done = load(progress_file)
except FileNotFoundError:
    done = []

print('done:', done)

to_try = [
    (root, file) for root, dir, files in walk(PICTURE_DIR) for file in files
    if match('.*\.jp.?g$', file, IGNORECASE) or match('.*\.png$', file, IGNORECASE)
    if file not in present_wallpapers + done
]

try:
    for i, (root, file) in enumerate(sorted(to_try)):
        print("{} [{}/{}]".format(join(root, file), i, len(to_try)))
        returncode = call(['xv', '-nolim', join(root, file)])
        if returncode == 0:
            done.append(file)
finally:
    print('done:', done)
    with open(PROGRESS_FILE, 'wb') as progress_file:
        dump(done, progress_file)
