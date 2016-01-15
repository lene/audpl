#!/bin/bash

test -x /opt/toggldesktop/TogglDesktop.sh && /opt/toggldesktop/TogglDesktop.sh &

which btsync && btsync --storage ~/.btsync

gkrellm &
xfce4-panel &
nitrogen --restore &

sleep 5 && kdeinit4 &
#sleep 5 && vuze &
