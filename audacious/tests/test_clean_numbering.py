__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

from os import listdir

from .test_junk_filenames import TestJunkFilenames

from clean_filenames import FilenameCleaner

NUM_TESTS = 3


class TestCleanNumbering(TestJunkFilenames):

    NUMBER_CASE_TEMPLATES = [
        '{:02d}a{}.mp3', '[{:02d}]{}.mp3', '{:02d}_{}.mp3', '-{:02d}. {}.mp3', '-{:02d}-{}.mp3',
        '{:02d}--{}.mp3', '{:02d}-   {}.mp3', '{:02d}-{}.mp3', '{:02d}- {}.mp3', '{:02d}.   {}.mp3',
        '{:02d}.{}.mp3', '{:02d}. {}.mp3', '{:02d}   {}.mp3', '{:02d} {}.mp3'
    ]
    SIDE_AND_NUMBER_CASE_TEMPLATES = [
        'a{:01d} {}.mp3', 'a{:01d}-{}.mp3', 'a{:01d}.{}.mp3', 'a{:01d}{}.mp3',
        '[a{:01d}]{}.mp3', 'a{:01d}]{}.mp3', '(a{:01d}){}.mp3'
    ]

    def test_space_after_number(self):
        self.create_files('{:02d} {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_multiple_spaces_after_number(self):
        self.create_files('{:02d}   {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dot_after_number(self):
        self.create_files('{:02d}. {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dot_and_no_space_after_number(self):
        self.create_files('{:02d}.{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dot_and_multiple_spaces_after_number(self):
        self.create_files('{:02d}.   {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dash_after_number(self):
        self.create_files('{:02d}- {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dash_and_no_space_after_number(self):
        self.create_files('{:02d}-{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dash_and_multiple_spaces_after_number(self):
        self.create_files('{:02d}-   {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_double_dash_after_number(self):
        self.create_files('{:02d}--{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_number_within_dashes(self):
        self.create_files('-{:02d}-{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_dash_number_dot(self):
        self.create_files('-{:02d}. {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_number_underscore(self):
        self.create_files('{:02d}_{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_bracketed_number(self):
        self.create_files('[{:02d}]{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_braced_number(self):
        self.create_files('({:02d}){}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_text_immediately_after_number(self):
        self.create_files('{:02d}a{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning()

    def test_space_after_side_and_number(self):
        self.create_files('a{:01d} {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_dash_after_side_and_number(self):
        self.create_files('a{:01d}-{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_dot_after_side_and_number(self):
        self.create_files('a{:01d}.{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_text_immediately_after_side_and_number(self):
        self.create_files('a{:01d}{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_bracketed_side_and_number(self):
        self.create_files('[a{:01d}]{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_bracket_after_side_and_number(self):
        self.create_files('a{:01d}]{}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_braced_side_and_number(self):
        self.create_files('(a{:01d}){}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_all_number_stuff_with_space_first(self):
        for template in self.NUMBER_CASE_TEMPLATES:
            self.create_files(' ' + template, NUM_TESTS)
            self._perform_and_check_cleaning()

    def test_all_side_and_number_stuff_with_space_first(self):
        for template in self.SIDE_AND_NUMBER_CASE_TEMPLATES:
            self.create_files(' ' + template, NUM_TESTS)
            self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_all_number_stuff_with_flac(self):
        for template in self.NUMBER_CASE_TEMPLATES:
            self.create_files(template.replace('mp3', 'flac'), NUM_TESTS)
            self._perform_and_check_cleaning(r'^\d+ - \w+\.flac$')

    def test_all_side_and_number_stuff_with_flac(self):
        for template in self.SIDE_AND_NUMBER_CASE_TEMPLATES:
            self.create_files(template.replace('mp3', 'flac'), NUM_TESTS)
            self._perform_and_check_cleaning(r'^a\d - \w+\.flac$')

    def test_all_number_stuff_does_not_rename_nonmusical_files(self):
        for template in self.NUMBER_CASE_TEMPLATES:
            self.create_files(template.replace('mp3', 'txt'), NUM_TESTS)
            FilenameCleaner(self.testdir.name).clean_numbering(force=True)
            for file in listdir(self.testdir.name):
                self.assertNotRegex(file, r'^\d+ - \w+\.txt$')

    def test_all_side_and_number_stuff_does_not_rename_nonmusical_files(self):
        for template in self.SIDE_AND_NUMBER_CASE_TEMPLATES:
            self.create_files(template.replace('mp3', 'txt'), NUM_TESTS)
            FilenameCleaner(self.testdir.name).clean_numbering(force=True)
            for file in listdir(self.testdir.name):
                self.assertNotRegex(file, r'^\d+ - \w+\.txt$')

    def test_unnumbered_files_are_not_renamed(self):
        self.create_files('abc{:02d}{}.mp3', NUM_TESTS)
        FilenameCleaner(self.testdir.name).clean_numbering(force=True)
        for file in listdir(self.testdir.name):
            self.assertNotRegex(file, r'^\d+ - \w+\.mp3$')

    def test_numbers_only_are_left_alone(self):
        self.create_files('{:02d}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^\d\d\.mp3$')

    def test_ttc_numbering_scheme(self):
        self.create_files('10-{:01d} {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^\d\d-\d - \w+\.mp3$')

    def test_other_ttc_numbering_scheme(self):
        self.create_files('10{:02d} {}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^\d\d\d\d - \w+\.mp3$')

    def test_doubled_numbers(self):
        self.create_files('{0:02d}{0:02d} - {1}.mp3', NUM_TESTS)
        self._perform_and_check_cleaning(r'^\d\d - \w+\.mp3$')

    def _perform_and_check_cleaning(self, regex: str=r'^\d+ - \w+\.mp3$'):
        FilenameCleaner(self.testdir.name).clean_numbering(force=True)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, regex)
