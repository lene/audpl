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

    def test_prepared_dir(self):
        from pprint import pprint
        pprint(FilenameCleaner('/home/lene/Music/Z').fix_commands_for_junk(), width=140)
        self.fail()

    def _perform_and_check_cleaning(self, regex: str=r'^\d\d\ - blah blub.mp3$'):
        FilenameCleaner(self.testdir.name).clean_junk(force=True, verbose=True)
        for file in os.listdir(self.testdir.name):
            self.assertRegex(file, regex)
