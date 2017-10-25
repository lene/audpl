#!/bin/bash

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
test -L $HOME/.emacs   || ln -s $HOME/workspace/configs/.emacs   $HOME
test -L $HOME/.xemacs  || ln -s $HOME/workspace/configs/.xemacs  $HOME

sudo apt install mrxvt gkrelltop audacious zenity openbox emacs konsole xfce4 libx11-dev inotify-tools network-manager-gnome tor rox-filer lxtask 

if [ -f openbox/setlayout.c ]; then
    cd openbox && \
	gcc setlayout.c -o setlayout -lX11 && \
	./setlayout 0 3 3 0 && \
	cd ..
fi


# (try to) install xv
which xv || (
	cd /tmp
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
    sudo apt install libxt-dev libc6-dev libjpeg62-dev libtiff5-dev  && (
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
