#!/usr/bin/env python3

from urllib.parse import unquote
import os
from shutil import copy2
from argparse import ArgumentParser
from subprocess import check_output

DEFAULT_AUDACIOUS_CONFIG_DIR = os.path.join(
    os.environ['HOME'], '.config', 'audacious'
)


class AudaciousTools:
    """Tools for working with the audacious media player"""

    PLAYLIST_DIR_NAME = 'playlists'
    PLAYLIST_EXTENSION = '.audpl'
    FILE_LINE_PREFIX = 'uri=file://'

    def __init__(self, base_config_dir=DEFAULT_AUDACIOUS_CONFIG_DIR):
        """
        :param base_config_dir: Directory containing the audacious configuration
        """
        self._base_directory = base_config_dir
        self._playlist_dir = find_first_dir(
            self.PLAYLIST_DIR_NAME, self._base_directory
        )

    def get_currently_playing_playlist_id(self):
        order = self.get_playlist_order()
        return order[AudaciousTools._currently_playing_playlist_number() - 1]

    def get_playlist_order(self):
        """All playlist ids for this audacious instance, sorted in tab order"""
        with open(self._playlist_order_file_path()) as order_file:
            return order_file.readlines()[0].split(' ')

    @property
    def playlist_directory(self):
        """Directory where the playlists are for this audacious instance"""
        return self._playlist_dir

    def files_in_playlist(self, playlist_id):
        """
        :param playlist_id: Playlist ID (filename)
        :return: All actually existing files in that playlist
        """
        lines = self._read_playlist(playlist_id)
        return existing_files(AudaciousTools._file_entries(lines))

    def _playlist_order_file_path(self):
        return os.path.join(self.playlist_directory, 'order')

    def _read_playlist(self, playlist_id):
        with open(self._playlist_file_path(playlist_id)) as playlist_file:
            return playlist_file.readlines()

    def _playlist_file_path(self, playlist_id):
        return os.path.join(
            self.playlist_directory,
            playlist_id + AudaciousTools.PLAYLIST_EXTENSION
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


def copy_playlist(playlist_id, number, target):
    if not os.path.isdir(target):
        os.mkdir(target)

    audacious = AudaciousTools()
    if not playlist_id:
        playlist_id = audacious.get_currently_playing_playlist_id()
    for file in audacious.files_in_playlist(playlist_id)[:number]:
        copy2(file, target)


def main(args):
    parser = ArgumentParser(
        description="Copy the first N existing files of an audacious playlist"
                    " to a target folder"
    )
    parser.add_argument(
        '-p', '--playlist', type=str,
        help='ID of the playlist to copy (default: currently playing)'
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
