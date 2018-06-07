#!/bin/bash

if [ $UID != 0 ]; then
	echo "execute me with sudo plz thankyouverymuch"
	exit
fi

TARGET_FOLDER=/media/backup

# sudo cryptsetup -y -v luksFormat --type luks2 /dev/sda1
# password: same as laptop
cryptsetup open /dev/sda1 backup 
# sudo mkfs.ext4 /dev/mapper/backup

mkdir -p $TARGET_FOLDER
mount /dev/mapper/backup $TARGET_FOLDER

time rsync -av --progress \
	 --exclude /media/ --exclude /proc/ --exclude /dev/ --exclude /sys/ \
	 --exclude /run/ --exclude .cache/ --exclude /tmp/ --exclude /var/tmp/ \
	 --exclude /mnt/ --exclude /home/ --exclude swapfile \
	 --delete-after /  $TARGET_FOLDER

time rsync -av --progress \
	 --exclude .cache/ --exclude Azureus\ Downloads/ --exclude Downloads/Movies \
	 --exclude .local/share/Trash/ --exclude GoogleDrive --exclude \*.bak \
	 --delete-before /home/lene/ $TARGET_FOLDER/home/lene/

umount /media/backup

cryptsetup close backup
