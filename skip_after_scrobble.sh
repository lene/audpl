#!/bin/bash
inotifywait -qq -e close_write $HOME/.config/audacious/scrobbler.log && \
  audtool current-song && \
  audtool playlist-delete $(audtool playlist-position)
