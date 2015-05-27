#!/bin/bash


music_dir=$HOME/Music
music_exe="audacious -e"
movie_dir=/mnt/Movies
movie_exe=mplayer

#####
# Menu Functions
#########
# CheckedMenuItem MenuName ItemTitle ExecutableName [%Icon%] [Path]
# if ExecutableName exists, add an item to MenuName which executes it
function CheckedMenuItem () {
	which $(echo $2 | cut -d \' \' -f 1) >> /dev/null 2>&1 && \
	      echo "AddToMenu $0 \'$1$3\' Exec exec $2"
}

# CheckedSudoMenuItem MenuName ItemTitle ExecutableName [%Icon%] [Path]
# if ExecutableName exists, add an item to MenuName which executes it under sudo
function CheckedSudoMenuItem () {
	which $2 >> $[HOME]/.fvwm.log 2>&1 && \
	      echo "AddToMenu $0 \'$1$3\' Exec exec gksudo $2"
}

# CheckedXTermMenuItem MenuName ItemTitle ExecutableName [%Icon%] [Path]
# if ExecutableName exists, add an item to MenuName which executes it in an xterm
function CheckedXTermMenuItem () {
	which $2 >> $[HOME]/.fvwm.log 2>&1 && \
	      echo "AddToMenu $0 \'$1%menu/terminal.png%\' Exec exec xterm -e $2"
}

# RemoteMRXVTItem MenuName ItemTitle %Icon% $REMOTE_HOST $PORT $PUB_KEY
# Open a remote MRXVT (if installed) or XTerm on $REMOTE_HOST (which can have the
# form user@host) using $PORT and public ssh key $PUB_KEY
function RemoteMRXVTItem () {
	if [ `which mrxvt` ]; then 
		echo "AddToMenu $0 \"$1$2\" Exec exec mrxvt -vt0.e \'ssh -i $5 -C -Y -p $4 $3\' -vt1.e \'ssh -i $5 -C -Y -p $4 $3\' -vt2.e \'ssh -i $5 -C -Y -p $4 $3\'"
	else echo "AddToMenu $0 \"$1$2\" Exec exec xterm -sb -sl 1024 -fn 10x20 -e ssh -C -Y -i $5 -p $4 $3"
	fi
}

#  Function parameters: $0       $1        $2     $3           $4       $5           $6       $7          $8       $9
# RemoteMRXVTTunnelItem MenuName ItemTitle %Icon% $REMOTE_HOST $FW_HOST $REMOTE_PORT $FW_PORT $LOCAL_PORT $PUB_KEY $REMOTE_USER
# Open a remote MRXVT (if installed) or XTerm as $REMOTE_USER on $REMOTE_HOST,
#  tunneling through firewall $FW_HOST (can take a username as above), using
# $REMOTE_PORT on remote host and $FW_PORT on the firewall. $LOCAL_PORT is used
# on the local host to tunnel the ssh connection. Public ssh key: $PUB_KEY
function RemoteMRXVTTunnelItem () {
	(ssh -i $8 -p $6 -L $7:$3:$5 -N -f $4 &)
	echo "AddToMenu $0 \"$1$2\" Exec exec xterm -sb -sl 1024 -fn 10x20 -e ssh -i $8 -C -Y -l $9 -p $7 localhost"
	ssh -p $6 -L $7:$3:$5 -N -f $4
	if [ `which mrxvt` ]; then 
		echo "AddToMenu $0 \"$1$2\" Exec exec mrxvt -vt0.e \'ssh -i $8 -C -Y -l $9 -p $7 localhost\' -vt1.e \'ssh -i $8 -C -Y -l $9 -p $7 localhost\' -vt2.e \'ssh -i $8 -C -Y -l $9 -p $7 localhost\' "
	else 
		echo "AddToMenu $0 \"$1$2\" Exec exec xterm -sb -sl 1024 -fn 10x20 -e ssh -i $8 -C -Y -l $9 -p $7 localhost"
	fi
}

#####
# Wallpaper Menu
###########
function BuildWallPaperMenu() {
	rm $[fvwm_icon]/wallpaper/*.png
	for i in $[fvwm_img]/wallpaper/*.png; do 
		convert -scale 64 $i "$[fvwm_icon]/wallpaper/`basename $i`"
	done && echo Nop
	rm $[fvwm_home]/WallpaperMenu
	echo "DestroyMenu FvwmWallpaperMenu" > $[fvwm_home]/WallpaperMenu
	echo "AddToMenu FvwmWallpaperMenu \"Wallpapers\" Title" >> $[fvwm_home]/WallpaperMenu
	for i in $[fvwm_img]/wallpaper/*.png; do 
		echo "AddToMenu FvwmWallpaperMenu \"`basename $i`%wallpaper/`basename $i`%\" FvwmChangeBackground \"`basename $i`\"" >> $[fvwm_home]/WallpaperMenu
	done && echo Nop
	Read $[fvwm_home]/WallpaperMenu
}

function FvwmChangeBackground() {
	fvwm-root --retain-pixmap $[fvwm_img]/wallpaper/$0
	echo "fvwm-root --retain-pixmap $[fvwm_img]/wallpaper/$0" > $[fvwm_home]/cfg/background.cfg
}

function InitWallpaper() {
	source $[fvwm_home]/cfg/background.cfg
}

#####
#
###########
function Thumbnail() {
+ I Raise
#+ I ThisWindow (!Shaded Iconifiable !Iconic) \
PipeRead  "xwd -silent -id $[w.id] | convert -scale $$(($[w.width]/8)) -frame 1x1 \
    -mattecolor black -quality 0 xwd:- png:$[fvwm_home]/tmp/icon.tmp.$[w.id].png \
    && echo Nop"
#+ I TestRc (Match) Test (f $[fvwm_home]/icons/$[w.iconfile]) \
PipeRead "composite -geometry +2+4 \
    $[fvwm_home]/icons/$[w.iconfile] $[fvwm_home]/tmp/icon.tmp.$[w.id].png \
    $[fvwm_home]/tmp/icon.tmp.$[w.id].png && \
    echo WindowStyle IconOverride, Icon $[fvwm_home]/tmp/icon.tmp.$[w.id].png || echo Nop"
#+ I TestRc (NoMatch) WindowStyle IconOverride, Icon $[fvwm_home]/tmp/icon.tmp.$[w.id].png
+ I Iconify
}

function DeThumbnail () {
+ I DestroyWindowStyle
+ I Exec rm -f $[fvwm_home]/tmp/icon.tmp.$[w.id].png
}

function   ReThumbnail() {
+ I Iconify
+ I Thumbnail
}

#####
# FvwmExpose
###########
function FvwmExpose() {
+ I AddToMenu FvwmExposeMenu "e x p o s e" Title
+ I + DynamicPopDownAction DestroyMenu FvwmExposeMenu
#+ I All (!Iconic !Shaded AcceptsFocus)\
    PipeRead "echo Raise; \
        xwd -silent -id $[w.id] | convert -scale $$(($[w.width]/10)) -quality 0 xwd:- \
        png:$[fvwm_home]/tmp/icon.exp.$[w.id].png \
    && echo AddToMenu FvwmExposeMenu \
    %$[fvwm_home]/tmp/icon.exp.$[w.id].png%\\\'\"$[w.name]\"\\\' WindowID $[w.id] WarpToWindow 50 50 \
        && echo AddToMenu FvwmExposeMenu \\\"\\\" Nop \
    || Nop"
+ I Popup FvwmExposeMenu
+ I Exec exec rm -f $[fvwm_home]/tmp/icon.exp.*
}

#####
#
#
function MakeWMMenu() {
#+ I AddToMenu WindowManagerMenu "Start other Window Manager" Title
#+ I PipeRead 'for wm in $(qpkg -I -nc "x11-wm/*" | cut -d "/" -f 2 | tac); do echo AddToMenu WindowManagerMenu "\'Start $wm\'" Restart $wm; done'
#+ I PipeRead 'for wm in $(equery -C list -i "x11-wm/" | cut -d "/" -f 2 | tac | head -n -1 | sort); do wmshort=$(echo ${wm} | cut -d "-" -f 1); echo AddToMenu WindowManagerMenu "\'Start ${wm}%menu/${wmshort}.png%\'" Restart ${wmshort}; done'
	for pkg in /usr/portage/x11-wm/*; do wm=$(echo $pkg | rev | cut -d / -f 1 | rev); which $wm > /dev/null 2>&1 && echo AddToMenu WindowManagerMenu "\'Start ${wm}%menu/${wm}.png%\'" Restart ${wm}; done
}
#####
# You can browse directories and files with the fvwm-menu-directory script
# http://www.mail-archive.com/fvwm%40hpc.uh.edu/msg05260.html
#################
function FuncFvwmMenuDirectory() {
	case "$0" in 
        "$[movie_dir]"*) myexec="$[movie_exe]" mypng=mini/multimedia.xpm;; 
        "$[music_dir]"*) myexec="$[music_exe]" mypng=mini/music.xpm;; 
        "$[image_dir]"*) myexec="$[image_exe]" mypng=mini/gnome-image-jpeg.xpm;; 
		*)               myexec="rox"          mypng="mini/folder.xpm";; 
    esac
    test -f "$0"/.icontitle.png && mytitle="$0"/.icontitle.png
    fvwm-menu-directory --icon-title "${mytitle:-mini/folder-open.png}" --icon-file ${mypng:-mini/file.xpm} \
    --icon-dir mini/folder.xpm --dir "$0" --exec-t="^${myexec:-gvim} $0" \
    --exec-file "^${myexec:-gvim}"
}

function MakePlanetsMenu() {
	$[fvwm_scrpt]/MakePlanetMenu.sh
}

function AddToMenu() {
	echo $1 $2 $3
}
function AddMenuItem() {
	echo "+   "$@
}

#################################################################################
# Terminals Menu
#################################################################################

#####
# Remote Terminals Menu
#################################################################################

#####
# Taz Logins
############

AddToMenu	TazMenu	"taz" 	Title
RemoteMRXVTItem TazMenu "t3dev" "%menu/konsole_remote.png%" "t3dev.hal.taz.de" 22 $[HOME]/.ssh/id_rsa
RemoteMRXVTItem TazMenu "t3red" "%menu/konsole_remote.png%" "t3red.hal.taz.de" 22 $[HOME]/.ssh/id_rsa
RemoteMRXVTItem TazMenu "segfault" "%menu/konsole_remote.png%" "helge@segfault.hal.taz.de" 22 $[HOME]/.ssh/id_rsa
RemoteMRXVTItem TazMenu "www" "%menu/konsole_remote.png%" "helge@www.taz.de" 22 $[HOME]/.ssh/id_rsa
#RemoteMRXVTItem TazMenu "jupiter" "%menu/konsole_remote.png%" "jupiter.hal.taz.de" 22 /home/helge/.ssh/id_rsa
# RemoteMRXVTTunnelItem MenuName ItemTitle %Icon%                      $REMOTE_HOST $FW_HOST                       $REMOTE_PORT $FW_PORT $LOCAL_PORT $PUB_KEY                  $REMOTE_USER
RemoteMRXVTTunnelItem   TazMenu  "w3"      "%menu/konsole_remote.png%" w3.taz.de    "segfault.hal.taz.de"    22           22       10023       $[HOME]/.ssh/id_rsa       lene

#####
# FZ Rossendorf Logins
############
#AddToMenu	FZRMenu	"FZ Rossendorf" 	Title
#RemoteMRXVTItem FZRMenu "mars" "%menu/konsole_remote.png%" "preuss@mars.fz-rossendorf.de" 22 $[HOME]/.ssh/id_helge
#Exec ssh -i $[HOME]/.ssh/id_helge -p 22 -L 10024:saturn:22 -N -f preuss@mars.fz-rossendorf.de
#AddToMenu FZRMenu "saturn%menu/konsole_remote.png%" Exec exec mrxvt -vt0.e 'ssh -i $[HOME]/.ssh/id_helge -C -Y -l preuss -p 10024 localhost' -vt1.e 'ssh -i $[HOME]/.ssh/id_helge -C -Y -l preuss -p 10024 localhost' -vt2.e 'ssh -i $[HOME]/.ssh/id_helge -C -Y -l preuss -p 10024 localhost'
#  Function parameters: $0       $1        $2                          $3           $4                             $5           $6       $7          $8       $9
# RemoteMRXVTTunnelItem MenuName ItemTitle %Icon%                      $REMOTE_HOST $FW_HOST                       $REMOTE_PORT $FW_PORT $LOCAL_PORT $PUB_KEY                  $REMOTE_USER
#RemoteMRXVTTunnelItem   FZRMenu  "saturn"  "%menu/konsole_remote.png%" w3       "preuss@mars.fz-rossendorf.de" 22           22       10023       $[HOME]/.ssh/id_helge preuss


#####
# Remote Terminals Menu
#######################
AddToMenu RTermsMenu "Remote Login" Title
AddMenuItem "taz%menu/konsole_remote.png%" Popup TazMenu
#AddMenuItem "FZ Rossendorf%menu/konsole_remote.png%" Popup FZRMenu
RemoteMRXVTItem RTermsMenu "newspaper-typo3.org" "%menu/konsole_remote.png%" "newspaper@newspaper-typo3.org" 22 $[HOME]/.ssh/sourceforge
# RemoteMRXVTItem MenuName ItemTitle %Icon% $REMOTE_HOST $PORT $PUB_KEY
#RemoteMRXVTItem RTermsMenu "sue" "%menu/konsole_remote.png%" "sue" 10022 $[HOME]/.ssh/sourceforge
#RemoteMRXVTItem RTermsMenu "sue - remote" "%menu/konsole_remote.png%" "88.134.0.192" 10022 $[HOME]/.ssh/sourceforge
RemoteMRXVTItem RTermsMenu "ganymede" "%menu/konsole_remote.png%" "ganymede" 22 $[HOME]/.ssh/sourceforge
#AddMenuItem "ganymede (remote)%menu/konsole_remote.png%"	Exec exec ssh -l helge -p 10022 -L 10023:ganymede:22 -N -f 88.134.0.192; mrxvt -vt0.e "ssh -C -p 10023 localhost" -vt1.e "ssh -C -p 10023 localhost" -vt2.e "ssh -C -p 10023 localhost"
# RemoteMRXVTTunnelItem MenuName ItemTitle %Icon% $REMOTE_HOST $FW_HOST $REMOTE_PORT $FW_PORT $LOCAL_PORT $PUB_KEY $REMOTE_USER
#RemoteMRXVTTunnelItem RTermsMenu "ganymede - remote" "%menu/konsole_remote.png%"  ganymede "helge@88.134.0.192" 22 10022 10023 $[HOME]/.ssh/sourceforge helge
# "root@WRT54g%menu/konsole_remote.png%"	Exec exec xterm -sb -sl 1024 -fn 10x20 -bg \#000000 -fg \#ffffff -e ssh root@192.168.2.66
#RemoteMRXVTItem RTermsMenu "hyperspace-expl.sourceforge.net" "%menu/konsole_remote.png%" "metaldog@hyperspace-expl.sourceforge.net" 22 $[HOME]/.ssh/sourceforge
RemoteMRXVTItem RTermsMenu "helge@gubi24.de" "%menu/konsole_remote.png%" "helge@gubi24.de" 10022 $[HOME]/.ssh/id_rsa
#RemoteMRXVTItem RTermsMenu "helge@dieberlinseite.de" "%menu/konsole_remote.png%" "helge@dieberlinseite.de" 22 $[HOME]/.ssh/id_rsa
#RemoteMRXVTItem RTermsMenu "squid@7aes.net" "%menu/konsole_remote.png%" "squid@7aes.net" 10022 $[HOME]/.ssh/sourceforge
RemoteMRXVTItem RTermsMenu "RootServer" "%menu/konsole_remote.png%" "root@195.226.161.149" 10022 $[HOME]/.ssh/id_rsa

#####
# Terminals Menu
#################################################################################
AddToMenu TermsMenu "Terminals" Title
AddMenuItem "Remote Login%menu/konsole_remote.png%" Popup RTermsMenu
AddMenuItem "MRXVT%menu/konsole_2.png%"		Exec exec mrxvt -stt
AddMenuItem "XTerm  5x7%menu/konsole_5.png%"	Exec exec xterm -bg rgb:e6/e6/e6 -fn 5x7 -sb -sl 500 AddMenuItemls -n 'XTerm'
AddMenuItem "XTerm  6x12%menu/konsole_5.png%"	Exec exec xterm -bg rgb:e6/e6/e6 -fn 6x12 -sb -sl 500 +ls -n 'XTerm'
AddMenuItem "XTerm  7x14%menu/konsole_5.png%"	Exec exec xterm -bg rgb:e6/e6/e6 -sb -sl 500 +ls -fn 7x14 -fb 7x14bold -n 'XTerm'
AddMenuItem "XTerm  8x16%menu/konsole_5.png%"	Exec exec xterm -sb -sl 1024 -fn 8x16
+ "XTerm 10x20%menu/konsole_5.png%"	Exec exec xterm  -bg rgb:e6/e6/e6 -sb -sl 500 +ls -fn 10x20 -n 'Large XTerm'
AddMenuItem "XTerm 12x24%menu/konsole_5.png%"	Exec exec xterm -geometry 82x34 -bg rgb:e0/e0/e0 -sb -sl 512+ls -fn 12x24 -n 'Huge XTerm'
AddMenuItem "Root XTerm%menu/terminal_shell.png%" Exec exec xterm -bg rgb:e6/20/20 -sb -sl 500 +ls -fn 10x20 -n 'Root Terminal' -e su
AddMenuItem "Enlightened Terminal%menu/gnome-eterm.png%" Exec exec Eterm --geometry 82x40 --trans --scrollbar-type next --scrollbar-floating --name 'Enlightened Terminal' --font1 7x14 --font2 8x16 --font3 10x20 --font4 12x24
CheckedMenuItem TermsMenu Konsole "konsole" "%menu/konsole_blue.png%"
AddMenuItem "FVWM Console%menu/terminal.png%"	Module FvwmConsole





#################################################################################
# File Manager Menu
#################################################################################

AddToMenu FileMgrMenu 	    "File Managers" 		Title
AddToMenu FileMgrMenu 	    MissingSubmenuFunction 	FuncFvwmMenuDirectory
AddMenuItem "/%menu/gnome-searchtool.png%"			Popup /
AddMenuItem "Home Directory%menu/kfm_home.png%"			Popup $[HOME]
AddMenuItem "" Nop
CheckedMenuItem FileMgrMenu "Dolphin" 			dolphin		"%menu/dolphin.png%"
CheckedMenuItem FileMgrMenu "Konqueror" 		konqueror	"%menu/konqueror.png%"
CheckedMenuItem FileMgrMenu "Nautilus" 			nautilus	"%menu/gnome-searchtool.png%"
CheckedMenuItem FileMgrMenu "Thunar" 			thunar		"%menu/.png%"
CheckedMenuItem FileMgrMenu "PCManFM" 			pcmanfm		"%menu/pcmanfm.png%"
CheckedMenuItem FileMgrMenu "ROX" 				rox			"%menu/xffm.png%"
CheckedMenuItem FileMgrMenu "XFFM" 				xffm		"%menu/xffm.png%"
CheckedMenuItem FileMgrMenu "KDESvn"			kdesvn		"%menu/kdesvn.png%"
CheckedMenuItem FileMgrMenu "eSvn"				esvn		"%menu/esvn_folder.png%"
CheckedMenuItem FileMgrMenu "RapidSVN"			rapidsvn	"%menu/kdesvn.png%"
CheckedMenuItem FileMgrMenu "PySVN WorkBench"	svn-workbench "%menu/.png%"
CheckedMenuItem FileMgrMenu "KFileManager"		kfm			"%menu/kfm.png%"
CheckedMenuItem FileMgrMenu "GnomeMidnightCommander"	gmc
CheckedMenuItem FileMgrMenu "FileSystemVisualizer"	fsv
CheckedMenuItem FileMgrMenu "Explorer" 			explorer
CheckedMenuItem FileMgrMenu "XFte" 				"xfte -C"
CheckedMenuItem FileMgrMenu "gitk" 				gitk		"%menu/git.png%"
CheckedMenuItem FileMgrMenu "gitg" 				gitd		"%menu/git.png%"
CheckedMenuItem FileMgrMenu "git-cola" 			git-cola	"%menu/git.png%"
CheckedMenuItem FileMgrMenu "giggle" 			giggle		"%menu/git.png%"


#################################################################################
# Programs Menu
#################################################################################

#####
# Editor Menu
#################################################################################

#####
# Emacs
#######
AddToMenu   EmacsMenu "Emacs" Title
CheckedMenuItem EmacsMenu Xemacs xemacs "%menu/emacs.png%"
CheckedMenuItem EmacsMenu "GNU Emacs" emacs "%menu/emacs.png%"

#####
# vi
####
AddToMenu   ViMenu "Vi" Title
CheckedMenuItem ViMenu GVim gvim "%menu/vim.png%"
CheckedMenuItem ViMenu EVim evim "%menu/evim.png%"
CheckedXTermMenuItem ViMenu Vi vi

#####
# Special Formats
#########################################
#####
# HTML
######
AddToMenu   HTMLMenu "HTML" Title
CheckedMenuItem HTMLMenu Quanta quanta "%menu/quanta.png%"
CheckedMenuItem HTMLMenu NVU "nvu" "%menu/nvu.png%"

#####
# PDF
#####
AddToMenu   PDFMenu "PDF" Title
CheckedMenuItem PDFMenu "Acrobat Reader" acroread "%menu/acroread.png%"
CheckedMenuItem PDFMenu KPDF "kpdf" "%menu/kpdf.png%"
CheckedMenuItem PDFMenu XPDF "xpdf" "%menu/xpdf.png%"

#####
# PostScript
############
AddToMenu   PSMenu "PostScript" Title
CheckedMenuItem PSMenu KGhostView kghostview "%menu/kghostview.png%"
CheckedMenuItem PSMenu GV gv "%menu/gv.png%"

#####
# Special Formats
#################
AddToMenu   FormatsMenu "Special Formats" Title
AddMenuItem "HTML%menu/.png%"	        Popup HTMLMenu
AddMenuItem "PDF%menu/acroread.png%"	Popup PDFMenu
AddMenuItem "PostScript%menu/ps.png%"	Popup PSMenu
CheckedMenuItem FormatsMenu Dasher "dasher" "%menu/dasher.png%"
CheckedMenuItem FormatsMenu KDVI "kdvi" "%menu/kdvi.png%"
CheckedMenuItem FormatsMenu KCHMViewer kchmviewer "%menu/kchmviewer.png%"

#####
# Editor Menu
#############
AddToMenu   EditorMenu "Editors" Title
AddMenuItem "Emacs%menu/emacs.png%"	Popup EmacsMenu
AddMenuItem "Vi%menu/vim.png%"	        Popup ViMenu
AddMenuItem "Special Formats%menu/.png%"	Popup FormatsMenu
CheckedMenuItem EditorMenu Kate kate "%menu/kate.png%"
CheckedMenuItem EditorMenu "Komodo Edit" /opt/Komodo-Edit-9/bin/komodo "%menu/kate.png%"
CheckedMenuItem EditorMenu Okular okular "%menu/okular.png%"
CheckedMenuItem EditorMenu KEdit kedit "%menu/kedit.png%"
CheckedMenuItem EditorMenu KWrite kwrite "%menu/kwrite.png%"
CheckedMenuItem EditorMenu KHexEdit khexedit "%menu/khexedit.png%"
CheckedXTermMenuItem EditorMenu Nano nano


#####
# Net Menu
#################################################################################

#####
# Browser Menu
###########
AddToMenu   BrowserMenu "Browsers" Title
CheckedMenuItem BrowserMenu Chrome chromium-bin "%menu/.png%"
CheckedMenuItem BrowserMenu Chromium chromium-browser "%menu/.png%"
CheckedMenuItem BrowserMenu Firefox firefox "%menu/firefox.png%"
CheckedMenuItem BrowserMenu "rekonq"    rekonq "%menu/rekonq.png%"
CheckedMenuItem BrowserMenu "Opera" opera "%menu/mozilla.png%"
CheckedMenuItem BrowserMenu "Mozilla" mozilla "%menu/mozilla.png%"
CheckedMenuItem BrowserMenu "Konqueror"	konqueror "%menu/konqueror.png%"
CheckedXTermMenuItem BrowserMenu "Lynx" lynx
CheckedXTermMenuItem BrowserMenu "Links" links
CheckedMenuItem BrowserMenu Netscape netscape

#####
# Mail Menu
###########
AddToMenu   MailMenu "Mail + News Clients" Title
CheckedMenuItem MailMenu "Thunderbird" thunderbird "%menu/mozillathunderbird-bin-icon.png%"
CheckedMenuItem MailMenu "Mozilla" "mozilla -mail" "%menu/mozilla.png%"
CheckedMenuItem MailMenu "Evolution" evolution "%menu/evolution.png%"
CheckedMenuItem MailMenu Balsa balsa
CheckedMenuItem MailMenu KMail kmail "%menu/kmail.png%"
CheckedXTermMenuItem MailMenu pine pine
CheckedXTermMenuItem MailMenu mutt mutt
CheckedMenuItem MailMenu KNode "knode"  "%menu/knode.png%"

#####
# Filesharing Menu
##################
AddToMenu FilesharingMenu "Filesharing" Title
CheckedMenuItem FilesharingMenu "Nicotine" nicotine "%menu/nicotine.png%"
CheckedMenuItem FilesharingMenu "Nicotine (anonymous)" nicotine-tor "%menu/nicotine-tor.png%"
CheckedMenuItem FilesharingMenu "MuSeeq" "linux32 /mnt/gentoo32/usr/local/bin/museeq"  ""
CheckedMenuItem FilesharingMenu "ED2k GUI" ed2k_gui  "%menu/ed2k.png%"
CheckedMenuItem FilesharingMenu "MLDonkey" mlgui  "%menu/mldonkey.png%"
CheckedMenuItem FilesharingMenu "KMLDonkey" kmldonkey  "%menu/kmldonkey.png%"
CheckedMenuItem FilesharingMenu "KTorrent" ktorrent  "%menu/ktorrent.png%"
CheckedMenuItem FilesharingMenu "BitTorrent" bittorrent  "%menu/bittorrent.png%"
CheckedMenuItem FilesharingMenu "Azureus" azureus  "%menu/azureus.png%"

#####
# Chat Menu
###########
AddToMenu   ChatMenu "Chat + IM" Title
CheckedMenuItem ChatMenu "Psi" psi "%menu/.png%"
CheckedMenuItem ChatMenu "gaim" gaim "%menu/gaim.png%"
CheckedMenuItem ChatMenu "pidgin" pidgin "%menu/pidgin.png%"
CheckedMenuItem ChatMenu "Kopete" kopete "%menu/kopete.png%"
CheckedMenuItem ChatMenu "Skype" skype  "%menu/skype.png%"
CheckedMenuItem ChatMenu "KSirc" ksirc "%menu/ksirc.png%"
CheckedMenuItem ChatMenu "Yahoo! Messenger" ymessenger  "%menu/yahoomess.png%"

#####
# Net Admin Menu
###########
AddToMenu   NetAdminMenu "Network Administration" Title
CheckedMenuItem NetAdminMenu Nessus "nessus"  "%menu/nessus.png%"
CheckedMenuItem NetAdminMenu "NMAP Frontend" "nmapfe"  "%menu/nmapfe.png%"
CheckedMenuItem NetAdminMenu "Kovpn configuration Wizard" "kovpnsetup"  "%menu/kovpn.png%"
CheckedMenuItem NetAdminMenu Kovpn "kovpn"  "%menu/kovpn.png%"
CheckedMenuItem NetAdminMenu KVpnc "kvpnc"  "%menu/kvpnc.png%"
CheckedMenuItem NetAdminMenu krfb "krfb"  "%menu/krfb.png%"
CheckedMenuItem NetAdminMenu krdc "krdc"  "%menu/krdc.png%"
CheckedMenuItem NetAdminMenu KNetAttach "knetattach"  "%menu/knetattach.png%"
CheckedXTermMenuItem NetAdminMenu Kismet kismet

#####
# Net Menu
##########
AddToMenu NetMenu "Internet" Title
AddMenuItem "Browsers%menu/konqueror.png%"	Popup BrowserMenu
AddMenuItem "Mail and News%menu/email.png%"		Popup MailMenu
AddMenuItem "Filesharing%menu/DLFileShare.png%"	Popup FilesharingMenu
AddMenuItem "Chat%menu/irc.png%"			Popup ChatMenu
AddMenuItem "Network Administration%menu/irc.png%" Popup NetAdminMenu
CheckedMenuItem NetMenu "D4X" d4x "%menu/d4x.png%"


#####
# Development Menu
#################################################################################

AddToMenu IDEMenu "IDEs" Title
CheckedMenuItem IDEMenu "KDevelop"      kdevelop "%menu/kdevelop.png%"
CheckedMenuItem IDEMenu "Eclipse"       eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu "Eclipse 3.6"   ~/Desktop/eclipse-3.6/eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu "Eclipse 3.6 PHP" ~/Desktop/eclipse-php-3.6/eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu "Eclipse 3.5 PHP" ~/Desktop/eclipse-php/eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu "Eclipse 3.5 CDT" ~/Desktop/eclipse+cdt-3.5/eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu "Eclipse 3.4 CDT" ~/Desktop/eclipse+cdt-3.4/eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu "Eclipse 3.4"   ~/Desktop/eclipse/eclipse "%menu/eclipse.png%"
CheckedMenuItem IDEMenu PhpStorm        phpstorm.sh "%menu/phpstorm.png%"
CheckedMenuItem IDEMenu "IntelliJ IDEA" /opt/intellij-idea/bin/idea.sh "%menu/intellij-idea.png%"
CheckedMenuItem IDEMenu NetBeans        netbeans "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 7.4"  /opt/netbeans-7.4/bin/netbeans "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 7.3"  /opt/netbeans-7.3/bin/netbeans "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 7.2"  /opt/netbeans-7.2/bin/netbeans "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 7.1"  /opt/netbeans-7.1/bin/netbeans "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 7.0"  /opt/netbeans-7.0/bin/netbeans "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 6.9"  netbeans-6.8 "%menu/netbeans.png%"
#CheckedMenuItem IDEMenu "NetBeans 6.8"  netbeans-6.8 "%menu/netbeans.png%"
CheckedMenuItem IDEMenu "QDevelop"      qdevelop "%menu/kdevelop.png%"
CheckedMenuItem IDEMenu "Groovy Console" groovyConsole "%menu/.png%"
CheckedMenuItem IDEMenu Forte4Java      "runide -jdkhome /usr/local/j2sdk1.3"
CheckedMenuItem IDEMenu Anjuta          anjuta "%menu/anjuta.png%"
CheckedMenuItem IDEMenu "Code::Blocks"  codeblocks "%menu/codeblocks.png%"
CheckedMenuItem IDEMenu PyCharm         pycharm.sh "%menu/pycharm.png%"
CheckedMenuItem IDEMenu Geany         	geany "%menu/geany-icon.png%"
CheckedMenuItem IDEMenu CLion         	/opt/clion/bin/clion.sh "%menu/geany-icon.png%"

AddToMenu UMLMenu "UML" Title
CheckedMenuItem UMLMenu Umbrello umbrello "%menu/umbrello.png%"
CheckedMenuItem UMLMenu BoUML bouml "%menu/umbrello.png%"
CheckedMenuItem UMLMenu Together "Together.sh"
CheckedMenuItem UMLMenu PoseidonUML /opt/PoseidonForUML_CE_1.5.1/bin/startPoseidon.sh

AddToMenu GUIMenu "GUI Design" Title
CheckedMenuItem GUIMenu QTDesigner designer "%menu/designer.png%"
CheckedMenuItem GUIMenu Glade glade "%menu/glade.png%"
CheckedMenuItem GUIMenu QtArchitect qtarch
CheckedMenuItem GUIMenu KFormDesigner kformdesigner  "%menu/.png%"
CheckedMenuItem GUIMenu SpecTcl specTcl

AddToMenu DbgMenu "Debugging" Title
CheckedMenuItem DbgMenu DDD "ddd" "%menu/xroach.png%"
CheckedMenuItem DbgMenu KDBG "kdbg" "%menu/xroach.png%"

AddToMenu DBMenu "Databases" Title
CheckedMenuItem DBMenu "MySQL Workbench" "mysql-workbench" "%menu/MySQLWorkbench-24.png%"
CheckedMenuItem DBMenu "MySQL administrator" "mysql-administrator" "%menu/MySQLAdmin.png%"
CheckedMenuItem DBMenu "MySQL Query Browser" "mysql-query-browser" "%menu/MySQLQueryBrowser.png%"
CheckedMenuItem DBMenu "pgAdmin III" "pgadmin3" "%menu/pgadmin3.png%"

AddToMenu WebdevMenu "Web Development" Title
CheckedMenuItem WebdevMenu Quanta "quanta" "%menu/quanta.png%"
CheckedMenuItem WebdevMenu NVU "nvu"  "%menu/nvu.png%"

AddToMenu VCMenu "Version Control" Title
CheckedMenuItem VCMenu "KDESvn"	  kdesvn "%menu/kdesvn.png%"
CheckedMenuItem VCMenu "eSvn"	  esvn "%menu/esvn_folder.png%"
CheckedMenuItem VCMenu "RapidSVN" rapidsvn "%menu/kdesvn.png%"
CheckedMenuItem VCMenu "cervisia" cervisia "%menu/cervisia.png%"

AddToMenu   DevMenu "Development" Title
AddMenuItem "IDEs%menu/windows.xpm%"      	Popup IDEMenu
AddMenuItem "UML%menu/flowchart.png%"      	Popup UMLMenu
AddMenuItem "GUI Design%menu/.png%"		Popup GUIMenu
AddMenuItem "Debugging%menu/xroach.png%"		Popup DbgMenu
AddMenuItem "Databases%menu/database.png%"	Popup DBMenu
AddMenuItem "Web Development%menu/html.png%"	Popup WebdevMenu
AddMenuItem "Version Control%menu/kdesvn.png%"	Popup VCMenu
CheckedMenuItem DevMenu SourceNavigator /opt/snavigator/bin/snavigator
CheckedMenuItem DevMenu KDiff3          kdiff3  "%menu/kdiff3.png%"
CheckedMenuItem DevMenu Kompare          kompare  "%menu/kompare.png%"
CheckedMenuItem DevMenu "BeanShell Console" bsh-console  "%menu/beanshell.png%"
CheckedMenuItem DevMenu "kregexpeditor" kregexpeditor "%menu/kregexpeditor.png%"
CheckedMenuItem DevMenu "KBabel" kbabel "%menu/kbabel.png%"


#####
# Science Menu
#################################################################################
AddToMenu SciMenu "Science" Title
CheckedMenuItem SciMenu "Celestia"      celestia "%menu/celestia.png%"
CheckedMenuItem SciMenu "OpenUniverse"  openuniverse "%menu/openuniverse.png%"
CheckedMenuItem SciMenu "KStars"      	kstars "%menu/kstars_planets.png%"
CheckedMenuItem SciMenu "Stellarium"    stellarium "%menu/stellarium.png%"
CheckedMenuItem SciMenu "Google Earth"  googleearth "%menu/googleearth.png%"
CheckedMenuItem SciMenu "Marble"  	marble "%menu/marble.png%"
CheckedMenuItem SciMenu "kOctave"       koctave3 "%menu/koctave3.png%"
CheckedMenuItem SciMenu "QtOctave"      qtoctave "%menu/qtoctave.png%"
CheckedMenuItem SciMenu "Cantor"        cantor "%menu/cantor.png%"
CheckedMenuItem SciMenu "RKWard"        rkward "%menu/rkward.png%"
CheckedMenuItem SciMenu "wxMaxima"      wxmaxima "%menu/wxmaxima.png%"
CheckedXTermMenuItem SciMenu "Singular" Singular
CheckedMenuItem SciMenu "VMD"           vmd
CheckedMenuItem SciMenu "kpl"           kpl "%menu/kpl.png%"
CheckedMenuItem SciMenu "VTk"           vtk
CheckedMenuItem SciMenu "Surf"          surf
CheckedMenuItem SciMenu "Geomview"      geomview
CheckedMenuItem SciMenu "Light Speed!"  lightspeed
CheckedMenuItem SciMenu "Sphere Eversion" sphereEversion
CheckedMenuItem SciMenu "XEphem"        xephem
CheckedMenuItem SciMenu "Nightfall"     "nightfall -U  0.8 85 0.8 1.0 5500 5800" "%menu/nightfall.png%"


#####
# Office Menu
#################################################################################

#####
# OOO Modules Menu
##################
AddToMenu   OOOModMenu "OpenOffice Modules" Title
CheckedMenuItem OOOModMenu "OOBase"      oobase "%menu/ooo_gulls.png%"
CheckedMenuItem OOOModMenu "OOCalc"      oocalc "%menu/ooo_gulls.png%"
CheckedMenuItem OOOModMenu "OODraw"      oodraw "%menu/ooo_gulls.png%"
CheckedMenuItem OOOModMenu "OOImpress"   ooimpress "%menu/ooo_gulls.png%"
CheckedMenuItem OOOModMenu "OOMath"      oomath "%menu/ooo_gulls.png%"
CheckedMenuItem OOOModMenu "OOPAdmin"    oopadmin "%menu/ooo_gulls.png%"
CheckedMenuItem OOOModMenu "OOWriter"    oowriter "%menu/ooo_gulls.png%"

#####
# KOffice Modules Menu
######################
AddToMenu   KOModMenu "KOffice Modules" Title
CheckedMenuItem KOModMenu "Karbon (Vector Drawing)"          karbon "%menu/karbon.png%"
CheckedMenuItem KOModMenu "KWord (Word Processing)"          kword "%menu/kword.png%"
CheckedMenuItem KOModMenu "Kivio (Flowchart + Diagram)"      kivio "%menu/kivio.png%"
CheckedMenuItem KOModMenu "KPresenter (Slide Presentations)" kpresenter "%menu/kpresenter.png%"
CheckedMenuItem KOModMenu "Krita (Image Editing)"            krita "%menu/krita.png%"
CheckedMenuItem KOModMenu "Kugar (Report Designer)"          kugar "%menu/kugar.png%"
CheckedMenuItem KOModMenu "KChart (Data Visualization)"      kchart "%menu/kchart.png%"
CheckedMenuItem KOModMenu "KFormula (Formula Layout)"        kformula "%menu/kformula.png%"
CheckedMenuItem KOModMenu "KPlato (Project Management)"      kplato "%menu/kplato.png%"
CheckedMenuItem KOModMenu "KSpread (Spreadsheets)"           kspread "%menu/kspread.png%"
CheckedMenuItem KOModMenu "Kexi (Databases)"                 kexi "%menu/kexi.png%"

#####
# PIM Menu
######################
AddToMenu   PIMMenu "Personal Information Management" Title
CheckedMenuItem PIMMenu "KOrganizer" korganizer "%menu/korganizer.png%"
CheckedMenuItem PIMMenu "ksync"      ksync "%menu/ksync.png%"
CheckedMenuItem PIMMenu "Kandy"      kandy "%menu/kandy.png%"
CheckedMenuItem PIMMenu "Kolab Configuration Wizard" kolabwizard "%menu/.png%"
CheckedMenuItem PIMMenu "KDE Groupware Wizard" groupwarewizard "%menu/.png%"
CheckedMenuItem PIMMenu "Kontact" kontact "%menu/kontact.png%"
CheckedMenuItem PIMMenu "KitchenSync" kitchensync "%menu/kitchensync.png%"
CheckedMenuItem PIMMenu "KAddressBook" kaddressbook "%menu/kaddressbook.png%"

#####
# Office Menu
#############
AddToMenu   OfficeMenu "Office" Title
# there are numerous names under which openoffice is known...
CheckedMenuItem OfficeMenu "LibreOffice" soffice "%menu/libre_office.png%"
CheckedMenuItem OfficeMenu "OpenOffice" ooffice "%menu/ooo_gulls.png%"
CheckedMenuItem OfficeMenu "OpenOffice" ooffice2 "%menu/ooo_gulls.png%"
CheckedMenuItem OfficeMenu "OpenOffice" openoffice.org "%menu/ooo_gulls.png%"
AddMenuItem "OpenOffice Modules%menu/ooo_gulls.png%"	Popup OOOModMenu
CheckedMenuItem OfficeMenu "KOffice"    koshell "%menu/koffice_2.png%"
AddMenuItem "KOffice Modules%menu/koffice_2.png%" Popup KOModMenu
AddMenuItem "PIM%menu/kontact.png%"               Popup PIMMenu
CheckedMenuItem OfficeMenu "KMyMoney"   kmymoney "%menu/okular.png%"
CheckedMenuItem OfficeMenu "Okular"     okular "%menu/okular.png%"
CheckedMenuItem OfficeMenu "Calibre"    calibre "%menu/okular.png%"
CheckedMenuItem OfficeMenu "FBReader"   fbreader "%menu/.png%"
CheckedMenuItem OfficeMenu "FreeMind"   freemind "%menu/Freemind-and.png%"
CheckedMenuItem OfficeMenu "KJots"      kjots "%menu/kjots.png%"
CheckedMenuItem OfficeMenu "KNotes"     knotes "%menu/knotes.png%"
CheckedMenuItem OfficeMenu "AbiWord"    abiword "%menu/abiword.png%"
CheckedMenuItem OfficeMenu "gtk-ocr"    gtk-ocr "%menu/.png%"


#####
# Gfx Menu
#################################################################################

#####
# View Menu
###########
AddToMenu   ViewMenu "Image Viewers" Title
CheckedMenuItem ViewMenu "XV" xv "%menu/xv.png%"
CheckedMenuItem ViewMenu "Display" display "%menu/imagemagick.png%"
CheckedMenuItem ViewMenu "Gwenview" gwenview "%menu/gwenview.png%"
CheckedMenuItem ViewMenu "KuickShow" kuickshow "%menu/kuickshow.png%"
CheckedMenuItem ViewMenu "KView" kview "%menu/kview.png%"
CheckedMenuItem ViewMenu "EOG" eog "%menu/gnome-eog.png%"

#####
# Image Editing Menu
####################
AddToMenu   ImgEditMenu "Image Editing" Title
CheckedMenuItem ImgEditMenu "The GIMP" "gimp" "%menu/gimp.png%"
CheckedMenuItem ImgEditMenu "KIconEdit" kiconedit "%menu/kiconedit.png%"
CheckedMenuItem ImgEditMenu "Karbon"     karbon "%menu/karbon.png%"
CheckedMenuItem ImgEditMenu "Krita"      krita "%menu/krita.png%"

#####
# 3D Menu
#########
AddToMenu   3DMenu "3D and Fractals" Title
CheckedMenuItem 3DMenu KPOVModeler kpovmodeler
CheckedMenuItem 3DMenu  K3D "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/k3d-0.2.0/libs/ k3d --basepath /opt/k3d-0.2.0"
CheckedMenuItem 3DMenu KPOV "kpov"
CheckedMenuItem 3DMenu Blender "blender"
CheckedMenuItem 3DMenu XaoS "xaos"
CheckedMenuItem 3DMenu Quat "quat"
CheckedMenuItem 3DMenu Fraqtive "fraqtive"
CheckedMenuItem 3DMenu KMandel "kmandel"
CheckedMenuItem 3DMenu KFract "kfract"
CheckedMenuItem 3DMenu XFractint "xfractint"
CheckedMenuItem 3DMenu Mountains "xmountains"
CheckedMenuItem 3DMenu Terraform "terraform"

#####
# Animation Menu
################
AddToMenu AnimationMenu "Animation" Title
CheckedMenuItem AnimationMenu GMPlayer gmplayer "%menu/mplayer.png%"
CheckedMenuItem AnimationMenu RealPlayer realplay "%menu/realplayer.png%"
CheckedMenuItem AnimationMenu aKtion "aktion"
CheckedMenuItem AnimationMenu "AVI Play" "aviplay"
CheckedMenuItem AnimationMenu MPEG "mtv"
CheckedMenuItem AnimationMenu MPEGPlayer "mpeg_play"
CheckedMenuItem AnimationMenu Animate "animate"  "%menu/imagemagick.png%"
CheckedMenuItem AnimationMenu XMPS "xmps"
CheckedMenuItem AnimationMenu gtv "gtv"
CheckedMenuItem AnimationMenu XMovie "xmovie"
CheckedMenuItem AnimationMenu XAnim "xanim"
CheckedMenuItem AnimationMenu XTheater "xtheater"
CheckedMenuItem AnimationMenu QRecompress "qtrecompress"
CheckedMenuItem AnimationMenu MainActorVideoEditor "/opt/MainActor/mave"
CheckedMenuItem AnimationMenu "Dragon Player" dragon "%menu/dragonplayer.png%"
CheckedMenuItem AnimationMenu "Totem" totem "%menu/totem.png%"

#####
# Gfx Menu
##########
AddToMenu   GfxMenu "Graphics" Title
AddMenuItem "Image Viewers%menu/gnome-eog.png%"	Popup ViewMenu
AddMenuItem "Image Editing%menu/krita.png%"	Popup ImgEditMenu
AddMenuItem "3D, Fractals%menu/lsphere.png%"	Popup 3DMenu
AddMenuItem "Animation%menu/film.png%"		Popup AnimationMenu
CheckedMenuItem GfxMenu "KSnapshot" ksnapshot "%menu/ksnapshot.png%"


#####
# Sound Menu
#################################################################################

#####
# Audio Player Menu
###################
AddToMenu PlayerMenu "Audio Playback" Title
CheckedMenuItem PlayerMenu "Xmms" xmms "%menu/xmms.png%"
CheckedMenuItem PlayerMenu "Audacious" audacious "%menu/audacious.png%"
CheckedMenuItem PlayerMenu "Audacious 2" audacious2 "%menu/audacious.png%"
CheckedMenuItem PlayerMenu "Mixxx" mixxx "%menu/mixxx-icon.png%"
CheckedMenuItem PlayerMenu "Clementine" clementine "%menu/clementine.png%"
CheckedMenuItem PlayerMenu "AmaroK" amarok "%menu/amarok.png%"
CheckedMenuItem PlayerMenu "Banshee" banshee "%menu/media-player-banshee.png%"
CheckedMenuItem PlayerMenu "GMPC" gmpc "%menu/gmpc.png%"
CheckedMenuItem PlayerMenu "Last.FM Player" lastfm "%menu/lastfm.png%"
CheckedMenuItem PlayerMenu "Rhythmbox" rhythmbox "%menu/rhythmbox.png%"
CheckedMenuItem PlayerMenu "KsCD" kscd "%menu/kscd.png%"
CheckedMenuItem PlayerMenu "JuK" juk "%menu/juk.png%"
CheckedMenuItem PlayerMenu "Dragon Player" dragon "%menu/dragonplayer.png%"
CheckedMenuItem PlayerMenu "Gnaural" gnaural 

#####
# CD Writing Menu
#################
AddToMenu CDWrMenu "CD Writing" Title
CheckedMenuItem CDWrMenu K3B "k3b" "%menu/k3b.png%"
CheckedMenuItem CDWrMenu CDBakeoven "cdbakeoven"
CheckedMenuItem CDWrMenu kreatecd "kreatecd"
CheckedMenuItem CDWrMenu "KISOCD" "kisocd"
CheckedMenuItem CDWrMenu KOnCD "koncd"
CheckedMenuItem CDWrMenu CDWriter "kcdwrite"
CheckedMenuItem CDWrMenu KEasyCD "keasycd"

#####
# CD Ripping Menu
#################
AddToMenu GrabMenu "CD Ripping" Title
CheckedMenuItem GrabMenu K3B k3b "%menu/k3b.png%"
CheckedMenuItem GrabMenu KAudioCreator kaudiocreator "%menu/kaudiocreator.png%"
CheckedMenuItem GrabMenu MP3Maker "mp3maker"
CheckedMenuItem GrabMenu Krabber "krabber"
CheckedMenuItem GrabMenu Grip "grip"

#####
# Mixer Menu
############
AddToMenu MixMenu Mixer Title
CheckedMenuItem MixMenu KMix "kmix" "%menu/kmix.png%"
CheckedMenuItem MixMenu AuMix "aumix" "%menu/ico.png%"
CheckedMenuItem MixMenu Xmixer "xmixer"
CheckedMenuItem MixMenu "Pulse Audio Volume Control" pavucontrol "%menu/multimedia-volume-control.png%"
CheckedMenuItem MixMenu "Pulse Audio Equalizer" pulseaudio-equalizer-gtk "%menu/multimedia-volume-control.png%"

#####
# Recording Menu
################
AddToMenu EditMenu "Recording + Editing" Title
CheckedMenuItem EditMenu Audacity "audacity" "%menu/audacity.png%"
CheckedMenuItem EditMenu EasyTag easytag  "%menu/easytag.png%"
CheckedMenuItem EditMenu KID3 kid3 "%menu/kid3.png%"
CheckedMenuItem EditMenu Picard picard "%menu/picard.png%"
CheckedMenuItem EditMenu SLab "slab"
CheckedMenuItem EditMenu snd "snd"
CheckedMenuItem EditMenu KRec "krec" "%menu/krec.png%"
CheckedMenuItem EditMenu KRecord "krecord" "%menu/gnome-media-player.png%"
CheckedMenuItem EditMenu KHarddiskRecorder "khdrec"
CheckedXTermMenuItem EditMenu GramoFileRecorder gramofile
CheckedMenuItem EditMenu KSoundSys "ksoundsys"
CheckedMenuItem EditMenu KModBox "kmodbox"
CheckedMenuItem EditMenu Thud "thud"
CheckedMenuItem EditMenu KMid "kmid" "%menu/kmid.png%"
CheckedMenuItem EditMenu "Ardour" ardour "%menu/audacity.png%"
CheckedMenuItem EditMenu "Ardour" ardour2 "%menu/ardour.png%"
CheckedMenuItem EditMenu "TagTool" tagtool "%menu/tagtool.png%"

#####
# Sound Menu
############
AddToMenu SoundMenu "Sound" Title
AddToMenu SoundMenu MissingSubmenuFunction FuncFvwmMenuDirectory
#AddMenuItem "All Music%menu/gnome-searchtool.png%"	Popup /home/scenes/Music
#AddMenuItem "" 					Nop
AddMenuItem "Playback%menu/noatun.png%"		Popup PlayerMenu
AddMenuItem "CD Ripping%menu/rip.png%"		Popup GrabMenu
AddMenuItem "CD Writing%menu/xcdroast.png%"	Popup CDWrMenu
AddMenuItem "Mixer%menu/kmix.png%"		Popup MixMenu
AddMenuItem "Editing%menu/gnome-media-player.png%" Popup EditMenu



#####
# Games Menu
#################################################################################

#####
# Network Go Menu
#################
AddToMenu NetGoMenu            "Network Go" Title
CheckedMenuItem NetGoMenu XGospel xgospel "%menu/cgoban.png%"
CheckedMenuItem NetGoMenu QIGC qigc "%menu/cgoban.png%"
CheckedMenuItem NetGoMenu XIGC xigc "%menu/cgoban.png%"
CheckedMenuItem NetGoMenu CGoBan cgoban "%menu/cgoban.png%"
CheckedMenuItem NetGoMenu Baduki baduki "%menu/cgoban.png%"
CheckedMenuItem NetGoMenu KGo kgo "%menu/cgoban.png%"
CheckedMenuItem NetGoMenu GTKGo gtkgo "%menu/cgoban.png%"
CheckedXTermMenuItem NetGoMenu GnuGo "gnugo"

#####
# Chess Menu
############
AddToMenu ChessMenu          Chess Title
CheckedMenuItem ChessMenu Knights knights "%menu/games_board.png%"
CheckedMenuItem ChessMenu GNUChess xboard "%menu/games_board.png%"
CheckedMenuItem ChessMenu GLChess glchess "%menu/games_board.png%"
CheckedMenuItem ChessMenu Crafty xcrafty "%menu/games_board.png%"
CheckedMenuItem ChessMenu 3DChess 3Dc "%menu/games_board.png%"

#####
# Go & Chess Menu
#################
AddToMenu GoMenu          "Go + Chess" Title
AddMenuItem "Network Go%menu/cgoban.png%"		Popup NetGoMenu
AddMenuItem "Chess%menu/games_board.png%"		Popup ChessMenu
CheckedMenuItem GoMenu "Go³ Server" "$[HOME]/workspace/go-3 SVN/bin/Go3DServer.sh"
CheckedMenuItem GoMenu "Go³ Client" "$[HOME]/workspace/go-3 SVN/bin/Go3DClient.sh"
CheckedMenuItem GoMenu Jago jago "%menu/cgoban.png%"

#####
# Games Menu
############
AddToMenu GamesMenu      "Games + Schnokus" Title
AddMenuItem "Go + Chess%menu/cgoban.png%"		Popup GoMenu
CheckedMenuItem GamesMenu Jugglemaster "jmdlx"
CheckedMenuItem GamesMenu FreeCiv freeciv "%menu/freeciv.png%"
CheckedMenuItem GamesMenu FreeCol freecol "%menu/Colony0.png%"
CheckedMenuItem GamesMenu Wesnoth wesnoth "%menu/wesnoth.png%"
CheckedMenuItem GamesMenu "World of Warcraft" "wine /home/scenes/World\ of\ Warcraft/Wow.exe -opengl" "%menu/WoW.png%"
CheckedMenuItem GamesMenu XShipWars xsw
CheckedMenuItem GamesMenu Konquest konquest
CheckedMenuItem GamesMenu Craft craft
CheckedMenuItem GamesMenu LinCity xlincity
CheckedMenuItem GamesMenu Battalion battalion
CheckedMenuItem GamesMenu NetMaze netmaze
CheckedMenuItem GamesMenu 3DTetris xbl
CheckedMenuItem GamesMenu Singularity singularity


#####
# Utilities Menu
#################################################################################

#####
# Notes Menu
############
AddToMenu NotesMenu "Taking Notes" Title
CheckedMenuItem NotesMenu "KNotes" knotes "%menu/knotes.png%"
CheckedMenuItem NotesMenu "KJots" kjots "%menu/kjots.png%"
CheckedMenuItem NotesMenu "E-Notes" E-Notes "%menu/E-Notes.png%"

#####
# Security Menu
################
AddToMenu SecMenu "Security" Title
CheckedMenuItem SecMenu "KWatchGnuPG" kwatchgnupg "%menu/kwatchgnupg.png%"
CheckedMenuItem SecMenu "Kleopatra" kleopatra "%menu/kwatchgnupg.png%"

#####
# Info Menu
###########
AddToMenu InfoMenu "(System) Information" Title
CheckedMenuItem InfoMenu "kpm" kpm "%menu/ksysguard.png%"
CheckedMenuItem InfoMenu "KSysGuard" ksysguard "%menu/ksysguard.png%"
CheckedMenuItem InfoMenu "KRuler" kruler "%menu/kruler.png%"
CheckedMenuItem InfoMenu "KInfoCenter" kinfocenter "%menu/kinfocenter.png%"
CheckedMenuItem InfoMenu "KHelpCenter" khelpcenter "%menu/khelpcenter.png%"
CheckedMenuItem InfoMenu "KFind" kfind "%menu/kfind.png%"
CheckedMenuItem InfoMenu "KDiskFree" kdf "%menu/kdf.png%"
CheckedMenuItem InfoMenu "DCOP Browser" kdcop "%menu/.png%"

#####
# Time Menu
###########
AddToMenu TimeMenu "Time + Timing" Title
CheckedMenuItem TimeMenu "KArm" karm "%menu/karm.png%"
CheckedMenuItem TimeMenu "KTimeTracker" ktimetracker "%menu/ktimetracker.png%"
CheckedMenuItem TimeMenu "GnoTime" gnotime "%menu/karm.png%"
CheckedMenuItem TimeMenu "taskCoach" taskcoach "%menu/taskcoach.png%"
CheckedMenuItem TimeMenu "KAlarm" kalarm "%menu/kalarm.png%"
CheckedMenuItem TimeMenu "KTimer" ktimer "%menu/ktimer.png%"
CheckedMenuItem TimeMenu "XFCE Calendar" xfcalendar "%menu/office-calendar.png%"
CheckedMenuItem TimeMenu "KCron" kcron "%menu/kcron.png%"

#####
# Typing Menu
#############
AddToMenu TypeMenu "Typing" Title
CheckedMenuItem TypeMenu "KTouch" ktouch "%menu/typewriter.png%"
CheckedXTermMenuItem TypeMenu "GTypist" gtypist

#####
# Words Menu
############
AddToMenu WordsMenu "Words" Title
CheckedMenuItem WordsMenu "KThesaurus" kthesaurus "%menu/book.png%"
CheckedMenuItem WordsMenu "KDict" kdict "%menu/kdict.png%"

#####
# Utilities Menu
################
AddToMenu UtilMenu "Utilities" Title
AddMenuItem "Taking Notes%menu/E-Notes.png%"	Popup NotesMenu
AddMenuItem "Security%menu/kgpg.png%"		Popup SecMenu
AddMenuItem "(System) Information%menu/info.png%"	Popup InfoMenu
+ "Time + Timing%menu/ktimer.png%"	Popup TimeMenu
AddMenuItem "Typing%menu/typewriter.png%" 	Popup TypeMenu
AddMenuItem "Words%menu/book.png%"        	Popup WordsMenu
CheckedMenuItem UtilMenu "KCalc" kcalc "%menu/calculator.png%"
CheckedMenuItem UtilMenu "galculator" galculator "%menu/galculator.png%"
CheckedMenuItem UtilMenu "Qalculate!" qalculate-kde "%menu/qalculate_kde.png%"
CheckedMenuItem UtilMenu "K3B" k3b "%menu/k3b.png%"
CheckedMenuItem UtilMenu "PortageMaster" portagemaster "%menu/gentoo.png%"
CheckedMenuItem UtilMenu "Kicker" kicker "%menu/kcmkicker.png%"
CheckedMenuItem UtilMenu "KCharSelect" kcharselect "%menu/kcharselect.png%"
CheckedMenuItem UtilMenu "KBoincSpy" kboincspy "%menu/kboincspy.png%"
CheckedMenuItem UtilMenu "kasbar" kasbar "%menu/.png%"
CheckedMenuItem UtilMenu "ark" ark "%menu/ark.png%"
CheckedMenuItem UtilMenu "KFileReplace" kfilereplace "%menu/kfilereplace.png%"
CheckedMenuItem UtilMenu "KImageMapEditor" kimagemapeditor "%menu/kimagemapeditor.png%"
CheckedMenuItem UtilMenu "KLinkStatus" klinkstatus "%menu/klinkstatus.png%"
CheckedMenuItem UtilMenu "KXSLDbg" kxsldbg "%menu/kxsldbg.png%"
CheckedMenuItem UtilMenu "Workrave" workrave "%menu/.png%"
CheckedMenuItem UtilMenu "Standalone Tray" "stalonetray -geometry 10x1-0-0" "%menu/.png%"


#####
# Programs Menu
#################################################################################

AddToMenu   FvwmProgramsMenu "Programs" Title
AddMenuItem "Editors%menu/kate.png%"	 	Popup EditorMenu
AddMenuItem "Net%menu/konqueror.png%"		Popup NetMenu
AddMenuItem "Development%menu/kdevelop.png%"	Popup DevMenu
AddMenuItem "Science%menu/konquest.png%"		Popup SciMenu
AddMenuItem "Office%menu/koffice.png%"		Popup OfficeMenu
AddMenuItem "Graphics%menu/paint.png%"		Popup GfxMenu
AddMenuItem "Sound%menu/notes.png%"		Popup SoundMenu
AddMenuItem "Games%menu/games.png%"		Popup GamesMenu
AddMenuItem "Utilities%menu/calculator.png%"	Popup UtilMenu


#################################################################################
# Appearance Menu
#################################################################################

#####
# Background Menu
#################################################################################

#####
# Planets Menu
##############
DestroyMenu PlanetsMenu
AddToMenu PlanetsMenu "Planets" Title
AddMenuItem "Stop Animation%menu/window-delete.xpm%"		Exec exec killall xplanet
MakePlanetsMenu

#####
# Background Menu
#################
AddToMenu BackMenu        Background Title
AddMenuItem "Planets%menu/celestia.png%"	Popup PlanetsMenu
CheckedMenuItem BackMenu Penguins xpenguins
CheckedMenuItem BackMenu Daemon "oneko -bsd_daemon" "%menu/beastie.png%"
CheckedMenuItem BackMenu Tiger "oneko -tora" "%menu/oneko.png%"
CheckedMenuItem BackMenu Cat oneko "%menu/oneko.png%"
CheckedMenuItem BackMenu Dog "oneko -dog" "%menu/oneko.png%"
AddMenuItem "Stop it!%menu/window-delete.xpm" Exec exec killall oneko
CheckedMenuItem BackMenu GasSimulation xgas
CheckedMenuItem BackMenu XBall xball
CheckedMenuItem BackMenu Springies xspringies


#####
# Eyes Menu
#################################################################################
AddToMenu EyesMenu "Eyes..." Title
CheckedMenuItem EyesMenu Teddy xteddy "%menu/xteddy.png%"
CheckedMenuItem EyesMenu Tux "tuXeyes --tux"
CheckedMenuItem EyesMenu Chuck "tuXeyes --chuck"
CheckedMenuItem EyesMenu Luxus "tuXeyes --luxus"
CheckedMenuItem EyesMenu Dustpuppy "tuXeyes --puppy"
CheckedMenuItem EyesMenu Penguin  penguineyes
CheckedMenuItem EyesMenu GLEyes gleyes


#####
# Appearance Menu
#################################################################################

AddToMenu AppearMenu "Appearance"  Title
AddMenuItem "Background%menu/gnome-settings-background.png%"	Popup BackMenu
AddMenuItem "Eyes%menu/xeyes.png%"				Popup EyesMenu
CheckedMenuItem AppearMenu "Configure Screensaver" xscreensaver-demo "%menu/screensaver.png%"


#################################################################################
# Configuration Menu
#################################################################################


#####
# fvwm Window Operation Menu
############################
AddToMenu   FvwmWindowOpsMenu "Window Operations" Title
AddMenuItem "Move%menu/window-move.xpm%"  Move
AddMenuItem "Resize%menu/window-resize.xpm%"  Resize
AddMenuItem "(De)Iconify%menu/window-iconify.xpm%"  Iconify
AddMenuItem "(Un)Maximize%menu/window-maximize.xpm%"  Maximize
AddMenuItem "(Un)Shade%menu/window-shade.xpm%"  WindowShade
AddMenuItem "(Un)Stick%menu/window-stick.xpm%"  Stick
AddMenuItem "" Nop
AddMenuItem "Close%menu/window-close.xpm%"  Close
AddMenuItem "Delete%menu/window-delete.xpm%"  Delete
AddMenuItem "Destroy%menu/window-destroy.xpm%"  Destroy
AddMenuItem "" Nop
AddMenuItem "StaysOnTop%menu/window-raise.xpm%"  Pick (CirculateHit) Layer 0 6
AddMenuItem "Layer +1%menu/window-raise.xpm%"  Pick (CirculateHit) Layer +1
AddMenuItem "StaysPut%menu/window.xpm%"  Pick (CirculateHit) Layer 0 4
AddMenuItem "Layer -1%menu/window-lower.xpm%"  Pick (CirculateHit) Layer -1
AddMenuItem "StaysOnBottom%menu/window-lower.xpm%"  Pick (CirculateHit) Layer 0 2
AddMenuItem "" Nop
AddMenuItem "%menu/window.xpm%Window Screenshot"  Pick (CirculateHit) FvwmWindowScreenshot
AddMenuItem "%menu/display.xpm%Screenshot" FvwmDesktopScreenshot 1
AddMenuItem "" Nop
AddMenuItem "Identify%menu/window-identify.xpm%"  Module FvwmIdent

#####
# FVWM Menu
###########
AddToMenu   FVWMMenu "FVWM" Title
AddMenuItem "Modules"		Popup ModulesMenu
AddMenuItem "Help%menu/help.png%" Popup FvwmManPagesMenu
AddMenuItem "FvwmRoot"		Popup MenuFvwmRoot
AddMenuItem "Window Ops"		Popup FvwmWindowOpsMenu

#####
# Configuration Menu
#################################################################################
AddToMenu	ConfigMenu	"Configuration" 	Title
AddMenuItem 		"FVWM%menu/fvwm.png%"			Popup FVWMMenu
CheckedMenuItem	ConfigMenu 	"KDE ControlCenter"	kcontrol "%menu/background.png%"
CheckedMenuItem ConfigMenu      "Edit KDE Menus"        kmenuedit "%menu/kmenuedit.png%"
CheckedMenuItem	ConfigMenu 	"GNOME Configuration"	gconf-editor "%menu/gnome-desktop-config.png%"
CheckedMenuItem ConfigMenu	"WindowMaker"		wmakerconf "%menu/windowmaker2.png%"
CheckedMenuItem ConfigMenu	"nVidia Settings"	nvidia-settings "%menu/nVidia.png%"

#################################################################################
# Quit Menu
#################################################################################
AddToMenu   QuitMenu "Exit FVWM?" Title
AddMenuItem "Restart FVWM%menu/restart.png%"  Restart
AddMenuItem "WindowManagers%menu/GNUstepGlow.xpm%"	Popup WindowManagerMenu
CheckedMenuItem QuitMenu "Start KDE 3" startkde "%menu/kde.xpm%"
CheckedMenuItem QuitMenu "Start GNOME 2.2" gnome-session "%menu/gnome.xpm%"
AddMenuItem ""						Nop
CheckedSudoMenuItem QuitMenu "Sleep%menu/sleep.png%" zzz
CheckedSudoMenuItem QuitMenu "Hibernate%menu/sleep.png%" hibernate
CheckedSudoMenuItem QuitMenu "Shut down%menu/sleep.png%" halt
CheckedSudoMenuItem QuitMenu "Reboot%menu/sleep.png%"	 reboot
AddMenuItem "Quit Session%menu/quit.png%"			Quit

#################################################################################
# FvwmRootMenu
#################################################################################

AddToMenu	FvwmRootMenu 				"Root Menu" Title
AddMenuItem "Terminals%menu/terminal.png%"  			Popup TermsMenu
AddMenuItem "File Managers%menu/gnome-searchtool.png%"		Popup FileMgrMenu
AddMenuItem "Programs%menu/programs.png%"  			Popup FvwmProgramsMenu
AddMenuItem "" Nop
AddMenuItem "Appearance%menu/config-xfree.png%"			Popup AppearMenu
AddMenuItem "Configuration%menu/gnome-settings.png%"		Popup ConfigMenu
AddMenuItem "" Nop
AddMenuItem "Lock Screen%menu/gnome-lockscreen.png%"		Exec exec xscreensaver-command -lock
AddMenuItem "Quit FVWM%menu/quit.png%"  				Popup QuitMenu
