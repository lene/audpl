from os.path import join
from os import listdir
from hashlib import md5

from .temp_dir_test_case import TempDirTestCase

from clean_filenames import FilenameCleaner

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestJunkFilenames(TempDirTestCase):

    def create_files(self, template: str, number: int):
        self.files = []
        for i in range(1, number+1):
            filename = template.format(i, md5(str(i).encode('utf-8')).hexdigest())
            path = join(self.testdir.name, filename)
            self.create_file(path)
            self.files.append(path)


class TestCleanFilenames(TestJunkFilenames):

    def test_longest_common_substring(self):
        self._longest_common_substr_is(('hello world!', 'can i help you?', 'fucking hell!'), 'hel')
        self._longest_common_substr_is(('abc', 'def', 'ghi'), '')
        self._longest_common_substr_is(('ÄÖÜ', 'ÖÜxxxxx'), 'ÖÜ')

    def _longest_common_substr_is(self, strings, expected):
        self.assertEqual(FilenameCleaner.longest_common_substring(strings), expected)

    def test_clean_filenames_succeeds(self):
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)

    def test_clean_filenames_removes_longest_common_part(self):
        self.create_files('{:02d} - blah blah blah - {}.mp3', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)
        for file in listdir(self.testdir.name):
            self.assertNotIn('blah blah blah', file)

    def test_clean_filenames_leaves_numbering_scheme_intact(self):
        self.create_files('{:02d} - blah blah blah - {}.mp3', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, r'^\d+\s*-?\s*')

    def test_clean_filenames_leaves_extension_intact(self):
        self.create_files('{:02d} - {}.mp3', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, r'^\d+\s*-?\s\w*\.mp3$')

    def test_clean_filenames_leaves_long_extension_intact(self):
        self.create_files('{:02d} - {}.prettylongextension', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, r'^\d+\s*-?\s\w*\.prettylongextension$')

    def test_clean_filenames_recognizes_non_extensions(self):
        self.create_files('{:02d} - {}.ext with spaces? nah', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)
        for file in listdir(self.testdir.name):
            self.assertNotRegex(file, r'^\d+\s*-?\s\w*\.ext with spaces? nah$')

    def test_clean_filenames_recognizes_period_in_filename(self):
        self.create_files('{:02d} - {}.www.spam.me.mp3', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(force=True)
        for file in listdir(self.testdir.name):
            self.assertNotIn('.www.spam.me', file)
            self.assertRegex(file, r'^\d+\s*-?\s\w*\.mp3$')

    def test_clean_filenames_honors_min_length(self):
        self.create_files('{:02d}-blah-{}.mp3', 10)
        FilenameCleaner(self.testdir.name).clean_filenames(min_length=7, force=True)
        for file in listdir(self.testdir.name):
            self.assertIn('-blah-', file)


class TestCleanNumbering(TestJunkFilenames):

    def test_space_after_number(self):
        self.create_files('{:02d} {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_multiple_spaces_after_number(self):
        self.create_files('{:02d}   {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dot_after_number(self):
        self.create_files('{:02d}. {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dot_and_no_space_after_number(self):
        self.create_files('{:02d}.{}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dot_and_multiple_spaces_after_number(self):
        self.create_files('{:02d}.   {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dash_after_number(self):
        self.create_files('{:02d}- {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dash_and_no_space_after_number(self):
        self.create_files('{:02d}-{}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dash_and_multiple_spaces_after_number(self):
        self.create_files('{:02d}-   {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_double_dash_after_number(self):
        self.create_files('{:02d}--{}.mp3', 3)
        self.skipTest('FIXME')
        self._perform_and_check_cleaning()

    def test_number_within_dashes(self):
        self.create_files('-{:02d}-{}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_dash_number_dot(self):
        self.create_files('-{:02d}. {}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_number_underscore(self):
        self.create_files('{:02d}_{}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_bracketed_number(self):
        self.create_files('[{:02d}]{}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_braced_number(self):
        self.create_files('({:02d}){}.mp3', 3)
        self._perform_and_check_cleaning()

    def test_text_immediately_after_number(self):
        self.create_files('{:02d}{}.mp3', 3)
        self.skipTest('FIXME')
        self._perform_and_check_cleaning()

    def test_space_after_side_and_number(self):
        self.create_files('a{:01d} {}.mp3', 3)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_dash_after_side_and_number(self):
        self.create_files('a{:01d}-{}.mp3', 3)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_dot_after_side_and_number(self):
        self.create_files('a{:01d}.{}.mp3', 3)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_text_immediately_after_side_and_number(self):
        self.create_files('a{:01d}{}.mp3', 3)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_bracketed_side_and_number(self):
        self.create_files('[a{:01d}]{}.mp3', 3)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_bracket_after_side_and_number(self):
        self.create_files('a{:01d}]{}.mp3', 3)
        self.skipTest('FIXME')
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def test_braced_side_and_number(self):
        self.create_files('(a{:01d}){}.mp3', 3)
        self._perform_and_check_cleaning(r'^a\d - \w+\.mp3$')

    def _perform_and_check_cleaning(self, regex: str=r'^\d+ - \w+\.mp3$'):
        FilenameCleaner(self.testdir.name).clean_numbering(force=True)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, regex)
