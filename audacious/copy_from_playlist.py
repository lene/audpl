from urllib import unquote
import os
from shutil import copy2
from argparse import ArgumentParser

PLAYLIST_DIR_NAME = 'playlists'
PLAYLIST_EXTENSION = '.audpl'
FILE_LINE_PREFIX = 'uri=file://'


def find_first_dir(name, path):
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)


def playlist_directory():
    return find_first_dir(PLAYLIST_DIR_NAME, '.')


def copy_playlist(playlist, number, target):
    with open(os.path.join(playlist_directory(), playlist + PLAYLIST_EXTENSION)) as playlist_file:
        lines = playlist_file.readlines()

    files = [
        unquote(line[len(FILE_LINE_PREFIX):]).strip()
        for line in lines if line.startswith(FILE_LINE_PREFIX)
    ]
    files = [line for line in files if os.path.isfile(line)]
    for file in files[:number]:
        copy2(file, target)


def main(args):
    parser = ArgumentParser(
        description="Copy the first N existing files of an audacious playlist to a target folder"
    )
    parser.add_argument(
        '-p', '--playlist', required=True, type=str, help='Name of the playlist to copy'
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
