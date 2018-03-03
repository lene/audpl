#!/bin/bash

which inotifywait > /dev/null || sudo apt install inotify-tools

inotifywait -qq -e close_write $HOME/.config/audacious/scrobbler.log && \
  audtool current-song && \
  audtool playlist-delete $(audtool playlist-position) && \
  sleep 2


