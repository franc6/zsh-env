autoload -Uz compinit && compinit
uname=`uname`

# set up SPEAKER, BROWSER and TERM for HPUX
if test $uname = "HP-UX" ; then
	export SPEAKER=external
	export BROWSER=/usr/local/bin/netscape
	if test $TERM = "xterm" ; then
		export TERM=dtterm
	fi
# If the linux box set DISPLAY to "unix:0.0" unset it!
elif test $uname = "Linux" ; then
	if test -n "$DISPLAY" -a "$DISPLAY" = "unix:0.0" ; then
		unset DISPLAY
	fi
# set up MOZILLA_HOME for AIX
elif test $uname = "AIX" ; then
	export MOZILLA_HOME=/usr/netscape
elif test $uname = "SunOS" ; then
	export XKEYSYMDB='/usr/dt/appconfig/netscape/XKeysymD'
fi

if test $uname = "FreeBSD" -o $uname = "Darwin" ; then
	shorthostname=`hostname -s`
else
	shorthostname=`echo ${HOST} | sed 's/\([^.]*\).*/\1/'`
fi

# set up REMOTEHOST based on SSH_CLIENT if REMOTEHOST not already set!
if test -n "$SSH_CLIENT" -a -z "$REMOTEHOST" ; then
	export REMOTEHOST="`echo ${SSH_CLIENT} | cut -f1 -d' '`"
fi

# ssh-agent setup
if test $uname != "Darwin" ; then
	sshagentfile=$HOME/.ssh.zsh.`hostname`
	if test -f $sshagentfile ; then
		. $sshagentfile
		whoami=`whoami`
		uid=`id -u $whoami`
		testpid=`pgrep -u $uid ssh-agent | grep $SSH_AGENT_PID`
		if test -n "$testpid" && test `echo $SSH_AGENT_PID` = `echo $testpid` ; then
			echo "Using ssh-agent with PID: $SSH_AGENT_PID"
		else
			echo "Starting new ssh-agent, old one was stopped"
			rm -f $sshagentfile
			ssh-agent -s > $sshagentfile
			. $sshagentfile
		fi
		unset whoami
		unset uid
		unset testpid
	else
		ssh-agent -s > $sshagentfile
		. $sshagentfile
	fi
	unset sshagentfile
fi

# Command prompt
autoload -Uz vcs_info
function precmd_vcs_info() {
    vcs_info
    if test -n "${VIRTUAL_ENV}" ; then
        PROMPT_PREFIX="%F{green}%B(`basename ${VIRTUAL_ENV}`) %b%f"
    else
        PROMPT_PREFIX=""
    fi
}
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
PROMPT=\$PROMPT_PREFIX$'%~ '\$vcs_info_msg_0_$'
Yes, master?'
zstyle ':vcs_info:*' stagedstr ' [Staged Changes]'
zstyle ':vcs_info:*' unstagedstr ' [Unstaged Changes]'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' check-for-staged-changes true
zstyle ':vcs_info:*' formats '%F{yellow}(%s)-[%b]%F{white}'
zstyle ':vcs_info:git:*' formats '%F{yellow}[%b]%c%u%F{white}'
zstyle ':vcs_info:hg:*' formats '%F{yellow}(%s)-[%b]%c%u%F{white}'

function precmd() {
	print -Pn "\e]2;${USER}@${shorthostname} %~\a"
}

function zle-line-init zle-keymap-select {
	VIMPROMPT="%F{yellow}%B[% NORMAL]% %b%f "
	PROMPT_RIGHT="${${KEYMAP/vicmd/$VIMPROMPT}/(main|viins)/}"
	PROMPT=\$PROMPT_RIGHT\$PROMPT_PREFIX$'%~ '\$vcs_info_msg_0_$'
Yes, master?'
	zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# Aliases
if alias ls>/dev/null ; then
    # Clear any alias for ls!
    unalias ls
fi
lsversion=`ls --version 2>/dev/null | grep GNU`
if test -n "${lsversion}"; then
    alias ls='ls --color=never'
fi
alias vi=vim
if test $uname = "Darwin" ; then
	alias ldd="otool -L"
else
    	# Work around bug in xterms on macos via ssh
	if test -n "$SSH_CLIENT" ; then
	    alias vi="vim -u /home/franc/.vimrc"
	fi
fi

alias h=history
alias j="jobs -l"
#alias larger "echo ']50;#+'"
#alias smaller "echo ']50;#-'"
#alias normal "echo ']50;#'"
#alias extralarge 'larger ; larger ; larger ; larger'
#alias pushtophone "obexapp -a 00:07:e0:f1:83:8f -c -C OPUSH"

# STTY
stty intr ^C
stty kill 
#stty erase 

# Improved history/search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "[A" up-line-or-beginning-search
bindkey "[B" down-line-or-beginning-search
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

# Set options
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt CSH_JUNKIE_HISTORY CSH_NULL_GLOB
setopt CLOBBER
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS
# if CLOBBER is set, this one makes no sense
#setopt HIST_ALLOW_CLOBBER
setopt HIST_REDUCE_BLANKS HIST_NO_STORE HIST_BEEP HIST_FCNTL_LOCK
# This next option isn't set for now, as it's unlikely I'll need it
#setopt HIST_LEX_WORDS
#
setopt AUTO_LIST LIST_AMBIGUOUS BAD_PATTERN
#setopt listmaxrows=3
setopt EQUALS NO_GLOB_DOTS MARK_DIRS
# RE_MATCH_PCRE isn't available on macos, and might not be useful to me,
# so don't enable it for now
#setopt RE_MATCH_PCRE
# Disable start/stop characters!
setopt NO_FLOW_CONTROL IGNORE_EOF NO_BG_NICE

