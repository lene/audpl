from itertools import chain
from os import mkdir
from os.path import join

from .temp_dir_test_case import TempDirTestCase

from copy_from_playlist import find_first_dir, existing_files, strip_leading_numbers, renumber_file

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestFreeFunctions(TempDirTestCase):

    def setUp(self):
        super().setUp()
        self.file_names = ('A', 'B', 'D')
        self.dir_names = ('C', 'E')
        for file in self.file_names:
            self.create_file(join(self.testdir.name, file))
        for dir in self.dir_names:
            mkdir(join(self.testdir.name, dir))
            for file in self.file_names:
                self.create_file(join(self.testdir.name, dir, file))

    def test_find_first_dir_finds_dirs(self):
        for dir in self.dir_names:
            self.assertIsNotNone(find_first_dir(dir, self.testdir.name))
            self.assertIn(dir, find_first_dir(dir, self.testdir.name))

    def test_find_first_dir_finds_no_files(self):
        for file in self.file_names:
            self.assertIsNone(find_first_dir(file, self.testdir.name))

    def test_existing_files(self):
        files_to_test = [join(self.testdir.name, f) for f in self.file_names]
        self.assertEqual(files_to_test, existing_files(files_to_test))

    def test_existing_files_no_dirs(self):
        files_to_test = [join(self.testdir.name, f) for f in chain(self.file_names, self.dir_names)]
        found_files = existing_files(files_to_test)
        self.assertNotEqual(files_to_test, found_files)
        self.assertTrue(set(found_files).issubset(files_to_test))
        self.assertGreater(len(found_files), 0)

    def test_strip_leading_numbers(self):
        for possible_name in [
            '1. blah', '1.blah', '1 - blah', '1-blah', '01. blah', '01.blah', '01 - blah',
            '1 blah', '01-blah', '123 - blah', '12345678 - blah'
        ]:
            self.assertEqual('blah', strip_leading_numbers(possible_name))

    def test_strip_leading_numbers_nonsense(self):
        for impossible_name in ['1x. blah', 'x1.blah', '² - blah', '1/blah', '01--blah']:
            self.assertNotEqual('blah', strip_leading_numbers(impossible_name))

    def test_renumber_file(self):
        self.assertEqual('10 - blah', renumber_file('01 - blah', 10, 10))
        self.assertEqual('10 - blah', renumber_file('blah', 10, 10))
        self.assertEqual('010 - blah', renumber_file('01 - blah', 10, 123))
        self.assertEqual('10 - blah', renumber_file('01 blah', 10, 10))
