from tempfile import TemporaryDirectory
from os.path import join
from os import mkdir
import unittest

from copy_from_playlist import find_first_dir

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestCopyFromPlaylist(unittest.TestCase):

    def setUp(self):
        self.testdir = TemporaryDirectory()
        self.files = ('A', 'B', 'D')
        self.directories = ('C', 'E')
        for file in self.files:
            with open(join(self.testdir.name, file), 'w'):
                pass
        for dir in self.directories:
            mkdir(join(self.testdir.name, dir))
            for file in self.files:
                with open(join(self.testdir.name, dir, file), 'w'):
                    pass

    def tearDown(self):
        self.testdir.cleanup()

    def test_find_first_dir_finds_dirs(self):
        found = find_first_dir('C ', self.testdir.name)
        print(found)
        self.assertIn('C', found)

    def test_find_first_dir_finds_no_files(self):
        self.assertIsNone(find_first_dir('A', self.testdir.name))
