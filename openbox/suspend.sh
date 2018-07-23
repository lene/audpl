#!/bin/bash

SLEEP_MINUTES=$(zenity --scale --min-value=0 --max-value=180 --value=15)
if [ $? -eq 0 ]; then
	echo $SLEEP_MINUTES
fi
