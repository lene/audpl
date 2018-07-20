#!/usr/bin/env python3

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

import re
import os
from argparse import ArgumentParser, Namespace
from shutil import move
from typing import List

from util import find_files


class FilenameCleaner:

    MUSIC_EXTENSIONS = ('mp3', 'flac', 'ogg', 'm4a')
    PATTERNS_TO_FIX = [
        r'\s*(\d{1,3})\s+(.+)',      # 01 blah
        r'\s*(\d{1,3})\.\s+(.+)',    # 01. blah
        r'\s*(\d{1,3})\.(.+)',     # 01.blah
        r'\s*(\d{1,3})--(.+)',     # 01--blah
        r'\s*(\d{1,3})-\s*(.+)',   # 01-blah or 01- blah
        r'\s*-(\d{1,3})-(.+)',     # -01-blah
        r'\s*-\s*(\d{1,3})\.\s*(.+)',  # - 01. blah
        r'\s*(\d{1,3})_(.+)',      # 01_blah
        r'\s*\[(\d{1,3})\](.+)',   # [01]blah
        r'\s*\((\d{1,3})\)\s*(.+)',  # (01)blah
        r'\s*(\d{1,3})(\D.*)',      # 01blah
        r'\s*([a-z]\d{1,2})\s+(.+)',    # a1 blah
        r'\s*([a-z]\d)-(.+)',      # a1-blah
        r'\s*([a-z]\d)\.(.+)',     # a1.blah
        r'\s*\[([a-z]\d)\](.+)',   # [a1]blah
        r'\s*([a-z]\d)\](.+)',     # a1]blah
        r'\s*\(([a-z]\d)\)(.+)',   # (a1)blah
        r'\s*([a-z]\d)(.+)',  # a1blah
    ]
    NONSENSE_TO_REMOVE = [
        # space(s) at beginning and before ".mp3"
        # "-.mp3", " - .mp3"
        # dash at beginning, with or without spaces
        # --
        # _
        # double spaces
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
            print(f'--  DIR: {self._base_directory}  --  REMOVE: "{to_remove}"')
        for file in files:
            if verbose:
                self.print_utf8_error(
                    'MOVE ', os.path.join(self._base_directory, file),
                    os.path.join(self._base_directory, file.replace(to_remove, ''))
                )
            if force:
                os.rename(os.path.join(self._base_directory, file), os.path.join(self._base_directory, file.replace(to_remove, '')))

    def print_utf8_error(self, *string: str):
        try:
            print(*string)
        except UnicodeEncodeError:
            raise ValueError(string)
            # raise ValueError(self._base_directory)

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

    def check_file_for_renumbering(self, file: str, fix_commands):
        for extension in self.MUSIC_EXTENSIONS:
            if re.match(r'(.*)/(\d{1,4})\.' + extension, file, flags=re.IGNORECASE):
                fix_commands.append((None, None))
                return
            for pattern in self.PATTERNS_TO_FIX:
                match = re.search('(.*)/' + pattern + r'\.' + extension, file, flags=re.IGNORECASE)
                if match:
                    fix_commands.append((file, f"{match.group(1)}/{match.group(2)} - {match.group(3)}." + extension))
                    return
        self.print_utf8_error(file)

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


def parse_commandline(args: List[str]) -> Namespace:
    parser = ArgumentParser(
        description="Copy the first N existing files of an audacious playlist to a target folder"
    )
    parser.add_argument(
        '-v', '--verbose', action='store_true'
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
    return parser.parse_args(args)


def main(args):
    opts = parse_commandline(args)
    if opts.clean_filenames:
        cleaner = FilenameCleaner(opts.clean_filenames)
        cleaner.clean_filenames(min_length=5, verbose=opts.verbose, recurse=opts.recurse, force=opts.force)
    elif opts.clean_numbering:
        cleaner = FilenameCleaner(opts.clean_numbering)
        cleaner.clean_numbering(verbose=opts.verbose, force=opts.force)


if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
