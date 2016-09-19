from urllib import unquote
from os.path import isfile

playlist = '1035'
with open('playlists/'+playlist+'.audpl') as playlist_file:
    lines = playlist_file.readlines()

lines = [
    unquote(line[len('uri=file://'):]).strip()
    for line in lines if line.startswith('uri=file://')
    ]
print([line for line in lines if isfile(line)])
