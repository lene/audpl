################################################################################

#   
#   alias section
#

alias more=less
alias lo=logout
alias em='emacs -nw'

alias +r='chmod go+r'
#alias '-r'='chmod go-r'
alias +w='chmod go+w'
#alias '-w'='chmod go-w'
alias +x='chmod +x'
#alias '-x'='chmod -x'

# set options for some common commands
alias	zip='zip -9mTu'
alias	dir='ls -C'
alias 	ls='ls $LS_OPTIONS'
alias 	ll='ls -l'
alias 	Xnest="xinit -- /usr/X11/bin/Xnest $1 -fn *-*-*-*-*-*-0-0-75-75-* \
	     -fp '/usr/X11/lib/fonts/75dpi,/usr/X11/lib/fonts/misc'"
alias 	xterm='xterm -bg rgb:e8/e8/e8 +ls -j -sb -sl 512'

# i never used the following aliases, i will delete them in the next edit
#alias h=history
#alias del='rm -i'
#alias rsz='eval `resize`'
#alias mine='chown $USER'
#alias vt52="set term = vt52"
#alias vt100="set term = vt100"

#alias   doc='less /usr/doc/'
#alias   r='fc -s'

# remove obsolete program from path (i'll keep this for sentimental reasons)
alias ghostview=gv

# From: pardo@cs.washington.edu (David Keppel)
#alias   go='cd  $path_\!*'
#alias   mark='set path_\!* = $cwd'
#alias   marks='set | grep ^path_ | sed "s/^path_/     /"'
#alias   unmark='unset path_\!*'

################################################################################

#   
#   alias section
#

alias more=less
alias lo=logout
alias em='emacs -nw'

alias +r='chmod go+r'
#alias '-r'='chmod go-r'
alias +w='chmod go+w'
#alias '-w'='chmod go-w'
alias +x='chmod +x'
#alias '-x'='chmod -x'

# set options for some common commands
alias	zip='zip -9mTu'
alias	dir='ls -C'
alias 	ls='ls $LS_OPTIONS'
alias 	ll='ls -l'
alias 	Xnest="xinit -- /usr/X11/bin/Xnest $1 -fn *-*-*-*-*-*-0-0-75-75-* \
	     -fp '/usr/X11/lib/fonts/75dpi,/usr/X11/lib/fonts/misc'"
alias 	xterm='xterm -bg rgb:e8/e8/e8 +ls -j -sb -sl 512'

# i never used the following aliases, i will delete them in the next edit
#alias h=history
#alias del='rm -i'
#alias rsz='eval `resize`'
#alias mine='chown $USER'
#alias vt52="set term = vt52"
#alias vt100="set term = vt100"

#alias   doc='less /usr/doc/'
#alias   r='fc -s'

# remove obsolete program from path (i'll keep this for sentimental reasons)
alias ghostview=gv

# From: pardo@cs.washington.edu (David Keppel)
#alias   go='cd  $path_\!*'
#alias   mark='set path_\!* = $cwd'
#alias   marks='set | grep ^path_ | sed "s/^path_/     /"'
#alias   unmark='unset path_\!*'

alias wow='wine .wine/drive_c/Program\ Files/World\ of\ Warcraft/Wow.exe -opengl'
