#!/bin/bash

mkdir -p $HOME/.config

test -L $HOME/.config/audacious || ln -s $HOME/workspace/configs/audacious $HOME/.config
test -L $HOME/.config/openbox || ln -s $HOME/workspace/configs/openbox   $HOME/.config

for i in bash/.??*; do
    file=$(basename $i)
    rm -rf $HOME/$file && ln -s $(pwd)/$i $HOME/$file
done

test -L $HOME/.config/fish || ln -s $HOME/workspace/configs/fish		 $HOME/.config

test -L $HOME/.config/kglobalshortcutsrc || ln -s $HOME/workspace/configs/kglobalshortcutsrc $HOME/.config
test -L $HOME/.config/kdeglobals         || ln -s $HOME/workspace/configs/kdeglobals         $HOME/.config
test -L $HOME/.config/kwinrc             || ln -s $HOME/workspace/configs/kwinrc             $HOME/.config
test -L $HOME/.config/kwinrulesrc        || ln -s $HOME/workspace/configs/kwinrulesrc        $HOME/.config

test -L $HOME/.mrxvtrc || ln -s $HOME/workspace/configs/.mrxvtrc $HOME
test -L $HOME/.emacs   || ln -s $HOME/workspace/configs/emacs/.emacs   $HOME
test -L $HOME/.xemacs  || ln -s $HOME/workspace/configs/emacs/.xemacs  $HOME

test -L $HOME/.gtkrc-2.0 || ln -s $HOME/workspace/configs/.gtkrc-2.0 $HOME
exit
# install some software I'll definitely need
sudo apt install mrxvt gkrelltop audacious zenity openbox emacs konsole xfce4 libx11-dev inotify-tools network-manager-gnome tor socat rox-filer lxtask menu gcc make

# build setlayout program for openbox pager to display desktops in a grid rather than a line
if [ -f openbox/setlayout.c ]; then
    cd openbox && \
	gcc setlayout.c -o setlayout -lX11 && \
	./setlayout 0 3 3 0 && \
	cd ..
fi

# Set up periodic cronjob to commit and push changes in config directory to git
crontab -l | grep -q workspace/configs || (
	crontab -l | { cat; echo ' 40 *    *   *   *   cd $HOME/workspace/configs; git pull && git add . && git commit -m "$(hostname) $(date)" && git push origin master' } | crontab -
)


# (try to) install xv (this is becoming more and more complicated :-\)
which xv || (
	cd /tmp
	# libpng12
	sudo apt install libpng12-dev || (
		test -f zlib-1.2.11.tar.gz || wget https://zlib.net/zlib-1.2.11.tar.gz
		test -f libpng-1.2.54.tar.bz2 || wget https://sourceforge.net/projects/libpng/files/libpng12/older-releases/1.2.54/libpng-1.2.54.tar.bz2
		tar xzf zlib-1.2.11.tar.gz
		cd zlib-1.2.11
		./configure --prefix=/usr/local
		make -j4
		sudo make install
		cd /tmp
		
		tar xjf libpng-1.2.54.tar.bz2
		cd libpng-1.2.54
		./configure --prefix=/usr/local
		make -j4
		sudo make install
	)
    sudo apt install libxt-dev libc6-dev libjpeg62 libjpeg62-dev libtiff5-dev  && (
		rm -r xv-3.10a 
		test -f xv-3.10a.tar.gz || wget ftp://ftp.trilon.com/pub/xv/xv-3.10a.tar.gz
		test -f xv-3.10a-jumbo20050501-1.diff.gz || wget http://www.ulich.org/hints/resources/xv-3.10a-jumbo20050501-1.diff.gz
		test -f xv-3.10a-jumbo-patches-20050501.tar.gz || wget http://www.ulich.org/hints/resources/xv-3.10a-jumbo-patches-20050501.tar.gz
		tar xvzf xv-3.10a.tar.gz
		tar xvzf xv-3.10a-jumbo-patches-20050501.tar.gz
		gzip -d xv-3.10a-jumbo20050501-1.diff.gz
		cd xv-3.10a
		patch -p1 < ../xv-3.10a-jumbo-fix-patch-20050410.txt
		patch -p1 < ../xv-3.10a-jumbo-enh-patch-20050501.txt
		patch -p1 < ../xv-3.10a-jumbo20050501-1.diff
		# set JPEG quality default to 95%
		sed -i s/75/95/g xvjpeg.c
		make -j4
		sudo mv -i xv /usr/local/bin/
		cd -
	)
)

# try installing scrivener
which scrivener || (
	cd /tmp
	test -f scrivener-1.9.0.1-amd64.deb || wget http://www.literatureandlatte.com/scrivenerforlinux/scrivener-1.9.0.1-amd64.deb
	test -f libgstreamer-plugins-base0.10-0_0.10.36-1_amd64.deb || wget http://fr.archive.ubuntu.com/ubuntu/pool/main/g/gst-plugins-base0.10/libgstreamer-plugins-base0.10-0_0.10.36-1_amd64.deb
	test -f libgstreamer0.10-0_0.10.36-1.5ubuntu1_amd64.deb || wget http://fr.archive.ubuntu.com/ubuntu/pool/universe/g/gstreamer0.10/libgstreamer0.10-0_0.10.36-1.5ubuntu1_amd64.deb
	sudo dpkg -i libgstreamer*.deb scrivener*.deb
)

# google-drive-ocamlfuse
which google-drive-ocamlfuse || (
	sudo add-apt-repository ppa:alessandro-strada/ppa
	sudo apt-get update
	sudo apt-get install google-drive-ocamlfuse
)
