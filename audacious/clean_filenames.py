#!/usr/bin/env python3

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

import re
import os
from argparse import ArgumentParser, Namespace
from shutil import move
from typing import List, Tuple

from util import find_files


class FilenameCleaner:

    MUSIC_EXTENSIONS = ('mp3', 'flac', 'ogg', 'm4a')
    PATTERNS_TO_FIX = [
        r'\s*(\d{1,4})\s+([^/]+)',    # 01 blah
        r'\s*(\d{1,3})\.\s+([^/]+)',  # 01. blah
        r'\s*(\d{1,3})\.([^/]+)',     # 01.blah
        r'\s*(\d{1,3})--([^/]+)',     # 01--blah
        r'\s*(\d{1,3})-\s*(\D[^/]+)',   # 01-blah or 01- blah
        r'\s*-(\d{1,3})-([^/]+)',     # -01-blah
        r'\s*-\s*(\d{1,3})\.\s*([^/]+)',  # - 01. blah
        r'\s*(\d{1,3})_([^/]+)',      # 01_blah
        r'\s*\[(\d{1,3})\]([^/]+)',   # [01]blah
        r'\s*(\d{1,3})\]([^/]+)',   # 01]blah
        r'\s*\((\d{1,3})\)\s*([^/]+)',  # (01)blah
        r'\s*(\d{1,3}-\d)\s+([^/]+)',  # 01-1 blah
        r'\s*(\d{1,4})(\D[^/]*)',      # 01blah
        r'\s*([a-z]\d{1,2})\s+([^/]+)',  # a1 blah
        r'\s*([a-z]\d)-([^/]+)',      # a1-blah
        r'\s*([a-z]\d)\.([^/]+)',     # a1.blah
        r'\s*\[([a-z]\d)\]([^/]+)',   # [a1]blah
        r'\s*([a-z]\d)\]([^/]+)',     # a1]blah
        r'\s*\(([a-z]\d)\)([^/]+)',   # (a1)blah
        r'\s*([a-z]\d{1,2})(\w[^/]+)',  # a1blah
    ]
    JUNK_TO_REMOVE = {
        ' $': '',     # space(s) at beginning and before ".mp3"
        '-$': '',     # "-.mp3", " - .mp3"
        '^-': '',     # dash at beginning, with or without spaces
        '^ ': '',     # space at beginning, with or without spaces
        '--': '-',    # --
        '- -': '-',   # stray double dashes
        '_': ' ',     # underscores
        '-,': '-',    # dash before comma (BECAUSE THAT HAPPENS AND FUCKS EVERYTHING UP JFC)
        ' -(\S)': r' - \1',  # immediately leading dash with space before
        '(\S)- ': r'\1 - ',  # immediately trailing dash with space after
        '  ': ' ',    # double spaces
        ' ,': ',',    # space before comma
    }

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
            print(f'----    DIR: {self._base_directory}    ----    REMOVE: "{to_remove}"')
        for file in files:
            if verbose:
                self.print_utf8_error(
                    'MOVE ', os.path.join(self._base_directory, file),
                    os.path.join(self._base_directory, file.replace(to_remove, ''))
                )
                pass
            if force:
                os.rename(
                    os.path.join(self._base_directory, file),
                    os.path.join(self._base_directory, file.replace(to_remove, ''))
                )

    def clean_numbering(self, verbose: bool=False, force: bool=False):
        def has_screwy_numbering(filename: str) -> bool:
            return self.is_music_file(filename) and \
                   bool(re.search(r'\d+', self.filename_base(filename))) and \
                   not any([re.search(r'\d+ - [^/]+\.' + e, filename, flags=re.IGNORECASE) for e in self.MUSIC_EXTENSIONS])

        mismatches = sorted(find_files(self._base_directory, has_screwy_numbering))
        fix_commands: List[Tuple[str, str]] = []
        for file in mismatches:
            self.check_file_for_renumbering(file, fix_commands)

        self.execute_fix_commands(fix_commands, force, verbose)
        print(f"{len(fix_commands)} fixed out of {len(mismatches)}")

    def clean_junk(self, verbose: bool=False, force: bool=False):

        fix_commands = self.fix_commands_for_junk()

        self.execute_fix_commands(fix_commands, force, verbose)
        print(f"{len(fix_commands)} fixed")

    def execute_fix_commands(self, fix_commands, force, verbose):
        for source, destination, pattern_matches in fix_commands:
            if verbose and source is not None and destination is not None:
                self.print_utf8_error(source, '->', destination, pattern_matches)
            if force and source is not None and destination is not None:
                try:
                    move(source, destination)
                except FileNotFoundError:
                    if verbose:
                        self.print_utf8_error('FAIL:', source, '->', destination)

    def fix_commands_for_junk(self):
        def has_junk(filename: str) -> bool:
            return self.is_music_file(filename) and \
                   any([re.search(s, self.filename_base(filename)) for s in self.JUNK_TO_REMOVE])

        mismatches = sorted(find_files(self._base_directory, has_junk))
        fix_commands: List[Tuple[str, str, List[str]]] = []
        for mismatch in mismatches:
            root = os.path.dirname(mismatch)
            fixed = self.filename_base(mismatch)
            extension = mismatch.split('.')[-1]
            matches = []
            changed = True
            while changed:
                changed = False
                for search, replace in self.JUNK_TO_REMOVE.items():
                    new_fixed = re.sub(search, replace, fixed)
                    if new_fixed != fixed:
                        changed = True
                        matches.append(search)
                    fixed = new_fixed
            fix_commands.append((mismatch, os.path.join(root, fixed + '.' + extension), matches))
        return fix_commands

    @staticmethod
    def filename_base(filename):
        return '.'.join(filename.split('/')[-1].split('.')[:-1])

    @staticmethod
    def print_utf8_error(*string: str):
        try:
            print(*string)
        except UnicodeEncodeError:
            raise ValueError(string)

    def check_file_for_renumbering(self, file: str, fix_commands):
        for extension in self.MUSIC_EXTENSIONS:
            if re.match(r'(.*)/(\d{1,4})\.' + extension, file, flags=re.IGNORECASE):
                fix_commands.append((None, None, None))
                return
            for pattern in self.PATTERNS_TO_FIX:
                match = re.search('(.*)/' + pattern + r'\.' + extension, file, flags=re.IGNORECASE)
                if match:
                    fix_commands.append(
                        (
                            file,
                            f"{match.group(1)}/{match.group(2)} - {match.group(3)}." + extension,
                            pattern
                        )
                    )
                    return
        self.print_utf8_error('-'*8, file)

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
                f for f in os.listdir(self._base_directory)
                if os.path.isfile(os.path.join(self._base_directory, f)) and self.is_music_file(f)
            ]
        )

    @staticmethod
    def is_music_file(filename: str) -> bool:
        return any([filename.upper().endswith(e.upper()) for e in FilenameCleaner.MUSIC_EXTENSIONS])

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
        description="Perform several operations to remove junk from music file names"
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
    parser.add_argument('--clean-junk', type=str, help='Remove junk from filenames')
    return parser.parse_args(args)


def main(args):
    opts = parse_commandline(args)
    if opts.clean_filenames:
        cleaner = FilenameCleaner(opts.clean_filenames)
        cleaner.clean_filenames(
            min_length=5, verbose=opts.verbose, recurse=opts.recurse, force=opts.force
        )
    elif opts.clean_numbering:
        cleaner = FilenameCleaner(opts.clean_numbering)
        cleaner.clean_numbering(verbose=opts.verbose, force=opts.force)
    elif opts.clean_junk:
        cleaner = FilenameCleaner(opts.clean_junk)
        cleaner.clean_junk(verbose=opts.verbose, force=opts.force)


if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
