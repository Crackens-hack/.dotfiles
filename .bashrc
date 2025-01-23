# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and update LINES & COLUMNS
shopt -s checkwinsize

# Make `less` more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Detect chroot environment
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Determine if running as root
if [[ $EUID -eq 0 ]]; then
    USER_COLOR='\[\033[01;31m\]'  # Rojo para root
    PATH_COLOR='\[\033[01;33m\]'  # Amarillo para rutas en root
else
    USER_COLOR='\[\033[01;32m\]'  # Verde para usuario normal
    PATH_COLOR='\[\033[01;34m\]'  # Azul para rutas en usuario normal
fi
HOST_COLOR='\[\033[01;36m\]'  # Cian para el hostname
RESET_COLOR='\[\033[00m]'

# Set a fancy prompt
PS1='${debian_chroot:+($debian_chroot)}'"$USER_COLOR\u$HOST_COLOR@\h$RESET_COLOR:$PATH_COLOR\w$RESET_COLOR\n\$ "

# If this is an xterm, set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Define useful aliases
alias sb='source ~/.bashrc'   # Recargar bashrc
alias cls='clear'             # Limpiar pantalla
alias df='df -h'              # Mostrar espacio en disco en formato legible
alias free='free -m'          # Ver memoria en MB
alias ..='cd ..'              # Subir un nivel
alias ...='cd ../..'          # Subir dos niveles
alias mv='mv -i'              # Preguntar antes de sobrescribir archivos
alias cp='cp -i'              # Preguntar antes de sobrescribir archivos
alias rm='rm -I'              # Confirmación antes de borrar más de un archivo
alias mkdir='mkdir -p'        # Crear directorios padres automáticamente
alias chmod='chmod --preserve-root'  # Evita cambiar permisos del root accidentalmente
alias chown='chown --preserve-root'  # Evita cambiar dueño del root accidentalmente
alias untar='tar -xvf'        # Extraer archivos tar
alias update='sudo apt update && sudo apt upgrade -y'  # Actualizar sistema

# Alert alias for long-running commands
alias alert='notify-send --urgency=low -i terminal "$(history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")"'

# Load additional aliases if available
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
