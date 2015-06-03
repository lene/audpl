#!/bin/bash

sudo rsync -av --progress --exclude /media/ --exclude /proc/ --exclude /dev/ --exclude /sys/ --exclude /run/ --exclude .cache/ --exclude /tmp/ --exclude /mnt/ / /media/lene/d599cfd0-8aff-433a-a965-d2d1188cfc8e/
