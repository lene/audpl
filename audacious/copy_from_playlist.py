from urllib import unquote
from os.path import isfile, join
from shutil import copy2
from argparse import ArgumentParser


import os


def find_first_dir(name, path):
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)


def playlist_directory():
    return find_first_dir('playlists', '.')
    return 'playlists'


def copy_playlist(playlist, number, target):
    with open(join(playlist_directory(), playlist+'.audpl')) as playlist_file:
        lines = playlist_file.readlines()

    files = [
        unquote(line[len('uri=file://'):]).strip()
        for line in lines if line.startswith('uri=file://')
        ]
    files = [line for line in files if isfile(line)]
    for file in files[:number]:
        copy2(file, target)


def main(args):
    parser = ArgumentParser(
        description="Copy the first N files of a playlist to a target folder"
    )
    parser.add_argument(
        '-p', '--playlist', required=True, type=str, help='Name of the playlist to copy'
    )
    parser.add_argument(
        '-n', '--number', default=-1, type=int, help='First N files to copy from the playlist'
    )
    parser.add_argument(
        '-t', '--target', default='.', type=str, help='Name of the target directory'
    )
    opts = parser.parse_args(args)
    copy_playlist(opts.playlist, opts.number, opts.target)

if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
