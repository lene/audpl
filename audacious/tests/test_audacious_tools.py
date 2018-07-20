from os import listdir

from .temp_dir_test_case import TempDirTestCase

from copy_from_playlist import AudaciousTools, copy_playlist

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestAudaciousTools(TempDirTestCase):

    def setUp(self):
        super().setUp()
        self.audacious = AudaciousTools(self.get_data_dir())

    def test_playlist_order(self):
        self.assertEqual(2, len(self.audacious.get_playlist_order()))
        self.assertIn('0001', self.audacious.get_playlist_order())

    def test_get_currently_playing_playlist_id(self):
        # currently playing playlist depends on external audacious state, so this is best we can do
        self.assertIn(self.audacious.get_currently_playing_playlist_id(), ('0001', '0002'))

    def test_files_in_playlist(self):
        files = self.audacious.files_in_playlist('0001')
        self.assertEqual(3, len(files))
        self.assertIn('data/audacious_config/01 - Test A.mp3', files)
        self.assertIn('data/audacious_config/Test B.mp3', files)
        self.assertIn('NONEXISTENT.mp3', files)

    def test_get_files_to_copy(self):
        files = self.audacious.get_files_to_copy(0, '0001')
        self.assertEqual(3, len(files))
        self.assertIn('data/audacious_config/01 - Test A.mp3', files)
        self.assertIn('data/audacious_config/Test B.mp3', files)
        self.assertIn('NONEXISTENT.mp3', files)
        files = self.audacious.get_files_to_copy(1, '0001')
        self.assertEqual(1, len(files))
        self.assertIn('data/audacious_config/01 - Test A.mp3', files)

    def test_copy_playlist(self):
        copy_playlist('0001', 2, self.testdir.name, audacious=self.audacious)
        copied_files = listdir(self.testdir.name)
        self.assertEqual(2, len(copied_files))
        self.assertIn('01 - Test A.mp3', copied_files)
        self.assertIn('Test B.mp3', copied_files)

    def test_copy_playlist_with_renumber(self):
        copy_playlist('0001', 2, self.testdir.name, renumber=True, audacious=self.audacious)
        copied_files = listdir(self.testdir.name)
        self.assertEqual(2, len(copied_files))
        self.assertIn('01 - Test A.mp3', copied_files)
        self.assertIn('02 - Test B.mp3', copied_files)
        self.assertNotIn('Test B.mp3', copied_files)

    def test_copy_playlist_honors_length_limit(self):
        copy_playlist('0001', 1, self.testdir.name, audacious=self.audacious)
        copied_files = listdir(self.testdir.name)
        self.assertEqual(1, len(copied_files))
        self.assertIn('01 - Test A.mp3', copied_files)
        self.assertNotIn('Test B.mp3', copied_files)

    def test_copy_playlist_fails_on_nonexistent_file(self):
        with self.assertRaises(FileNotFoundError):
            copy_playlist('0001', 0, self.testdir.name, audacious=self.audacious)

