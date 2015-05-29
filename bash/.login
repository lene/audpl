# $FreeBSD: src/share/skel/dot.login,v 1.16 2001/06/25 20:40:02 nik Exp $
#
# .login - csh login script, read by login shell, after `.cshrc' at login.
#
# see also csh(1), environ(7).
#

AUDPL_DIR=${HOME}/Music/lists/audacious
function update_playlists() {
	cd ${AUDPL_DIR} && \
		git pull && \
		git commit -a -m "$(date) - $(hostname) logout" && \
		git push origin master
}

[ -x /usr/games/fortune ] && /usr/games/fortune freebsd-tips

$(gpg-agent --daemon) &

# update audacious playlist from git on login
cd ${AUDPL_DIR} && git pull

# push changes made to audacious playlist on logout
trap update_playlists 0
