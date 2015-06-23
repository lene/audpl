#!/bin/bash

gkrellm &
xfce4-panel &
nitrogen --restore &

sleep 5 && kdeinit4 &
sleep 5 && vuze &
