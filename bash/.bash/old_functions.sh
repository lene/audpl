################################################################################

#
# a couple of ancient convenience functions follow, neither well written, well
# documented, nor much used any more
#

function register_function() {
    :
}

function tgz () {

    archive_name=${1:?"specify an archive name"}.tar.gz
    echo $archive_name "wont be archived; use of tgz is prohibited until"
    echo "you solved the problem with trailing slashes in the directory name!"
    return

    for i in $@; do
	shift
	tar cO $@ | gzip -9f > $archive_name && rm -rf $@ 
    done

}
register_function 'tgz archive [file|dir [...]]' \
		  'not working right now, but supposed to archive all files/folders specified as args into a tar archive with the name derived from the first argument'


function tbz () {

    archive_name=${1:?"specify an archive name"}.tar.bz2
    echo $archive_name "wont be archived; use of tbz is prohibited until"
    echo "you solved the problem with trailing slashes in the directory name!"
    return 

    for i in $@; do
	shift
	echo compressing $i in $archive_name
	tar cO $@ | bzip2 -9sf > $archive_name && rm -rf $@ 
    done

}
register_function 'tbz archive [file|dir [...]]' \
		  'not working right now, but supposed to archive all files/folders specified as args into a tar archive with the name derived from the first argument'


function cpdir () {

    mkdir -p ${2?}
    (cd ${1?}; tar cf - .) | (cd ${2?}; tar xf -) 

}
register_function 'cpdir source target' \
		  'err... what is the difference to cp -r? i dont know any more...'

function mvdir () {

    cpdir ${1:?} ${2:?} && diff ${1:?} ${2:?} > /dev/null && rm -r ${1:?} 

}
register_function 'mvdir source target' \
		  'other than mv, mvdir works across file systems and diffs the result before \
removing the source dir'

function png2jpg () {                           

    help='converts 1 PNG file to JPEG format. CAUTION - recognizes only the first field of the file name. do not use on files like foo.001.png, the 2nd field will be lost'

    image_name=`echo ${1:?} | cut -d . -f 1`

    shift
    pngtopnm $image_name.png | \
	cjpeg -optimize -dct float -quality 90 $@ -outfile $image_name.jpg 
}
register_function 'png2jpg png_file [cjpeg options]' \
'converts 1! PNG file to JPEG format CAUTION! recognizes only the first field of the file name. do not use on files like foo.001.png, the 2nd field will be lost!'

function AudioCDBurn () {

    help='AudioCDBurn [audiofiles] burns an audio CD from the given audiofiles. if the CD writer supports it, a multisession CD is written allowing you to burn more tracks to the CD later. the process is simulated first and the writing only takes place if the simulation succeeds. the process is done in dual speed, so you can expect all of it to be finished in the playing time of the CD. if no files are given, burns all .wav files in current directory.'

    Audiofiles=${*:-"*.wav"}
    speed=4
    device=FIXME

    if [ "$Audiofiles" = "-h" -o "$Audiofiles" = "--help" ]; then

	echo ${help}
    else 

	echo -n burning: 
	for i in $Audiofiles; do 
	    echo -n "    "$i
	done
	echo
	echo -n "continue (y/n)?"
	read i
	if [ x"$i" = "xy" -o x$i = "xY" ]; then
	    cdrecord -v speed=${speed} dev=0,4,0 -multi -audio -dummy $Audiofiles &&
	    cdrecord -v speed=${speed} dev=0,4,0 -multi -audio -eject $Audiofiles 
	else
	    echo aborted!
	fi
    fi
}
register_function 'AudioCDBurn [audiofiles]' \
		  'burns an audio CD from the given audiofiles. if the CD writer supports it, a multisession CD is written, allowing you to burn more tracks to the CD later. the process is simulated first and the writing only takes place if the simulation succeeds. the process is done in dual speed, so you can expect all of it to be finished in the playing time of the CD. if no files are given, burns all .wav files in current directory.'

function CDRip () {

    help='Usage: CDRip [device] [tracks] reads audio tracks from a CD and writes them to .wav files. device is either /dev/sr0 -the CD writer- or /dev/sr1 -the CD ROM-. the default is the CD ROM. tracks is of the form "first+last". the default is to read all tracks on the CD. CDRip works only if you are root.'

    Device=${1:-/dev/sr1}
    Tracks=${2:+"-t" $2}

    if [ $Device = "-h" -o $Device = "--help" ]; then

	echo ${help}

    else

        cdda2wav -D $Device -B -x -H $Tracks && \
	eject $Device
	
    fi
}
register_function 'CDRip [device] [tracks]' \
	          'reads audio tracks from a CD and writes them to .wav files. device is either /dev/sr0 -the CD writer- or /dev/sr1 -the CD ROM-. the default is the CD ROM. tracks is of the form "first+last". the default is to read all tracks on the CD. CDRip works only if you are root.'


function MP3Encode () {
    Audiofiles=${*:-"*.wav"}
    for i in $Audiofiles; do

	if [ -d "$i" ]; then
	    cd "$i"
	    echo '***' "$i" '-' `pwd` '***'
	    MP3Encode "*"
	    cd ..
	else
	    Extension=`echo "$i" | rev | cut -d '.' -f 1 | rev`
	    case "$Extension" in "mp3" | "MP3" | "log" ) 
		continue ;;
	    esac
	    lame -v -m s --abr 256 -q 0 -b 32 "$i" && rm -f "$i"
	    
	fi
    done
}
register_function 'MP3Encode [audiofile|dir [...]]'


function png2mpeg () {
    mkdir anim
    cd anim
    for i in ../*.png; do 
	image_name=`echo $i | cut -d . -f 3 | cut -d / -f 2`; 
	echo $image_name; 
	pngtopnm $i > $image_name.ppm; 
    done
    echo "now go find MPEG-1.par or PAL.par, edit it and run"
    echo "mpeg2encode in this directory!"
}
register_function 'png2mpeg'

################################################################################

#
# root-specific commands
#

#       RPM manipulation

function un () {                # uninstall package/s
    Package=${1:?}              # maybe delete leading path and trailing .rpm,
				# but dont know how to do that now
    shift

    rpm -e $Package             # uninstall
    rm $Package.rpm             # remove archive - must be in current directory

    if [ "x$*" != "x" ]; then   # process further args
	un $@
    fi
}
register_function "un"

function show () {              # show package description
    for i in $@; do
	grep $i INDEX           # must be in current dir
    done
}
register_function "show"
