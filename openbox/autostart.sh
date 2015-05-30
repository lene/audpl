#!/bin/bash

gkrellm &
xfce4-panel &
sleep 5 && kdeinit5 &
