function fish_prompt --description 'Write out the prompt'
	# Just calculate this once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	set -l color_cwd
	set -l suffix

	switch $USER
	case root toor
		if set -q fish_color_cwd_root
			set color_cwd $fish_color_cwd_root
		else
			set color_cwd $fish_color_cwd
		end
		set suffix '#'
	case '*'
		set color_cwd $fish_color_cwd
		set suffix '>'
	end
	
	set logfile {$HOME}/history/$__fish_prompt_hostname
	echo '#' (date +'%Y%m%d %H:%M:%S') (pwd) '#' (history -1) >> $logfile

	if set -q VIRTUAL_ENV
    		echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
	end

	#
	# display user name, hostname and working directory in the xterm title bar
	# before each prompt display
	# TBD: does not work correctly with all xterm types on all systems
	# 
	if [ (echo $TERM | cut -c -5) = "xterm" ]
		echo -ne "\033]30;"(whoami)@{$__fish_prompt_hostname}: (pwd | rev | cut -d / -f -2 | rev)"\007"
	else                                            # no xterm, probably 
  		echo -n "$USER@$__fish_prompt_hostname"                      # display user, host and cwd
  		test (id -u) -eq 0; and export PS1="\u@\h:\w # "
	end	

	echo -n -s (set_color 888) "[ " (date +'%H:%M:%S') " ] " (set_color $color_cwd) (prompt_pwd) (set_color normal) "$suffix "
end

