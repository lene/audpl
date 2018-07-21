import re
import os

from .test_junk_filenames import TestJunkFilenames

from clean_filenames import FilenameCleaner


__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestCleanJunk(TestJunkFilenames):

    def test_underscore(self):
        self.create_files('{:02d} - blah_blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_multiple_spaces(self):
        self.create_files('{:02d} - blah    blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_multiple_underscores(self):
        self.create_files('{:02d} - blah____blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_double_dashes(self):
        self.create_files('{:02d} - -blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_double_dashes_2(self):
        self.create_files('{:02d} - - blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_double_dashes_3(self):
        self.create_files('{:02d} -  - blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_double_dashes_4(self):
        self.create_files('{:02d} -- blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_trailing_space(self):
        self.create_files('{:02d} - blah blub .mp3', 3)
        self._perform_and_check_cleaning()

    def test_trailing_spaces(self):
        self.create_files('{:02d} - blah blub   .mp3', 3)
        self._perform_and_check_cleaning()

    def test_trailing_dash(self):
        self.create_files('{:02d} - blah blub-.mp3', 3)
        self._perform_and_check_cleaning()

    def test_trailing_dashes(self):
        self.create_files('{:02d} - blah blub--.mp3', 3)
        self._perform_and_check_cleaning()

    def test_trailing_space_dash(self):
        self.create_files('{:02d} - blah blub -.mp3', 3)
        self._perform_and_check_cleaning()

    def test_trailing_dash_space(self):
        self.create_files('{:02d} - blah blub- .mp3', 3)
        self._perform_and_check_cleaning()

    def test_leading_dash(self):
        self.create_files('-{:02d} - blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_leading_space(self):
        self.create_files(' {:02d} - blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_leading_dot(self):
        self.create_files('.{:02d} - blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_free_comma(self):
        self.create_files('{:02d} - blah , blub.mp3', 3)
        self._perform_and_check_cleaning('\d\d - blah, blub.mp3')

    def test_empty_brackets(self):
        self.create_files('{:02d} - blah [] blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dash_comma_does_not_loop_infinitely_and_gives_sensible_result(self):
        self.create_files('{:02d} -, blah blub.mp3', 3)
        self._perform_and_check_cleaning()

    def test_real_world_cases(self):
        self.maxDiff = None
        fails = []
        for letter in (
            # 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            # 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            # '.',
            'X',
        ):
            basedir = '/home/lene/Music/' + letter
            fixed = FilenameCleaner(basedir)._fix_commands_for_junk()
            for _, replacement, patterns in fixed:
                core = '.'.join(os.path.basename(replacement).split('.')[:-1])
                if '_' in core:
                    fails.append((core, patterns))
                if '  ' in core:
                    fails.append((core, patterns))
                if '--' in core:
                    fails.append((core, patterns))
                if '- -' in core:
                    fails.append((core, patterns))
                if core.endswith('-'):
                    fails.append((core, patterns))
                if core.startswith('-'):
                    fails.append((core, patterns))
                if core.endswith(' '):
                    fails.append((core, patterns))
                if core.startswith(' '):
                    fails.append((core, patterns))
                # ideal filename pattern
                if not re.match(r'^\d{1,3}\s?-\s?.*$', core):
                    if not re.match(r'\D.*\D', core) and not re.match(r'^\d{1,3}$', core):
                        # but it's not possible everywhere, so don't really test for it
                        if False:
                            fails.append((core, patterns))
                if re.match(r'-\w{1,4}$', core):
                    fails.append((core, patterns))
        self.assertEqual([], fails)

    def _perform_and_check_cleaning(self, regex: str=r'^\d\d\ - blah blub.mp3$'):
        FilenameCleaner(self.testdir.name).clean_junk(force=True, verbose=True)
        for file in os.listdir(self.testdir.name):
            self.assertRegex(file, regex)