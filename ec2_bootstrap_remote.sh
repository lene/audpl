#!/bin/bash

set -xv

# swap size in MB
SWAPSIZE={1:-4096}

cd $HOME

mkdir -p history

sudo apt -y update 
sudo rm /boot/grub/menu.lst
sudo update-grub-legacy-ec2 -y
sudo apt -y upgrade 

sudo dd if=/dev/zero of=/var/swap bs=1M count=${SWAPSIZE}
sudo mkswap /var/swap
sudo chmod 0600 /var/swap
sudo swapon /var/swap

git clone https://github.com/lene/style-scout.git

sudo apt -y install nfs-common
sudo mkdir /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-804b8649.efs.eu-west-1.amazonaws.com:/ /mnt/efs
echo 'fs-804b8649.efs.eu-west-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0' | sudo tee >> /etc/fstab
ln -s /mnt/efs/data/ style-scout

sudo apt -y install python-pip python3-tk fish
sudo pip install virtualenvwrapper
sudo pip install virtualfish
. $HOME/.local/bin/virtualenvwrapper.sh

lspci | grep -i nvidia && (
	cd
	sed -i s/tensorflow/tensorflow_gpu/ style-scout/requirements.txt
	sudo dpkg -i /mnt/efs/CUDA/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
	sudo apt-get update
	sudo apt -y install cuda
	sudo dpkg -i /mnt/efs/CUDA/libcudnn5_5.1.10-1+cuda8.0_amd64.deb
	sudo apt -y install libcupti-dev
)

echo 'workon style_scout' > style-scout/dir.sh
cd style-scout/
mkvirtualenv -p python3.5 style_scout && \
	pip install -r requirements.txt
