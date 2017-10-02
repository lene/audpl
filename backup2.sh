
time sudo  rsync -av --progress --exclude /home --exclude /media/ --exclude /proc/ --exclude /dev/ --exclude /sys/ --exclude /run/ --exclude /tmp/ --exclude /var/tmp/ --exclude /mnt/ --delete-before / /media/lene/06ecd5c5-7380-476e-985b-211e32e5628b/
sudo mkdir -p /media/lene/06ecd5c5-7380-476e-985b-211e32e5628b/home/lene/
sudo chown lene.lene /media/lene/06ecd5c5-7380-476e-985b-211e32e5628b/home/lene/
time rsync -av --progress --exclude .cache/ --exclude Azureus\ Downloads/ --exclude Downloads/Movies --exclude .local/share/Trash/ --exclude \*.bak --delete-before /home/lene/ /media/lene/06ecd5c5-7380-476e-985b-211e32e5628b/home/lene/