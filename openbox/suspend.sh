#!/bin/bash

SECS_PER_MINUTE=60

SLEEP_MINUTES=$(
	zenity --scale \
		   --width=600 \
		   --title="Suspend?" \
		   --text="<span font='24'>Minutes until suspend:            </span>" \
		   --min-value=0 --max-value=120 --value=15 --step=5
)
if [ $? -eq 0 ]; then
	echo $SLEEP_MINUTES
	for i in $(seq $[$SLEEP_MINUTES*$SECS_PER_MINUTE]); do
		echo $[$i*100/$SLEEP_MINUTES/$SECS_PER_MINUTE]
		sleep 1
	done | zenity --progress \
				  --width=600 \
				  --title="Suspending soon(ish)" \
				  --text="<span font='24'><b>$SLEEP_MINUTES</b> minutes until suspend</span>" \
				  --auto-close 

	if [ $? -eq 0 ]; then
		systemctl suspend
	fi
fi
