from functools import partial
from os import listdir
from typing import Callable

from .test_junk_filenames import TestJunkFilenames

from clean_filenames import FilenameCleaner


__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestCleanFilenames(TestJunkFilenames):

    def test_longest_common_substring_finds_substring(self):
        self._longest_common_substr_is(('hello world!', 'can i help you?', 'fucking hell!'), 'hel')

    def test_longest_common_substring_if_there_is_none(self):
        self._longest_common_substr_is(('abc', 'def', 'ghi'), '')

    def test_longest_common_substring_with_utf8(self):
        self._longest_common_substr_is(('ÄÖÜ', 'ÖÜxxxxx'), 'ÖÜ')

    def test_clean_filenames_succeeds(self):
        self._perform_cleaning()

    def test_clean_filenames_removes_longest_common_part(self):
        self.create_files('{:02d} - blah blah blah - {}.mp3', 10)
        self._perform_and_check_cleaning(partial(self.assertNotIn, 'blah blah blah'))

    def test_clean_filenames_leaves_numbering_scheme_intact(self):
        self.create_files('{:02d} - blah blah blah - {}.mp3', 10)
        self._perform_and_check_cleaning_with_regex(r'^\d+\s*-?\s*')

    def test_clean_filenames_leaves_extension_intact(self):
        self.create_files('{:02d} - {}.mp3', 10)
        self._perform_and_check_cleaning_with_regex(r'^\d+\s*-?\s\w*\.mp3$')

    def test_clean_filenames_leaves_long_extension_intact(self):
        self.create_files('{:02d} - {}.prettylongextension', 10)
        self._perform_and_check_cleaning_with_regex(r'^\d+\s*-?\s\w*\.prettylongextension$')

    def test_clean_filenames_recognizes_non_extensions(self):
        self.create_files('{:02d} - {}.ext with spaces? nah', 10)
        self._perform_and_check_cleaning(
            partial(self.assertNotRegex, unexpected_regex=r'^\d+\s*-?\s\w*\.ext with spaces? nah$')
        )

    def test_clean_filenames_recognizes_period_in_filename(self):
        self.create_files('{:02d} - {}.www.spam.me.mp3', 10)
        self._perform_and_check_cleaning(partial(self.assertNotIn, '.www.spam.me'))
        self._perform_and_check_cleaning_with_regex(r'^\d+\s*-?\s\w*\.mp3$')

    def test_clean_filenames_honors_min_length(self):
        self.create_files('{:02d}-blah-{}.mp3', 10)
        self._perform_and_check_cleaning(partial(self.assertIn, '-blah-'), min_length=7)

    def _longest_common_substr_is(self, strings, expected):
        self.assertEqual(FilenameCleaner.longest_common_substring(strings), expected)

    def _perform_and_check_cleaning_with_regex(self, regex: str):
        self._perform_and_check_cleaning(partial(self.assertRegex, expected_regex=regex))

    def _perform_and_check_cleaning(self, assertion: Callable[[str], None], **kwargs):
        self._perform_cleaning(**kwargs)
        for file in listdir(self.testdir.name):
            assertion(file)

    def _perform_cleaning(self, **kwargs):
        self.get_cleaner().clean_filenames(force=True, **kwargs)
