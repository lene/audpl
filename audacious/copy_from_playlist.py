#!/usr/bin/env python3

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

import os
import re
from math import log10
from urllib.parse import unquote
from shutil import copy2, SameFileError
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
        self._playlist_dir = find_first_dir(self.PLAYLIST_DIR_NAME, self._base_directory)

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
        return AudaciousTools._file_entries(lines)
        return existing_files(AudaciousTools._file_entries(lines))

    def get_files_to_copy(self, number, playlist_id):
        files_to_copy = self.files_in_playlist(playlist_id)
        return files_to_copy[:number] if number else files_to_copy

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


def copy_playlist(playlist_id, number, target, verbose=False, renumber=False):
    if not os.path.isdir(target):
        os.mkdir(target)

    audacious = AudaciousTools()

    playlist_id = playlist_id or audacious.get_currently_playing_playlist_id()

    copy_files(audacious.get_files_to_copy(number, playlist_id), target, verbose, renumber)


def strip_leading_numbers(filename):
    return re.sub(r'^\d+\s*[-.]?\s*', '', filename)


def renumber_file(filename, number, total):
    return "{:0{width}d} - {}".format(
        number, strip_leading_numbers(filename), width=max(int(log10(total)) + 1, 2)
    )


def copy_files(files_to_copy, target_dir, verbose, renumber):
    for i, file in enumerate(files_to_copy):
        filename = file.split('/')[-1]
        target_filename = renumber_file(filename, i+1, len(files_to_copy)) if renumber else filename
        if verbose:
            print("{}/{}: {}".format(i + 1, len(files_to_copy), target_filename))
        copy_file(file, os.path.join(target_dir, target_filename))


def copy_file(file, target):
    try:
        copy2(file, target)
    except SameFileError as e:
        print(str(e))


def move_files_to_original_places(playlist_id):

    def find(name, path):
        for root, dirs, files in os.walk(path):
            if name in files:
                return os.path.join(root, name)

    audacious = AudaciousTools()
    playlist_id = playlist_id or audacious.get_currently_playing_playlist_id()
    for file in audacious.files_in_playlist(playlist_id):
        if os.path.isfile(file):
            continue
        filename = file.split('/')[-1]
        target_dir = '/'.join(file.split('/')[:-1])
        original_file = find(filename, '/home/preuss/Music')
        if not original_file:
            continue
        original_file_parent_dir = '/'.join(original_file.split('/')[:-1])
        files_to_move = [f for f in os.listdir(original_file_parent_dir) if os.path.isfile(original_file_parent_dir+'/'+f)]
        print('TO MOVE', original_file, target_dir, files_to_move)
        os.makedirs(target_dir, exist_ok=True)
        for f in files_to_move:
            os.rename(original_file_parent_dir+'/'+f, target_dir+'/'+f)
            print('        MOVING', original_file_parent_dir+'/'+f, target_dir)
        os.rmdir(original_file_parent_dir)


def main(args):
    parser = ArgumentParser(
        description="Copy the first N existing files of an audacious playlist to a target folder"
    )
    parser.add_argument(
        '-p', '--playlist', type=str,
        help='ID of the playlist to copy (default: currently playing)'
    )
    parser.add_argument(
        '-n', '--number', default=0, type=int,
        help='First N files to copy from the playlist (default: all)'
    )
    parser.add_argument(
        '-t', '--target', default='.', type=str,
        help='Name of the target folder (default: current directory)'
    )
    parser.add_argument(
        '-r', '--renumber', action='store_true',
        help='Rename files to have playlist position prepended to file name'
    )
    parser.add_argument(
        '-v', '--verbose', action='store_true'
    )
    parser.add_argument(
        '-m', '--move', action='store_true',
        help='Move files to the places in the file system they have on the playlist'
    )
    parser.add_argument(
        '--clean-filenames', type=str,
        help='Remove longest common substring from music files in this dir'
    )
    parser.add_argument(
        '--copy-files-newer-than-days', type=int,
        help='Copy files newer than this many days'
    )
    parser.add_argument(
        '--copy-files-newer-than-days-target', type=str,
        help='Copy files newer than this many days to *this* target directory'
    )
    opts = parser.parse_args(args)
    if opts.move:
        move_files_to_original_places(opts.playlist)
    elif opts.clean_filenames:
        clean_filenames(opts.clean_filenames)
    elif opts.copy_newer_than_days:
        copy_newest_files(opts.copy_newer_than_days, opts.copy_newer_than_days_target)
    else:
        copy_playlist(opts.playlist, opts.number, opts.target, opts.verbose, opts.renumber)

if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
