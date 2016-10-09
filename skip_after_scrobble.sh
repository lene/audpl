inotifywait -qq -e close_write audacious/scrobbler.log && audtool current-song && audtool playlist-delete $(audtool playlist-position)
