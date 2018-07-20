from os.path import join
from os import listdir
from hashlib import md5

from .temp_dir_test_case import TempDirTestCase

from clean_filenames import FilenameCleaner #longest_common_substring, clean_filenames

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestCleanFilenames(TempDirTestCase):

    def test_longest_common_substring(self):
        self._longest_common_substr_is(('hello world!', 'can i help you?', 'fucking hell!'), 'hel')
        self._longest_common_substr_is(('abc', 'def', 'ghi'), '')
        self._longest_common_substr_is(('ÄÖÜ', 'ÖÜxxxxx'), 'ÖÜ')

    def _longest_common_substr_is(self, strings, expected):
        self.assertEqual(FilenameCleaner.longest_common_substring(strings), expected)

    def test_clean_filenames_succeeds(self):
        clean_filenames(self.testdir.name)

    def test_clean_filenames_removes_longest_common_part(self):
        self._create_files('{:02d} - blah blah blah - {}.mp3', 10)
        clean_filenames(self.testdir.name)
        for file in listdir(self.testdir.name):
            self.assertNotIn('blah blah blah', file)

    def test_clean_filenames_leaves_numbering_scheme_intact(self):
        self._create_files('{:02d} - blah blah blah - {}.mp3', 10)
        clean_filenames(self.testdir.name)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, r'^\d+\s*-?\s*')

    def test_clean_filenames_leaves_extension_intact(self):
        self._create_files('{:02d} - {}.mp3', 10)
        clean_filenames(self.testdir.name)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, r'^\d+\s*-?\s\w*\.mp3$')

    def test_clean_filenames_leaves_long_extension_intact(self):
        self._create_files('{:02d} - {}.prettylongextension', 10)
        clean_filenames(self.testdir.name)
        for file in listdir(self.testdir.name):
            self.assertRegex(file, r'^\d+\s*-?\s\w*\.prettylongextension$')

    def test_clean_filenames_recognizes_non_extensions(self):
        self._create_files('{:02d} - {}.ext with spaces? nah', 10)
        clean_filenames(self.testdir.name)
        for file in listdir(self.testdir.name):
            self.assertNotRegex(file, r'^\d+\s*-?\s\w*\.ext with spaces? nah$')

    def test_clean_filenames_recognizes_period_in_filename(self):
        self._create_files('{:02d} - {}.www.spam.me.mp3', 10)
        clean_filenames(self.testdir.name)
        for file in listdir(self.testdir.name):
            self.assertNotIn('.www.spam.me', file)
            self.assertRegex(file, r'^\d+\s*-?\s\w*\.mp3$')

    def test_clean_filenames_honors_min_length(self):
        self._create_files('{:02d}-blah-{}.mp3', 10)
        clean_filenames(self.testdir.name, 7)
        for file in listdir(self.testdir.name):
            self.assertIn('-blah-', file)

    def _create_files(self, template: str, number: int):
        self.files = []
        for i in range(1, number+1):
            filename = template.format(i, md5(str(i).encode('utf-8')).hexdigest())
            path = join(self.testdir.name, filename)
            self.create_file(path)
            self.files.append(path)
