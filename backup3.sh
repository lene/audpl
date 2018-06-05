#!/bin/bash

TARGET_DRIVE_ID=06ecd5c5-7380-476e-985b-211e32e5628b/
time sudo rsync -av --progress --exclude /media/ --exclude /proc/ --exclude /dev/ --exclude /sys/ --exclude /run/ --exclude .cache/ --exclude /tmp/ --exclude /var/tmp/ --exclude /mnt/ --exclude /home/ --exclude swapfile --delete-after / /media/lene/$TARGET_DRIVE_ID

time sudo rsync -av --progress --exclude .cache/ --exclude Azureus\ Downloads/ --exclude Downloads/Movies --exclude .local/share/Trash/ --exclude GoogleDrive --exclude \*.bak --delete-before /home/lene/ /media/lene/$TARGET_DRIVE_ID/home/lene/
