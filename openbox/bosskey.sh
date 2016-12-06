#!/bin/bash

#SELF_DESTRUCT="poweroff"
SELF_DESTRUCT="xscreensaver-command -lock"
TEN_PERCENT_TIME=0.1
(
	sleep $TEN_PERCENT_TIME
	echo "10"; echo "# activate self-destruct" 
	sleep $TEN_PERCENT_TIME
	echo "20"; echo "# formatting root file system" 
	sleep $TEN_PERCENT_TIME
	sleep $TEN_PERCENT_TIME
	sleep $TEN_PERCENT_TIME	
	echo "50"; echo "alerting FBI"
	sleep 0.25; echo "75" ;
	sleep 0.25; echo "# Rebooting system" ;
	sleep 1; echo "100" ;
	sleep 1;
	$SELF_DESTRUCT
) | zenity --progress   --title="Update System Logs"   --text="Scanning mail logs..."   --percentage=0
