from os import mkdir
from os.path import join, isfile, isdir

from .temp_dir_test_case import TempDirTestCase

from copy_from_playlist import copy_newest_files

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestCopyNewestFiles(TempDirTestCase):

    def setUp(self):
        super().setUp()
        self.src_dir = join(self.testdir.name, 'src')
        mkdir(self.src_dir)
        self.create_file(join(self.src_dir, 'x'))
        mkdir(join(self.src_dir, 'sub_dir'))
        self.create_file(join(self.src_dir, 'sub_dir', 'x'))
        self.dest_dir = join(self.testdir.name, 'dest')
        mkdir(self.dest_dir)

    def test_files_are_copied(self):
        copy_newest_files(self.src_dir, 1, self.dest_dir)
        self.assertTrue(isfile(join(self.dest_dir, 'x')))
        self.assertTrue(isdir(join(self.dest_dir, 'sub_dir')))
        self.assertTrue(isfile(join(self.dest_dir, 'sub_dir', 'x')))
