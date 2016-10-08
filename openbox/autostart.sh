#!/bin/bash

OPENBOX_DIR=~/workspace/configs/openbox

setxkbmap -layout us

if [ -x $OPENBOX_DIR/setlayout ]; then
    $OPENBOX_DIR/setlayout 0 3 3 0
else
    if [ - f $OPENBOX_DIR/setlayout.c ]; then
		gcc $OPENBOX_DIR/setlayout.c -o $OPENBOX_DIR/setlayout
		$OPENBOX_DIR/setlayout 0 3 3 0

    fi
fi
    
gkrellm &
xfce4-panel &
nitrogen --restore &
audacious &

sleep 5 && kdeinit4 &

test -x /opt/toggldesktop/TogglDesktop.sh && /opt/toggldesktop/TogglDesktop.sh &
#which btsync && sleep 60 && btsync --storage ~/.btsync
#which slack && sleep 120 && slack &
