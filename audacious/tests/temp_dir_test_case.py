from tempfile import TemporaryDirectory

import unittest

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
