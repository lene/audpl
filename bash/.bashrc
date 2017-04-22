#!/bin/bash

#
# .bashrc
# a set of commands carried together over the course of over 10 years
#

# debugging off
set +xv

alias time="/usr/bin/time --format='%E wall, %Us user, %Ss sys 
%M kB max (%Xtext+%Ddata)
%P CPU'"
alias 	ll='ls -l'

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

################################################################################

test -f ./dir.sh && . ./dir.sh

################################################################################

export LESS="-R -M -m --shift 5"

#
# Python settings
#
export PYTHONSTARTUP=$HOME/workspace/configs/bash/.pythonrc
export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python2' # This needs to be placed before the virtualenvwrapper command
export WORKON_HOME=~/.virtualenvs

if [ -f $HOME/.local/bin/virtualenvwrapper.sh ]; then
	source $HOME/.local/bin/virtualenvwrapper.sh
elif [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
	source /usr/local/bin/virtualenvwrapper.sh
elif [ -f /usr/share/virtualenvwrapper/virtualenvwrapper.sh ];  then
	source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi

#
# Ruby settings
#
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting 

#
# CUDA settings
#
export CUDA_HOME="/usr/local/cuda"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64"
export PATH="${CUDA_HOME}/bin:${PATH}"

#
################################################################################

#
# source files delegated to .bash/ subdirectory
#
if [ -d ${HOME}/.bash ]; then
    for s in ${HOME}/.bash/*.sh ${HOME}/.bash/*.bash ; do
	test -r $s && . $s
    done
fi

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# utilize thefuck, if installed <https://github.com/nvbn/thefuck>
alias fuck='eval $(thefuck $(fc -ln -1)); history -r'

