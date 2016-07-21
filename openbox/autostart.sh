#!/bin/bash

setxkbmap -layout us

if [ -x ~/workspace/configs/openbox/setlayout ]; then
    ~/workspace/configs/openbox/setlayout 0 3 3 0
else
    if [ - f ~/workspace/configs/openbox/setlayout.c ]; then
	gcc ~/workspace/configs/openbox/setlayout.c -o ~/workspace/configs/openbox/setlayout
	~/workspace/configs/openbox/setlayout 0 3 3 0
    fi
fi
    
gkrellm &
xfce4-panel &
nitrogen --restore &

sleep 5 && kdeinit4 &

test -x /opt/toggldesktop/TogglDesktop.sh && /opt/toggldesktop/TogglDesktop.sh &
#which btsync && sleep 60 && btsync --storage ~/.btsync
#which slack && sleep 120 && slack &
