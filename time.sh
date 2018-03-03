#!/bin/bash

ORIGINAL_DIR=$(pwd)
SCRIPT=$(realpath $0)
BASEDIR=${1:-$ORIGINAL_DIR}
cd "$BASEDIR"
for DIR in * ; do
	if [ -d "$DIR" ]; then

		cd "$DIR"
		TOTAL=0
		
		for i in *.[mM][pP]3; do
			if [ -f "$i" ]; then
				SECONDS=$(mp3info -p "%S" -- "$i")
				TOTAL=$[$TOTAL+$SECONDS]
			fi
		done

		for i in *.[fF][lL][aA][cC]; do
			if [ -f "$i" ]; then
				SECONDS=$(metaflac --show-total-samples --show-sample-rate "$i" | \
								 tr '\n' ' ' | \
								 awk '{print $1/$2}' - | \
								 cut -d . -f 1)
				TOTAL=$[$TOTAL+$SECONDS]
			fi
		done

		for i in *.[mM]4[aA] *.[wW][mM][aA]; do
			if [ -f "$i" ]; then
				MILLISECONDS=$(mediainfo --Inform="Audio;%Duration%" "$i")
				SECONDS=$[$MILLISECONDS/1000]
				TOTAL=$[$TOTAL+$SECONDS]
			fi
		done

		printf "%4d:%02d %s\n" $[$TOTAL/60] $[$TOTAL%60] "$DIR"

		test "$DIR" == "." || "$SCRIPT" .

		cd .. #"$BASEDIR"
	fi
done

cd "$ORIGINAL_DIR"
