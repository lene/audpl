from urllib import unquote
from os.path import isfile
from argparse import ArgumentParser

playlist = '1035'


def copy_playlist(playlist, number, target):
    with open('playlists/'+playlist+'.audpl') as playlist_file:
        lines = playlist_file.readlines()

    lines = [
        unquote(line[len('uri=file://'):]).strip()
        for line in lines if line.startswith('uri=file://')
        ]
    print([line for line in lines if isfile(line)])


def main(args):
    parser = ArgumentParser(description="copy first N files of a playlist to target folder")
    parser.add_argument(
        '-p', '--playlist', default='', type=str,
        help='Name of the playlist to copy'
    )
    parser.add_argument(
        '-n', '--number', default=0, type=int,
        help='First N files to copy from the playlist'
    )
    parser.add_argument(
        '-t', '--target', default='', type=str,
        help='Name of the target directory'
    )
    opts = parser.parse_args(args)
    copy_playlist(opts.playlist, opts.number, opts.target)

if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
