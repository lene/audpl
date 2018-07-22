#!/usr/bin/fish
# pops up an image at the moise pointer position
# needs xdotool anf pqiv installed, also assumes the image is present

set IMG $HOME/workspace/configs/openbox/zoidberg.png
set x 1000
set y 500
xdotool mousemove $x $y

#set x (xdotool getmouselocation | cut -d ':' -f 2 | cut -d ' ' -f 1)
#set y (xdotool getmouselocation | cut -d ':' -f 3 | cut -d ' ' -f 1)
# these values are specific to the image, to center the mouse pointer on the image
set x (math $x-25)
set y (math $y-35)

pqiv -c -i -P $x,$y $IMG &
sleep 3
killall pqiv
