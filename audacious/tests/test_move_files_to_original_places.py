from os.path import join, exists
from os import listdir, remove

from .temp_dir_test_case import TempDirTestCase

from copy_from_playlist import AudaciousTools, move_files_to_original_places

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestMoveFilesToOriginalPlaces(TempDirTestCase):

    TARGETDIR = '/tmp'  # as defined in data/audacious_config/playlists/0002.audpl

    def setUp(self):
        super().setUp()
        self.audacious = AudaciousTools('data/audacious_config')

        self.file_names = ('01 - Test A.mp3', 'Test B.mp3')
        for file in self.file_names:
            self.create_file(join(self.testdir.name, file))

        for file in self.file_names:
            self.assertIn(file, listdir(self.testdir.name))

    def tearDown(self):
        super().tearDown()
        for file in self.file_names:
            try:
                remove(join(self.TARGETDIR, file))
            except FileNotFoundError:
                pass

    def test_move_files_to_original_places_creates_target_files(self):
        move_files_to_original_places('0002', music_dir=self.testdir.name, audacious=self.audacious)
        for file in self.file_names:
            self.assertIn(file, listdir(self.TARGETDIR))

    def test_move_files_to_original_places_deletes_source_dir(self):
        print(self.audacious.playlist_directory)
        raise ValueError(self.audacious.playlist_directory)
        move_files_to_original_places('0002', music_dir=self.testdir.name, audacious=self.audacious)
        self.assertFalse(exists(self.testdir.name))

