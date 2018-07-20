import os
from .temp_dir_test_case import TempDirTestCase

from copy_from_playlist import AudaciousTools, move_files_to_original_places

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestMoveFilesToOriginalPlaces(TempDirTestCase):

    TARGETDIR = '/tmp'  # as defined in data/audacious_config/playlists/0002.audpl

    def setUp(self):
        super().setUp()

        self.audacious = AudaciousTools(self.get_data_dir())

        self.file_names = ('01 - Test A.mp3', 'Test B.mp3')
        for file in self.file_names:
            self.create_file(os.path.join(self.testdir.name, file))

        for file in self.file_names:
            self.assertIn(file, os.listdir(self.testdir.name))

    def tearDown(self):
        super().tearDown()
        for file in self.file_names:
            try:
                os.remove(os.path.join(self.TARGETDIR, file))
            except FileNotFoundError:
                pass

    def test_move_files_to_original_places_creates_target_files(self):
        move_files_to_original_places('0002', music_dir=self.testdir.name, audacious=self.audacious)
        for file in self.file_names:
            self.assertIn(file, os.listdir(self.TARGETDIR))

    def test_move_files_to_original_places_deletes_source_dir(self):
        move_files_to_original_places('0002', music_dir=self.testdir.name, audacious=self.audacious)
        self.assertFalse(os.path.exists(self.testdir.name))
