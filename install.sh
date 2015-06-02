#!/bin/bash

ln -s $HOME/workspace/config/audacious $HOME/.config
ln -s $HOME/workspace/config/openbox $HOME/.config
#ln -s $HOME/workspace/config/bash/.??* $HOME
for i in bash/.??*; do file=$(basename $i);  rm -r $HOME/$file && ln -s $(pwd)/$i $HOME/$file; done
