#!/usr/bin/env python3

from urllib.parse import unquote
import os
from shutil import copy2
from argparse import ArgumentParser
from subprocess import check_output

PLAYLIST_DIR_NAME = 'playlists'
PLAYLIST_EXTENSION = '.audpl'
FILE_LINE_PREFIX = 'uri=file://'


def find_first_dir(name, path):
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)


def playlist_directory():
    return find_first_dir(PLAYLIST_DIR_NAME, '.')


def get_currently_playing_playlist():
    playlist_number = int(check_output(['audtool', 'current-playlist']))
    with open(os.path.join(playlist_directory(), 'order')) as order_file:
        order = order_file.readlines()[0].split(' ')
    playlist = order[playlist_number - 1]
    return playlist


def files_in_playlist(playlist):
    if not playlist:
        playlist = get_currently_playing_playlist()
    with open(os.path.join(playlist_directory(), playlist + PLAYLIST_EXTENSION)) as playlist_file:
        lines = playlist_file.readlines()
    files = [
        unquote(line[len(FILE_LINE_PREFIX):]).strip()
        for line in lines if line.startswith(FILE_LINE_PREFIX)
        ]
    return [line for line in files if os.path.isfile(line)]


def copy_playlist(playlist, number, target):
    if not os.path.isdir(target):
        os.mkdir(target)
    for file in files_in_playlist(playlist)[:number]:
        copy2(file, target)


def main(args):
    parser = ArgumentParser(
        description="Copy the first N existing files of an audacious playlist to a target folder"
    )
    parser.add_argument(
        '-p', '--playlist', type=str,
        help='Name of the playlist to copy (default: currently playing)'
    )
    parser.add_argument(
        '-n', '--number', default=-1, type=int,
        help='First N files to copy from the playlist (default: all)'
    )
    parser.add_argument(
        '-t', '--target', default='.', type=str,
        help='Name of the target folder (default: current directory)'
    )
    opts = parser.parse_args(args)
    copy_playlist(opts.playlist, opts.number, opts.target)

if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
