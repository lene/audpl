#!/usr/bin/env python3

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

import os
import re
from math import log10
from urllib.parse import unquote
from shutil import copy2, move, SameFileError
from argparse import ArgumentParser
from subprocess import check_output
from typing import List
from time import time

DEFAULT_AUDACIOUS_CONFIG_DIR = os.path.join(
    os.environ['HOME'], '.config', 'audacious'
)


class AudaciousTools:
    """Tools for working with the audacious media player"""

    PLAYLIST_DIR_NAME = 'playlists'
    PLAYLIST_EXTENSION = '.audpl'
    FILE_LINE_PREFIX = 'uri=file://'

    def __init__(self, base_config_dir: str=DEFAULT_AUDACIOUS_CONFIG_DIR):
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

    def files_in_playlist(self, playlist_id: str):
        """
        :param playlist_id: Playlist ID (filename)
        :return: All actually existing files in that playlist
        """
        lines = self._read_playlist(playlist_id)
        return AudaciousTools._file_entries(lines)
        return existing_files(AudaciousTools._file_entries(lines))

    def get_files_to_copy(self, number: int, playlist_id: str):
        files_to_copy = self.files_in_playlist(playlist_id)
        return files_to_copy[:number] if number else files_to_copy

    def _playlist_order_file_path(self):
        return os.path.join(self.playlist_directory, 'order')

    def _read_playlist(self, playlist_id: str):
        with open(self._playlist_file_path(playlist_id)) as playlist_file:
            return playlist_file.readlines()

    def _playlist_file_path(self, playlist_id: str):
        return os.path.join(self.playlist_directory, playlist_id + AudaciousTools.PLAYLIST_EXTENSION)

    @staticmethod
    def _file_entries(lines: int):
        return [
            unquote(line[len(AudaciousTools.FILE_LINE_PREFIX):]).strip()
            for line in lines if line.startswith(AudaciousTools.FILE_LINE_PREFIX)
        ]

    @staticmethod
    def _currently_playing_playlist_number():
        return int(check_output(['audtool', 'current-playlist']))


class FilenameCleaner:

    MUSIC_EXTENSIONS = ('mp3', 'flac', 'ogg', 'm4a')
    PATTERNS_TO_FIX = [
        r'(\d{1,3}) (.+)',  # 01 blah
        r'(\d{1,3})\. (.+)',  # 01. blah
        r'(\d{1,3})\.(.+)',  # 01.blah
        r'(\d{1,3})- (.+)',  # 01- blah
        r'(\d{1,3})--(.+)',  # 01--blah
        r'(\d{1,3})-(.+)',  # 01-blah
        r'(\d{1,3})_(.+)',  # 01_blah
        r'\[(\d{1,3})\](.+)',  # [01]blah
        r'\((\d{1,3})\)(.+)',  # (01)blah
        r'(\d{1,3})(\D+)',  # 01blah
        r'([a-z]\d) (.+)',  # a1 blah
        r'([a-z]\d)-(.+)',  # a1-blah
    ]

    def __init__(self, basedir):
        self._base_directory = basedir

    def clean_filenames(
            self, min_length: int=0, verbose: bool=False, recurse: bool=False, force: bool=False
    ) -> None:
        if recurse:
            subdirs = sorted(
                [name for name in os.listdir(self._base_directory)
                 if os.path.isdir(os.path.join(self._base_directory, name))]
            )
            for subdir in subdirs:
                cleaner = FilenameCleaner(os.path.join(self._base_directory, subdir))
                cleaner.clean_filenames(min_length, verbose, recurse, force)

        files = self.get_music_files()
        to_remove = self.longest_common_substring(files)
        to_remove = self.exclude_common_use_cases(to_remove)
        if min_length and len(to_remove) < min_length:
            return
        if verbose:
            print('REMOVE:', to_remove)
        for file in files:
            if verbose:
                print('MOVE ', os.path.join(self._base_directory, file), os.path.join(self._base_directory, file.replace(to_remove, '')))
            if force:
                os.rename(os.path.join(self._base_directory, file), os.path.join(self._base_directory, file.replace(to_remove, '')))

    def clean_numbering(self, verbose: bool = False, force: bool = False):
        def numbering_mismatch(filename: str) -> bool:
            return self.is_music_file(filename) and \
                   bool(re.search(r'\d+', '.'.join(filename.split('/')[-1].split('.')[:-1]))) and \
                   not re.search(r'\d+ - .+\.mp3', filename) and \
                   not re.search(r'\d+ - .+\.flac', filename) and \
                   not re.search(r'\d+ - .+\.ogg', filename) and \
                   not re.search(r'\d+ - .+\.m4a', filename)

        mismatches = sorted(find_files(self._base_directory, numbering_mismatch))
        fix_commands = []
        for file in mismatches:
            self.check_file_for_renumbering(file, fix_commands)

        for source, destination in fix_commands:
            if verbose and source is not None and destination is not None:
                print(source, '->', destination)
            if force and source is not None and destination is not None:
                try:
                    move(source, destination)
                except FileNotFoundError:
                    pass
        print(f"{len(fix_commands)} fixed out of {len(mismatches)}")

    @classmethod
    def check_file_for_renumbering(cls, file: str, fix_commands):
        for extension in cls.MUSIC_EXTENSIONS:
            if re.match(r'(.*)/(\d{1,4})\.' + extension, file, flags=re.IGNORECASE):
                fix_commands.append((None, None))
                return
            for pattern in cls.PATTERNS_TO_FIX:
                match = re.search('(.*)/' + pattern + r'\.' + extension, file, flags=re.IGNORECASE)
                if match:
                    fix_commands.append((file, f"{match.group(1)}/{match.group(2)} - {match.group(3)}.mp3"))
                    return
        print(file)

    @staticmethod
    def exclude_common_use_cases(to_remove):
        if to_remove[:3] == ' - ':
            to_remove = to_remove[3:]
        if re.match(r'.*\.\w+$', to_remove):
            to_remove = re.sub(r'\.\w+?$', '', to_remove)
        if to_remove.endswith('-'):
            to_remove = to_remove[:-1]
        elif to_remove.startswith('-'):
            to_remove = to_remove[1:]
        return to_remove

    def get_music_files(self):
        return sorted(
            [
                name for name in os.listdir(self._base_directory)
                if os.path.isfile(os.path.join(self._base_directory, name)) and self.is_music_file(name)
            ]
        )

    @staticmethod
    def is_music_file(filename: str) -> bool:
        return any([filename.upper().endswith(ext.upper()) for ext in FilenameCleaner.MUSIC_EXTENSIONS])

    @staticmethod
    def longest_common_substring(data: List[str]):
        substr = ''
        if len(data) > 1 and len(data[0]) > 0:
            for i in range(len(data[0])):
                for j in range(len(data[0])-i+1):
                    if j > len(substr) and all(data[0][i:i+j] in x for x in data):
                        substr = data[0][i:i+j]
        return substr


def existing_files(files: List[str]):
    return [file for file in files if os.path.isfile(file)]


def find_first_dir(name: str, path: str):
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)


def copy_playlist(
        playlist_id: str, number: int, target: str, verbose: bool=False, renumber: bool=False,
        audacious=None
):
    if not os.path.isdir(target):
        os.mkdir(target)

    if audacious is None:
        audacious = AudaciousTools()

    playlist_id = playlist_id or audacious.get_currently_playing_playlist_id()

    copy_files(audacious.get_files_to_copy(number, playlist_id), target, verbose, renumber)


def strip_leading_numbers(filename: str):
    return re.sub(r'^\d+\s*[-.]?\s*', '', filename)


def renumber_file(filename: str, number: int, total: int):
    return "{:0{width}d} - {}".format(
        number, strip_leading_numbers(filename), width=max(int(log10(total)) + 1, 2)
    )


def copy_files(files_to_copy: List[str], target_dir: str, verbose: bool, renumber: bool):
    for i, file in enumerate(files_to_copy):
        filename = file.split('/')[-1]
        target_filename = renumber_file(filename, i+1, len(files_to_copy)) if renumber else filename
        if verbose:
            print("{}/{}: {}".format(i + 1, len(files_to_copy), target_filename))
        copy_file(file, os.path.join(target_dir, target_filename))


def copy_file(file: str, target: str):
    try:
        copy2(file, target)
    except SameFileError as e:
        print(str(e))


def move_files_to_original_places(
        playlist_id: str, music_dir: str='/home/preuss/Music', verbose: bool=False, audacious=None
):

    def find(name, path):
        for root, dirs, files in os.walk(path):
            if name in files:
                return os.path.join(root, name)

    if audacious is None:
        audacious = AudaciousTools()

    playlist_id = playlist_id or audacious.get_currently_playing_playlist_id()
    for file in audacious.files_in_playlist(playlist_id):
        if os.path.isfile(file):
            continue
        filename = file.split('/')[-1]
        target_dir = '/'.join(file.split('/')[:-1])
        original_file = find(filename, music_dir)
        if not original_file:
            continue
        original_file_parent_dir = '/'.join(original_file.split('/')[:-1])
        files_to_move = [f for f in os.listdir(original_file_parent_dir) if os.path.isfile(original_file_parent_dir+'/'+f)]
        if verbose:
            print('TO MOVE', original_file, target_dir, files_to_move)
        os.makedirs(target_dir, exist_ok=True)
        for f in files_to_move:
            os.rename(original_file_parent_dir+'/'+f, target_dir+'/'+f)
            if verbose:
                print('        MOVING', original_file_parent_dir+'/'+f, target_dir)
        os.rmdir(original_file_parent_dir)


def find_files(base_path, condition):
    return [
        os.path.join(root, file)
        for root, _, files in os.walk(base_path)
        for file in files
        if os.path.exists(os.path.join(root, file))
        if condition(os.path.join(root, file))
    ]


def find_newer_than(base_path, seconds):
    return find_files(base_path, lambda file: time() - os.path.getctime(file) < seconds)


def copy_newest_files(src_dir: str, target_dir: str, max_days: int, verbose: bool=False):
    to_copy = sorted(find_newer_than(src_dir, max_days * 24 * 60 * 60))
    for i, file in enumerate(to_copy):
        basedir = os.path.join('/', *os.path.split(file)[:-1])
        target_subdir = basedir.replace(src_dir, '').split(os.path.sep)
        target_path = os.path.join(target_dir, *target_subdir)
        os.makedirs(target_path, exist_ok=True)
        if verbose:
            print("{}/{} {}".format(i+1, len(to_copy), file.replace(src_dir, '').strip('/')))
        if not os.path.isfile(os.path.join(file, target_path)):
            try:
                copy2(file, target_path)
            except OSError:
                pass


def get_options(args: List[str]):
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
    parser.add_argument('--recurse', action='store_true', help='Scan subdirectories recursively')
    parser.add_argument('-f', '--force', action='store_true', help='Force rename files')
    parser.add_argument(
        '--clean-numbering', type=str,
        help='Number music files in this dir to let them start with "%d - "'
    )
    parser.add_argument(
        '--copy-files-newer-than-days', type=int, help='Copy files newer than this many days'
    )
    parser.add_argument(
        '--copy-files-newer-than-days-source', type=str,
        default=os.path.expanduser('~/Music'),
        help='If copying files newer than this many days, use *this* source directory.\n' +
             'Default: ' + os.path.expanduser('~/Music')
    )
    parser.add_argument(
        '--copy-files-newer-than-days-target', type=str,
        help='If copying files newer than this many days, use *this* target directory'
    )
    return parser.parse_args(args)


def main(args):
    opts = get_options(args)
    if opts.move:
        move_files_to_original_places(opts.playlist, verbose=opts.verbose)
    elif opts.clean_filenames:
        cleaner = FilenameCleaner(opts.clean_filenames)
        cleaner.clean_filenames(min_length=5, verbose=opts.verbose, recurse=opts.recurse, force=opts.force)
    elif opts.clean_numbering:
        cleaner = FilenameCleaner(opts.clean_numbering)
        cleaner.clean_numbering(verbose=opts.verbose, force=opts.force)
    elif opts.copy_files_newer_than_days:
        copy_newest_files(
            opts.copy_files_newer_than_days_source, opts.copy_files_newer_than_days_target,
            opts.copy_files_newer_than_days, verbose=opts.verbose
        )
    else:
        copy_playlist(opts.playlist, opts.number, opts.target, opts.verbose, opts.renumber)


if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
