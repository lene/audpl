#!/usr/bin/env python3

from urllib.parse import unquote
import os
from shutil import copy2
from argparse import ArgumentParser
from subprocess import check_output


class AudaciousTools:
    """Tools for working with the audacious media player"""

    PLAYLIST_DIR_NAME = 'playlists'
    PLAYLIST_EXTENSION = '.audpl'
    FILE_LINE_PREFIX = 'uri=file://'

    def __init__(self, base_config_dir):
        """
        :param base_config_dir: directory under which the audacious playlists are searched
        """
        self._base_directory = base_config_dir
        self._playlist_dir = None

    def get_currently_playing_playlist_filename(self):
        order = self.get_playlist_order()
        return order[AudaciousTools._currently_playing_playlist_number() - 1]

    def get_playlist_order(self):
        with open(self._playlist_order_file_path()) as order_file:
            return order_file.readlines()[0].split(' ')

    @property
    def playlist_directory(self):
        if self._playlist_dir is None:
            self._playlist_dir = find_first_dir(self.PLAYLIST_DIR_NAME, self._base_directory)
        return self._playlist_dir

    def files_in_playlist(self, playlist=None):
        lines = self._read_playlist(playlist)
        return existing_files(AudaciousTools._file_entries(lines))

    def _playlist_order_file_path(self):
        return os.path.join(self.playlist_directory, 'order')

    def _read_playlist(self, playlist):
        with open(self._playlist_file_path(playlist)) as playlist_file:
            return playlist_file.readlines()

    def _playlist_file_path(self, playlist):
        return os.path.join(
            self.playlist_directory, playlist + AudaciousTools.PLAYLIST_EXTENSION
        )

    @staticmethod
    def _file_entries(lines):
        return [
            unquote(line[len(AudaciousTools.FILE_LINE_PREFIX):]).strip()
            for line in lines if line.startswith(AudaciousTools.FILE_LINE_PREFIX)
        ]

    @staticmethod
    def _currently_playing_playlist_number():
        return int(check_output(['audtool', 'current-playlist']))


def existing_files(files):
    return [file for file in files if os.path.isfile(file)]


def find_first_dir(name, path):
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)


def copy_playlist(playlist, number, target):
    if not os.path.isdir(target):
        os.mkdir(target)

    audacious = AudaciousTools('.')
    if not playlist:
        playlist = audacious.get_currently_playing_playlist_filename()
    for file in audacious.files_in_playlist(playlist)[:number]:
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
