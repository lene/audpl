#!/bin/bash

ln -s $HOME/workspace/configs/audacious $HOME/.config
ln -s $HOME/workspace/configs/openbox   $HOME/.config

for i in bash/.??*; do
    file=$(basename $i)
    rm -rf $HOME/$file && ln -s $(pwd)/$i $HOME/$file
done

ln -s $HOME/workspace/configs/kglobalshortcutsrc $HOME/.config
ln -s $HOME/workspace/configs/kdeglobals         $HOME/.config
ln -s $HOME/workspace/configs/kwinrc             $HOME/.config
ln -s $HOME/workspace/configs/kwinrulesrc        $HOME/.config

ln -s $HOME/workspace/configs/.mrxvtrc $HOME
ln -s $HOME/workspace/configs/.emacs   $HOME
ln -s $HOME/workspace/configs/.xemacs  $HOME

sudo apt install mrxvt gkrelltop audacious zenity openbox emacs konsole xfce4 libx11-dev inotify-tools

if [ -f openbox/setlayout.c ]; then
    cd openbox && \
	gcc setlayout.c -o setlayout -lX11 && \
	./setlayout 0 3 3 0 && \
	cd ..
fi


# (try to) install xv
which xv || (
    cd /tmp
    wget ftp://ftp.trilon.com/pub/xv/xv-3.10a.tar.gz
    wget http://www.ulich.org/hints/resources/xv-3.10a-jumbo20050501-1.diff.gz
    wget http://www.ulich.org/hints/resources/xv-3.10a-jumbo-patches-20050501.tar.gz
    tar xvzf xv-3.10a.tar.gz
    tar xvzf xv-3.10a-jumbo-patches-20050501.tar.gz
    gzip -d xv-3.10a-jumbo20050501-1.diff.gz
    cd xv-3.10a
    patch -p1 < ../xv-3.10a-jumbo-fix-patch-20050410.txt
    patch -p1 < ../xv-3.10a-jumbo-enh-patch-20050501.txt
    patch -p1 < ../xv-3.10a-jumbo20050501-1.diff
    # set JPEG quality default to 95%
    sed -i s/75/95/g xvjpeg.c
    sudo apt install libxt-dev libc6-dev xlibs-dev libjpeg62-dev libtiff5-dev libpng12-dev
    make -j4
    sudo mv -i xv /usr/local/bin/
    cd -
)