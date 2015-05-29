#!/bin/bash

#
# .bashrc
# a set of commands carried together over the course of over 10 years
#

# debugging off
set +xv

# set PATH, if not set properly for root
echo $PATH | grep sbin > /dev/null || export PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/usr/X11R6/bin:$PATH

# enable colorful ls, if present
which dircolors > /dev/null 2>&1 && test -f $HOME/.dir_colors && eval `dircolors -b ~/.dir_colors`

#
# set prompt to write a log of the last executed command to $logfile
#
logfile=${HOME}/history/$(echo $HOSTNAME | cut -d '.' -f 1)
# whew! i'm kinda proud of this, don't let this get lost again!
export PROMPT_COMMAND="echo '#' \$(date +'%Y%m%d %H:%M:%S') \$(pwd) '#' \$(history 1 | cut -d ' ' -f 4-) >> $logfile"

#
# display user name, hostname and working directory in the xterm title bar
# before each prompt display
# TBD: does not work correctly with all xterm types on all systems
# 
if [ x$TERM == "xxterm" -o x$TERM == "xxterm-color" -o x$TERM == "xrxvt" ]; then

  # check for mrxvt and set the tab title if found
  if [ x$COLORTERM == "xrxvt-xpm" ]; then
    export PROMPT_COMMAND=${PROMPT_COMMAND}'; echo -ne "\033]61;`pwd`\007\033]0;`whoami`@`hostname`: `pwd | rev | cut -d / -f -2 | rev`\007"'
  else
    if `which xtermset > /dev/null 2>&1`; then
      export PROMPT_COMMAND=${PROMPT_COMMAND}'; xtermset -T "`whoami`@`hostname`: `pwd | rev | cut -d / -f -2 | rev`"'
    else
      export PROMPT_COMMAND=${PROMPT_COMMAND}'; echo -ne "\033]0;`whoami`@`hostname`: `pwd | rev | cut -d / -f -2 | rev`\007"'
    fi
  fi

  export PS1="[ \t ] "                          # display current time
  test $UID == 0 && export PS1="\t # "
else                                            # no xterm, probably 
  export PS1="\u@\h:\w > "                      # display user, host and cwd
  test $UID == 0 && export PS1="\u@\h:\w # "
fi
PS2="->"

export EDITOR=vi

export CUDA_HOME="/usr/local/cuda"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64"
export PATH="${CUDA_HOME}/bin:${PATH}"
################################################################################

#test -f ./TO-DO && cat ./TO-DO
test -f ./dir.sh && . ./dir.sh

if [ ! `which > /dev/null 2>&1 wterm` ]; then 
    which xterm > /dev/null 2>&1 && alias wterm="xterm"
    which rxvt > /dev/null 2>&1 && alias wterm="rxvt"
fi 

################################################################################

#
# conditional actions follow
# these conditions have to be set manually in some cases
# have a look at the source anyway
#
if [ `uname` == "Linux" ]; then
    export FLOWHOME=/home/i/.ReptileLabour/FlowHome
fi

if [ `uname` == "FreeBSD" ]; then
    export CDROM=/dev/acd1
    export LS_OPTIONS="-G"
fi

false &&  export HTTP_PROXY=sue:3128

export FTP_PROXY=$HTTP_PROXY

export CVS_RSH=ssh
# select whichever CVSROOT is appropriate
export CVSROOT=:ext:metaldog@cvs.sourceforge.net:/cvsroot/hyperspace-expl
export CVSROOT=:ext:metaldog@cvs.sourceforge.net:/cvsroot/go-3

export LESS="-R -M -m --shift 5"

test -d /usr/local/petlib/lib && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/petlib/lib

#
# conditional actions end
#

################################################################################

#
# source files delegated to .bash/ subdirectory
#
if [ -d ${HOME}/.bash ]; then
    for s in ${HOME}/.bash/*.sh; do
	test -r $s && . $s
    done
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# utilize thefuck, if installed <https://github.com/nvbn/thefuck>
alias fuck='eval $(thefuck $(fc -ln -1)); history -r'

