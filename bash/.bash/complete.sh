################################################################################

#   
#   programmable completion section
#

complete -d -f -c nice

#
# i included the following file here verbatim to be sure i always have the 
# rather nifty SuSE autocompletion configuration, and not depend on system
# configuration
#

# /etc/profile.d/complete.bash for SuSE Linux
#
#
# This feature has its own file because some other shells
# do not like the way how the bash assigns arrays
#
# REQUIRES bash 2.0 and higher
#
# To add completions for new commands, first add the required extension[s] to the
# CASE expression in function _exp_ () (starting arounf line 70), then add the
# command to the "complete" command at about line 184.
#


shopt -s extglob

_def=; _dir=; _file=; _nosp=
if complete -o default _nullcommand &> /dev/null ; then
    _def="-o default"
    _dir="-o dirnames"
    _file="-o filenames"
fi
if complete -o nospace _nullcommand &> /dev/null ; then
    _nosp="-o nospace"
fi
complete -r _nullcommand &> /dev/null

# Expanding shell function for directories
function _cd_ ()
{
    local c=${COMP_WORDS[COMP_CWORD]}
    local o="$IFS" x
    IFS='
'
    case "$c" in
    \~*) COMPREPLY=($(compgen -u -- "$c")) ;;
    *)	 COMPREPLY=($(compgen -d -- "$c"))
	 case "$1" in
	 mkdir)
	    if test "$c" != "." -a "$c" != ".." ; then
		for x in $(compgen -f -S .d -- "${c%.}") ; do
		    if test -d "${x}" -o -d "${x%.d}" ; then
			continue
		    fi
		    COMPREPLY=(${COMPREPLY[@]} ${x})
		done
	    fi
	 esac
    esac
    test -z "$o" && unset IFS || IFS="$o"
}

complete -d -F _cd_ ${_dir}		cd rmdir pushd chroot chrootx
complete -d -F _cd_ ${_file}	mkdir

# General expanding shell function
_exp_ ()
{
    # bash `complete' is broken because you can not combine
    # -d, -f, and -X pattern without missing directories.
    local c=${COMP_WORDS[COMP_CWORD]}
    local a="${COMP_LINE}"
    local o="$IFS"
    local e s g=0

    shopt -q extglob && g=1
    test $g -eq 0 && shopt -s extglob

    case "$1" in
    compress)		e='*.Z'					;;
    bzip2)
	    case "$c" in
	    -)		    COMPREPLY=(d c)
		  	        test $g -eq 0 && shopt -u extglob
			        return
					;;
 	    -?|-??)		COMPREPLY=($c)
			        test $g -eq 0 && shopt -u extglob
			        return
					;;
	    esac
 	    case "$a" in
	    *-?(c)d*)	e='!*.bz2'				;;
	    *)		    e='*.bz2'				;;
	    esac
		;;
    bunzip2)		e='!*.bz2'				;;
    gzip)
	    case "$c" in
	    -)		COMPREPLY=(d c)
			    test $g -eq 0 && shopt -u extglob
			    return
				;;
 	    -?|-??)	COMPREPLY=($c)
			    test $g -eq 0 && shopt -u extglob
			    return
				;;
	    esac
	    case "$a" in
	    *-?(c)d*)	e='!*.+(gz|tgz|z|Z)'			;;
	    *)		    e='*.+(gz|tgz|z|Z)'			;;
	    esac
		;;
    gunzip)		    e='!*.+(gz|tgz|z|Z)'			        ;;
    uncompress)		e='!*.Z'				                ;;
    unzip)		    e='!*.+(zip|ZIP|jar|exe|EXE)'		    ;;
    gs|ghostview)	e='!*.+(eps|EPS|ps|PS|pdf|PDF)'		    ;;
    gv)			    e='!*.+(eps|EPS|ps|PS|ps.gz|pdf|PDF)'	;;
    acroread|xpdf)	e='!*.+(pdf|PDF)'			            ;;
    dvips)		    e='!*.+(dvi|DVI)'			            ;;
    xdvi)		    e='!*.+(dvi|dvi.gz|DVI|DVI.gz)'		    ;;
    tex|latex)		e='!*.+(tex|TEX|texi|latex)'		    ;;
    okular)	        e='!*.+(eps|EPS|ps|PS|ps.gz|ps.bz2|pdf|PDF|pdf.gz|pdf.bz2|tif|tiff|TIF|TIFF|dvi|dvi.gz|div.bz2|DVI|DVI.gz|DVI.bz2|bmp|BMP|gif|GIF|jpg|jpeg|JPG|JPEG|ico|ICO|mng|MNG|pbm|PBM|pgm|PGM|ppm|PPM|png|PNG|tga|TGA|xbm|XBM|xpm|XPM)' ;;
    groovy)		    e='!*.groovy'		                    ;;
    export)
	    case "$a" in
	    *=*)		c=${c#*=}				;;
	    *)		COMPREPLY=($(compgen -v -- ${c}))
			    test $g -eq 0 && shopt -u extglob
			    return
				;;
	    esac
	    ;;
    *)			e='!*'
    esac

    case "$(complete -p $1)" in
	*-d*) ;;
	*) s="/"  
    esac

    IFS='
'
    case "$c" in
    \$\(*\))	COMPREPLY=(${c}) ;;
    \$\(*)		COMPREPLY=($(compgen -c -P '$(' -S ')'  -- ${c#??}))	;;
    \`*\`)		COMPREPLY=(${c}) ;;
    \`*)		COMPREPLY=($(compgen -c -P '\`' -S '\`' -- ${c#?}))	;;
    \$\{*\})	COMPREPLY=(${c}) ;;
    \$\{*)		COMPREPLY=($(compgen -v -P '${' -S '}'  -- ${c#??}))	;;
    \$*)		COMPREPLY=($(compgen -v -P '$'          -- ${c#?}))	;;
    ~*/*)		COMPREPLY=($(compgen -f -X "$e"         -- ${c}))	;;
    ~*)			COMPREPLY=($(compgen -u ${s:+-S$s} 	-- ${c}))	;;
    *@*)		COMPREPLY=($(compgen -A hostname -P '@' -S ':' -- ${c#*@})) ;;
    *[*?[]*)	COMPREPLY=($(compgen -G "${c}"))			;;
    *[?*+\!@]\(*\)*)
	    if test $g -eq 0 ; then
			COMPREPLY=($(compgen -f -X "$e" -- $c))
			test -z "$o" && unset IFS || IFS="$o"
			test $g -eq 0 && shopt -u extglob
			return
	    fi
	    COMPREPLY=($(compgen -G "${c}"))
		;;
    *)
	    if test "$c" = ".." ; then
			COMPREPLY=($(compgen -d -X "$e" -S / ${_nosp} -- $c))
	    else
			for s in $(compgen -f -X "$e" -- $c) ; do
			    if test -d $s ; then
				COMPREPLY=(${COMPREPLY[@]} $(compgen -f -X "$e" -S / -- $s))
			    else
				COMPREPLY=(${COMPREPLY[@]} $s)
			    fi
			done
	    fi
		;;
    esac
    test -z "$o" && unset IFS || IFS="$o"
    test $g -eq 0 && shopt -u extglob
}

complete -d -X '.[^./]*' -F _exp_ ${_file} \
				    compress \
				    bzip2 \
				    bunzip2 \
				    gzip \
				    gunzip \
				    uncompress \
				    unzip \
				    gs ghostview \
				    gv \
				    acroread xpdf \
				    dvips xdvi \
				    tex latex \
	                okular \
	                groovy

# No clean way to hande variable expansion _and_ file/dir name expansion
# with the same string. So let the default expansion on for that commands.
#complete -d -F _exp_ ${_def}		chown chgrp chmod chattr ln
#complete -d -F _exp_ ${_def}		more cat less strip grep vi ed

complete -A function -A alias -A command -A builtin \
					type
complete -A function			function
complete -A alias			alias unalias
complete -A variable			unset local readonly
complete -F _exp_ ${_def} ${_nosp}	export
complete -A variable -A export		unset
complete -A shopt			shopt
complete -A setopt			set
complete -A helptopic			help
complete -A user			talk su login sux
complete -A builtin			builtin
complete -A export			printenv
complete -A command ${_def}		command which nohup exec nice eval 
complete -A command ${_def}		ltrace strace gdb
HOSTFILE=""
test -s $HOME/.hosts && HOSTFILE=$HOME/.hosts
complete -A hostname			ping telnet slogin rlogin \
					traceroute nslookup
complete -A hostname -A directory -A file \
					rsh ssh scp
complete -A stopped -P '%'		bg
complete -A job -P '%'			fg jobs disown

# Expanding shell function for manual pager
_man_ ()
{
    local c=${COMP_WORDS[COMP_CWORD]}
    local o=${COMP_WORDS[COMP_CWORD-1]}
    local os="- f k P S t l"
    local ol="whatis apropos pager sections troff local-file"
    local m s

    if test -n "$MANPATH" ; then
	m=${MANPATH//:/\/man,}
    else
	m="/usr/X11R6/man/man,/usr/openwin/man/man,/usr/share/man/man"
    fi

    case "$c" in
 	 -) COMPREPLY=($os)	;;
	--) COMPREPLY=($ol) 	;;
 	-?) COMPREPLY=($c)	;;
    [1-9n]) COMPREPLY=($c)	;;
	 *)
	case "$o" in
	    -l) COMPREPLY=($(compgen -f -d -X '.*' -- $c)) ;;
	[1-9n]) s=$(eval echo {${m}}$o/)
		if type -p sed &> /dev/null ; then
		    COMPREPLY=(\
			$(ls -1fUA $s 2>/dev/null|\
			  sed -n "/^$c/{s@\.[1-9n].*\.gz@@g;s@.*/:@@g;p;}")\
		    )
		else
		    s=($(ls -1fUA $s 2>/dev/null))
		    s=(${s[@]%%.[1-9n]*})
		    s=(${s[@]#*/:})
		    for m in ${s[@]} ; do
			case "$m" in
			    $c*) COMPREPLY=(${COMPREPLY[@]} $m)
			esac
		    done
		    unset m s
		    COMPREPLY=(${COMPREPLY[@]%%.[1-9n]*})
		    COMPREPLY=(${COMPREPLY[@]#*/:})
		fi					   ;;
	     *) COMPREPLY=($(compgen -c -- $c))		   ;;
	esac
    esac
}

complete -F _man_ ${_file}		man

unset _def _dir _file _nosp

#
# End of /etc/profile.d/complete.bash
#
