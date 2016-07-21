#!/bin/bash

setxkbmap -layout us

gkrellm &
xfce4-panel &
nitrogen --restore &

sleep 5 && kdeinit4 &

test -x /opt/toggldesktop/TogglDesktop.sh && /opt/toggldesktop/TogglDesktop.sh &
#which btsync && sleep 60 && btsync --storage ~/.btsync
#which slack && sleep 120 && slack &
