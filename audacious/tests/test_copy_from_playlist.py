from itertools import chain
from tempfile import TemporaryDirectory
from os.path import join, exists
from os import mkdir, listdir, remove
from hashlib import md5

import unittest

from copy_from_playlist import find_first_dir, existing_files, strip_leading_numbers, renumber_file, \
    AudaciousTools, copy_playlist, move_files_to_original_places, clean_filenames

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'


class TestFreeFunctions(unittest.TestCase):

    def setUp(self):
        self.testdir = TemporaryDirectory()
        self.file_names = ('A', 'B', 'D')
        self.dir_names = ('C', 'E')
        for file in self.file_names:
            with open(join(self.testdir.name, file), 'w'):
                pass
        for dir in self.dir_names:
            mkdir(join(self.testdir.name, dir))
            for file in self.file_names:
                with open(join(self.testdir.name, dir, file), 'w'):
                    pass

    def tearDown(self):
        self.testdir.cleanup()

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

    def test_strip_leading_numbers_nonsens(self):
        for impossible_name in ['1x. blah', 'x1.blah', '² - blah', '1/blah', '01--blah']:
            self.assertNotEqual('blah', strip_leading_numbers(impossible_name))

    def test_renumber_file(self):
        self.assertEqual('10 - blah', renumber_file('01 - blah', 10, 10))
        self.assertEqual('10 - blah', renumber_file('blah', 10, 10))
        self.assertEqual('010 - blah', renumber_file('01 - blah', 10, 123))


class TestAudaciousTools(unittest.TestCase):

    def setUp(self):
        self.audacious = AudaciousTools('data/audacious_config')

    def test_playlist_order(self):
        self.assertEqual(2, len(self.audacious.get_playlist_order()))
        self.assertIn('0001', self.audacious.get_playlist_order())

    def test_get_currently_playing_playlist_id(self):
        self.assertEqual('0001', self.audacious.get_currently_playing_playlist_id())

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
        with TemporaryDirectory() as temp_dir:
            copy_playlist('0001', 2, temp_dir, audacious=self.audacious)
            copied_files = listdir(temp_dir)
            self.assertEqual(2, len(copied_files))
            self.assertIn('01 - Test A.mp3', copied_files)
            self.assertIn('Test B.mp3', copied_files)

    def test_copy_playlist_with_renumber(self):
        with TemporaryDirectory() as temp_dir:
            copy_playlist('0001', 2, temp_dir, renumber=True, audacious=self.audacious)
            copied_files = listdir(temp_dir)
            self.assertEqual(2, len(copied_files))
            self.assertIn('01 - Test A.mp3', copied_files)
            self.assertIn('02 - Test B.mp3', copied_files)

    def test_copy_playlist_honors_length_limit(self):
        with TemporaryDirectory() as temp_dir:
            copy_playlist('0001', 1, temp_dir, audacious=self.audacious)
            copied_files = listdir(temp_dir)
            self.assertEqual(1, len(copied_files))
            self.assertIn('01 - Test A.mp3', copied_files)
            self.assertNotIn('Test B.mp3', copied_files)

    def test_copy_playlist_fails_on_nonexisting_file(self):
        with self.assertRaises(FileNotFoundError):
            with TemporaryDirectory() as temp_dir:
                copy_playlist('0001', 0, temp_dir, audacious=self.audacious)


class TestMoveFilesToOriginalPlaces(unittest.TestCase):

    TARGETDIR = '/tmp'  # as defined in data/audacious_config/playlists/0002.audpl

    def setUp(self):
        self.audacious = AudaciousTools('data/audacious_config')

        self.testdir = TemporaryDirectory()
        self.file_names = ('01 - Test A.mp3', 'Test B.mp3')
        for file in self.file_names:
            with open(join(self.testdir.name, file), 'w'):
                pass

        for file in self.file_names:
            self.assertIn(file, listdir(self.testdir.name))

    def tearDown(self):
        try:
            self.testdir.cleanup()
        except FileNotFoundError:
            pass

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
        move_files_to_original_places('0002', music_dir=self.testdir.name, audacious=self.audacious)
        self.assertFalse(exists(self.testdir.name))


class TestCleanFilenames(unittest.TestCase):

    def setUp(self):
        self.testdir = TemporaryDirectory()

    def tearDown(self):
        self.testdir.cleanup()

    def test_clean_filenames_succeeds(self):
        clean_filenames(self.testdir.name)

    def test_clean_filenames_removes_longest_common_part(self):
        self._create_files('{} - blah blah blah - {}.mp3', 10)
        print(listdir(self.testdir.name))
        clean_filenames(self.testdir.name)

    def test_clean_filenames_leaves_numbering_intact(self):
        pass

    def test_clean_filenames_leaves_extension_intact(self):
        pass

    def test_clean_filenames_honors_min_length(self):
        pass

    def _create_files(self, template: str, number: int):
        self.files = []
        for i in range(1, number+1):
            filename = template.format(i, md5(str(i).encode('utf-8')).hexdigest())
            path = join(self.testdir.name, filename)
            with open(path, 'wb'):
                pass
            self.files.append(path)
