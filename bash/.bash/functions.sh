#   
#   predefined functions section
#

unset functions function_help
declare -a functions function_help

function register_function () {

    functions[${#functions[@]}]=${1:?"register_function needs a function to register"}
    function_help[${#functions[@]}]=${2:-"empty help text"}

}
register_function 'register_function function [help_text]' \
		  'register function name and help text for later use'

function function_help () {

    if [ -z $1 ]; then 
	i=0
	while [ $i -lt ${#functions[@]} ]; do
	    echo ${functions[$i]}
	    i=$[$i+1]
	done
    else
	echo "help on specific function nyi"
    fi

}
register_function 'function_help [function]' \
		  'help on all or specific functions'

#
# extending the cd command to execute special files in the target directory
#
function cd () {

    builtin cd "${1:-$HOME}"
    test -f TO-DO && cat TO-DO
    test -f dir.sh && . dir.sh

}
register_function 'cd [targetdir]' 'cd, cat TO-DO, . functions.sh'

################################################################################
#
# following are functions to replace cp, mv and rm commands for directories 
# under subversion control.
# these functions have to differentiate whether the source and/or target files/
# folders of the command are under version control.
# this is not trivial, because the function has to differentiate between files
# and folders to work on as well (dirname on folders strips the leaf folder).
#
# TBD:
# - refactor to remove duplicate code
# - spaces and other special characters in the path
# - multiple (freely definable) directories under version control, instead of
#   just $HOME
#
################################################################################

#
# find out the full (absolute) path to $1
#
function realpath () {
  
    help='find out the full (absolute) path to argument'
    
    arg=${1:?"realpath called without argument"}

    target_0_=`echo ${arg} | head -c 1`               # first letter of target

  if [ -d ${arg} ]; then                            # directory: dirname == target
    if [ $target_0_ == "/" ]; then              # absolute path
      targetbasedir=${arg}
    else                                        # relative path
      targetbasedir=$(pwd)/${arg}
    fi
    target=$targetbasedir
  else                                          # target is a file
    if [ $target_0_ == "/" ]; then              # absolute path
      targetbasedir=$(dirname ${arg})
      target=${arg}
    else                                        # relative path
      targetbasedir=$(dirname $(pwd)/${arg})
      target=$targetbasedir/$(basename ${arg})
    fi
  fi

  echo $target                                  # output to be captured by caller

}
register_function 'realpath file|directory' \
		  'find out the full (absolute) path to argument'

#
# a replacement for mv taking into account that the home directory is under
# subversion control
# differentiates 4 cases:
# source in svn, target in svn         => svn move
# source not in svn, target in svn     => mv && svn add
# source in svn, target not in svn     => mv && svn remove
# source not in svn, target not in svn => mv
#
function move () {

  help='a replacement for mv taking into account that the home directory is under subversion control
    differentiates 4 cases:
    source in svn, target in svn         => svn move
    source not in svn, target in svn     => mv && svn add
    source in svn, target not in svn     => mv && svn remove
    source not in svn, target not in svn => mv'

  #
  # get source and target files
  #
  declare -a source
  i=0
  while [ $# -gt 1 ]; do
    source[$i]="$1"
    i=$[$i+1]
    shift
  done
  target="$1"

  #
  # get the absolute path for $target
  #
  target=$(realpath $target)

  #
  # check whether we would overwrite anything
  #
  if [ ! -d $target ]; then
    if [ ${#source[@]} -gt 1 ]; then
      echo "=== won't overwrite single file with multiple files ==="
      return
    fi
    if [ -f $target ]; then
      echo "=== not overwriting $target ==="
      echo 'TBD: add --force switch or somesuch, or read from commandline'
      return
    fi
  fi

  for sourcefile in ${source[@]}; do
    if [ $(echo $target | grep $HOME) ]; then   # target in home directory
      if [ $(realpath $sourcefile | grep $HOME) ]; then

        #
	# source in svn, target in svn         => svn move
	#
	svn move "$sourcefile" "$target"

      else

	#
	# source not in svn, target in svn     => mv && svn add
	#
	mv "$sourcefile" "$target" && svn add "$target"
	echo "=== get the svn add argument right: \$dir/\$file ==="
	echo "(possibly that works automatically because add works recursively)"

      fi
    else                                        # target not in home directory
      if [ $(realpath "$sourcefile" | grep $HOME) ]; then

	#
	# source in svn, target not in svn     => mv && svn remove
	#
	mv "$sourcefile" "$target" && svn remove "$sourcefile"

      else

	#
	# source not in svn, target not in svn => mv
	#
	mv "$sourcefile" "$target"

      fi
    fi
  done

}
register_function 'move source [source [...]] target' \
		  'a replacement for mv taking into account that the home directory is under
    subversion control
    differentiates 4 cases:
    source in svn, target in svn         => svn move
    source not in svn, target in svn     => mv && svn add
    source in svn, target not in svn     => mv && svn remove
    source not in svn, target not in svn => mv'

#
# a replacement for cp taking into account that the home directory is under
# subversion control
# differentiates 3 cases:
# source in svn, target in svn         => svn copy
# source not in svn, target in svn     => cp && svn add
# target not in svn                    => cp
#
function copy () {

  help='a replacement for cp taking into account that the home directory is under subversion control
    differentiates 3 cases:
    source in svn, target in svn         => svn copy
    source not in svn, target in svn     => cp && svn add
    target not in svn                    => cp'

  #
  # get source and target files
  #
  declare -a source
  i=0
  while [ $# -gt 1 ]; do
    source[$i]="$1"
    i=$[$i+1]
    shift
  done
  target="$1"

  #
  # get the absolute path for $target
  #
  target=$(realpath "$target")

  #
  # check whether we would overwrite anything
  #
  if [ ! -d $target ]; then
    if [ ${#source[@]} -gt 1 ]; then
      echo "=== won't overwrite single file with multiple files ==="
      return
    fi
    if [ -f $target ]; then
      echo "=== not overwriting $target ==="
      echo 'TBD: add --force switch or somesuch, or read from commandline'
      return
    fi
  fi

  for sourcefile in ${source[@]}; do
    if [ $(echo $target | grep $HOME) ]; then   # target in home directory
      if [ $(realpath $sourcefile | grep $HOME) ]; then

        #
	# source in svn, target in svn         => svn copy
	#
	svn copy $sourcefile $target

      else

	#
	# source not in svn, target in svn     => cp && svn add
	#
	cp $sourcefile $target \&\& svn add $target
	echo "=== get the svn add argument right: \$dir/\$file ==="
	echo "(possibly that works automatically because add works recursively)"

      fi
    else                                        # target not in home directory

      #
      # source not in svn, target not in svn => mv
      #
      cp $sourcefile $target

    fi
  done

}
register_function 'copy source [source [...]] target' \
		  'a replacement for cp taking into account that the home directory is under 
    subversion control
    differentiates 3 cases:
    source in svn, target in svn         => svn copy
    source not in svn, target in svn     => cp && svn add
    target not in svn                    => cp'

#
# a replacement for mv taking into account that the home directory is under
# subversion control
# differentiates 2 cases:
# target in svn         => svn remove
# target not in svn     => rm
#
function remove () {

help='a replacement for cp taking into account that the home directory is under subversion control
    differentiates 2 cases:
    target in svn         => svn remove
    target not in svn     => rm'

  for target in $@; do
    if [ $(echo $target | grep $HOME) ]; then   # target in home directory
      svn remove $target
    else                                        # target not in home directory
      rm $target
    fi
  done

}
register_function 'remove target [target [...]]' \
		  'a replacement for cp taking into account that the home directory is under
    subversion control
    differentiates 2 cases:
    target in svn         => svn remove
    target not in svn     => rm'

################################################################################

#
# functions for mounting encrypted loopback devices, and other encrypted devices
#

function secretup () {

    help='mount an encrypted file as loopback device - must be run with root rights, i am afraid'

    encryption_algorithm="blowfish"
    cryptfile=${1:-${HOME}/secret.wma}
    mountpoint=${2:-${HOME}/tmp}
    loopback=loop0
    PATH=/sbin:${PATH}
#   modprobe dm_crypt
    losetup /dev/${loopback} ${cryptfile}
    cryptsetup -c ${encryption_algorithm} create secret /dev/${loopback}
    mount /dev/${loopback} /home/helge/tmp

}
register_function 'secretup [cryptfile [mountpoint]]' \
		  'mount an encrypted file as loopback device - must be run with root rights, i am afraid'

function secretdown () {

    help='unmount an encrypted file from a loopback device - must be run with root rights, i am afraid'

    mountpoint=${1:-${HOME}/tmp}
    loopback=loop0
    PATH=/sbin:${PATH}
    umount ${mountpoint}
    cryptsetup remove secret
    losetup -d /dev/${loopback}

}
register_function 'secretdown [mountpoint]' \
		  'unmount an encrypted file from a loopback device - must be run with root rights, i am afraid'


function mount_encrypted_dvdram () {
    
    help=''
    
    encryption_algorithm="blowfish"
    dvdram_device="/dev/sr0"
    mount_point="/mnt/dvdrecorder"

cryptsetup -c ${encryption_algorithm} create dvdram ${dvdram_device}
    # sudo mkfs.ext2 /dev/mapper/dvdram
    mount -t ext2 /dev/mapper/dvdram ${mount_point}
    rsync -a --delete --backup --backup-dir=`date +%Y%m%d-%H:%M` . ${mount_point}

}
register_function 'mount_encrypted_dvdram' \
		  'mount dvdram with an encrypted file system and backup the current working directory to it'

function make_encrypted_isofs () {
    :
}
register_function 'make_encrypted_isofs - WRITE ME!' 

#
# parallel mp3 encoding for multiprocessor system
#
function num_lame_tasks() {
    ps a | cut -c 28- | grep ^lame | wc -l
}

function num_processors() {
#   if uname is linux
        ls /sys/class/cpuid | wc -w
}

function lame_encode() {

    i=0
    bitrate_command="-b"
    target_bitrate=128

    for arg in "$@"; do

	case "$arg" in
	    -b|--abr)
		bitrate_command=$arg
		target_bitrate="$2"; shift 2
		continue
		;;

	    *.[mM][pP]3|*.[wW][aA][vV])
		;;

	    # TO DO: other lame arguments, ogg vorbis files

	    *)
		continue
		;;
	esac

	mp3file=$arg
	i=$[$i+1]

	# this function was historically used to downsize MP3's. Thus first the
	# bitrate is checked
	# to do: if id3info is installed, use it - also if mpg123 returns 0 kbps
	bitrate=$(mpg123 -t "$mp3file" 2>&1 | grep kbit/s | cut -d ' ' -f 5)
	if [ -z $bitrate ]; then
	    bitrate=$(id3info "$mp3file" | grep Bitrate | cut -d ' ' -f 2 | tr -d [:alpha:])
	fi
	test -z $bitrate && bitrate=0

	echo $i/$# $mp3file: $bitrate

	# if resizing is any use...:
	if [ $bitrate -gt $target_bitrate ]; then
	    # start lame process in the background, suppressing bash job info
	    ( lame -S $bitrate_command $target_bitrate -q 0 "$mp3file" "$mp3file.bak" && \
		mv "$mp3file.bak" "$mp3file" & ) > /dev/null
	    # show job number and PID of the task hust started
	    # jobs -l | cut -c 1-10
	fi

	# wait for a lame process to finish, if there is CPU saturation	
	while [ $(num_lame_tasks) -ge $(num_processors) ]; do
	    sleep 1
	done
    done

    wait
}

register_function 'lame_encode' \
		  'reencode a number of mp3 files to 128 kbit in parallel using num_cpu processes - there is much room for improvement in this function! call with list of mp3 files, e.g. IFS="\n" lame_encode $(find . -print -name \*.mp3)'
