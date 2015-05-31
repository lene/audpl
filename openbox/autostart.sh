#!/bin/bash

gkrellm &
xfce4-panel &
nitrogen --restore &

sleep 5 && kdeinit5 &
