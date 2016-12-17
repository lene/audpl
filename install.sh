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

sudo apt install mrxvt gkrellm audacious zenity openbox emacs konsole xfce4 libx11-dev

if [ -f openbox/setlayout.c ]; then
    cd openbox && \
	gcc setlayout.c -o setlayout -lX11 && \
	./setlayout 0 3 3 0 && \
	cd ..
fi


