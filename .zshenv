function setenv() {
	export $1=$2
}

alias unsetenv=unset

uname=`uname`

# if /etc/PATH exists, use it for the path, and tack on /home/franc/bin
if test -d ${HOME}/Library/Android/sdk ; then
	export ANDROID_HOME=${HOME}/Library/Android/sdk
	if test -d /opt/local/share/gradle ; then
		export GRADLE_HOME=/opt/local/share/gradle
	elif test -d /usr/local/opt/gradle ; then
		export GRADLE_HOME=/usr/local/opt/gradle
	fi
elif test -d ${HOME}/android-sdk-macosx ; then
	export ANDROID_HOME=${HOME}/android-sdk-macosx
	if test -d /opt/local/share/gradle ; then
		export GRADLE_HOME=/opt/local/share/gradle
	elif test -d /usr/local/opt/gradle ; then
		export GRADLE_HOME=/usr/local/opt/gradle
	fi
elif test -d ${HOME}/android-sdk ; then
	export ANDROID_HOME=${HOME}/android-sdk
	export GRADLE_HOME=/usr/local/share/java/gradle
else
	export ANDROID_HOME=/noexist
fi

if test -d "${ANDROID_HOME}" ; then
    export ANDROID_SDK_ROOT=${ANDROID_HOME}
fi

# Auto-export PATH (and make sure entries are unique) when setting path
#typeset -TUx PATH path
# Auto-export MANPATH (and make sure entries are unique) when setting manpath
#typeset -TUx MANPATH manpath

if test -r /etc/PATH ; then
	export PATH=`cat /etc/PATH`
	export PATH=${PATH}:${HOME}/bin
else
	path=( )
	for dir in /sbin /bin /usr/sbin /usr/local/sbin /opt/local/sbin /usr/local/opt/curl/bin /usr/local/ssl/bin /opt/local/bin /usr/local/bin /opt/X11/bin /usr/bin /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin /usr/gcc/4.8/bin /opt/developerstudio12.5/bin /usr/games /usr/local/games ${HOME}/bin ${ANDROID_HOME}/emulator ${ANDROID_HOME}/tools ${ANDROID_HOME}/tools/bin ${ANDROID_HOME}/platform-tools ${HOME}/.composer/vendor/bin ${HOME}/node_modules/.bin ; do
		if test -d $dir ; then
			path+=$dir
		fi
	done
fi

if test "${uname}" = "Darwin" ; then
	if test -n ${MANPATH} ; then
		testmanpath=${(s/:/)MANPATH}
	else
		testmanpath=('/usr/share/man')
	fi
	manpath=( )
	for dir in ${testmanpath} /Applications/Xcode.app/Conents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man /opt/local/man /opt/local/share/man /usr/local/share/man ; do
		if test -d $dir ; then
			manpath+=$dir
		fi
	done
	unset testmanpath
fi

unset TERMINFO
unset TERMINFO_DIRS
for dir in /usr/share/terminfo /usr/share/misc/terminfo /opt/local/share/terminfo /usr/local/share/terminfo ; do
	if test -d "$dir" ; then
		if test -n "$TERMINFO_DIRS" ; then
			export TERMINFO_DIRS=${TERMINFO_DIRS}:${dir}
		else
			export TERMINFO_DIRS=${dir}
		fi
	fi
done

export EDITOR="vim"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

export MAIL='{sheridan.tcsaf.com}'

if test "${uname}" = "Darwin" ; then
	limit coredumpsize unlimited
fi

autoload -U zmv
