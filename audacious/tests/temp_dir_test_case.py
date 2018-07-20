import os
import unittest
from tempfile import TemporaryDirectory

from util import find_dirs

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TempDirTestCase(unittest.TestCase):

    def setUp(self):
        self.testdir = TemporaryDirectory()

    def tearDown(self):
        try:
            self.testdir.cleanup()
        except FileNotFoundError:
            pass

    @staticmethod
    def create_file(name):
        open(name, 'a').close()

    @staticmethod
    def get_data_dir() -> str:
        candidates = find_dirs('.', lambda d: d.endswith('data/audacious_config'))
        if len(candidates) != 1:
            raise ValueError(
                f"Test audacious config dir not found in {os.getcwd()} - see {candidates}"
            )
        return candidates[0]
