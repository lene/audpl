################################################################################

#   
#   alias section
#

# this is pretty neat and I'm ashamed I only learned this in 2017!
alias time="/usr/bin/time --format='%E wall, %Us user, %Ss sys 
%M kB max (%Xtext+%Ddata)
%P CPU'"

# haven't played WoW in years, but hey
alias wow='wine .wine/drive_c/Program\ Files/World\ of\ Warcraft/Wow.exe -opengl'

# all this is legit stuff from way back in the 90s and I did not even remember I had it

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
# ^ commands that were common in the 90s, that is
alias	zip='zip -9mTu'
# who stil remembers the dir command? 
alias	dir='ls -C'
alias 	ls='ls $LS_OPTIONS'
# yeah, this one I actually use all the time. only legit reason this file exists tbh.
alias 	ll='ls -l'
# lol, Xnest!
alias 	Xnest="xinit -- /usr/X11/bin/Xnest $1 -fn *-*-*-*-*-*-0-0-75-75-* \
	     -fp '/usr/X11/lib/fonts/75dpi,/usr/X11/lib/fonts/misc'"
alias 	xterm='xterm -bg rgb:e8/e8/e8 +ls -j -sb -sl 512'

# i'll keep this comment for sentimental reasons
## remove obsolete program from path (i'll keep this for sentimental reasons)
alias ghostview=gv

