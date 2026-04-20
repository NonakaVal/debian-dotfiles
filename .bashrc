# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ================================
# 📦 PATH & ENVIRONMENT
# ================================

# System and Languages
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Ruby/Jekyll Config
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# ================================
# ⚡ ALIASES
# ================================


alias ls='ls --color=auto'
alias bat='batcat'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# ================================
# 🤖 AI FUNCTIONS
# ================================

_ai_core() {
    local role="$1"; shift
    local prompt="$*"
    local dir="$HOME/Documentos/Notes/+/_output"
    local file="$dir/$(date +%Y-%m-%d_%H-%M-%S)_${role}.md"
    
    mkdir -p "$dir"
    set +m
    
    (while true; do
        for c in '|' '/' '-' '\'; do
            printf "\r%s pensando..." "$c"
            sleep 0.1
        done
    done) &
    
    local pid=$!
    local output
    output=$(aichat --role "$role" "$prompt" 2>/dev/null)
    
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    set -m
    
    printf "\r\033[K"
    echo "$output" | tee "$file" | glow -
    echo -e "\n💾 salvo em: $file"
}

aif() { 
    _ai_core "falido" "$@"; 
}

aihelp() {
    local dir="$HOME/Documentos/Notes/+/_output"
    _ai_core "help" "$@"
    
    # Copia a última resposta limpa para o clipboard
    tail -n +1 "$(ls -t "$dir"/*_help.md | head -1)" \
        | sed '/<think>/,/<\/think>/d; s/```[a-z]*//g; s/```//g; /^$/d' \
        | wl-copy
    echo "📋 copiado"
}


ailogs() {
    local dir="$HOME/Documentos/Notes/+/_output"
    local selected
    local file

    selected=$(
        find "$dir" -maxdepth 1 -type f -name "*.md" | sort -r | while read -r file; do
            base=$(basename "$file")
            date_part=$(echo "$base" | cut -d_ -f1)
            time_part=$(echo "$base" | cut -d_ -f2 | tr '-' ':')
            name_part=$(echo "$base" | cut -d_ -f3- | sed 's/\.md$//')

            printf "%s | %s | %s\t%s\n" "$date_part" "$time_part" "$name_part" "$file"
        done | fzf \
            --delimiter='\t' \
            --with-nth=1 \
            --preview 'glow {2}' \
            --preview-window=right:70% \
            --prompt='📂 logs > ' \
            --header='Enter: abrir • Ctrl-D: deletar' \
            --bind 'ctrl-d:execute(rm -f {2})+reload(find '"$dir"' -maxdepth 1 -type f -name "*.md" | sort -r | while read -r file; do base=$(basename "$file"); date_part=$(echo "$base" | cut -d_ -f1); time_part=$(echo "$base" | cut -d_ -f2 | tr "-" ":"); name_part=$(echo "$base" | cut -d_ -f3- | sed "s/\.md$//"); printf "%s | %s | %s\t%s\n" "$date_part" "$time_part" "$name_part" "$file"; done)'
    )

    file=$(printf '%s' "$selected" | cut -f2)
    [[ -n "$file" ]] && glow "$file"
}



addlog() {
    local dir="$HOME/Documentos/Notes/+/_output"
    local label="$1"

    if [[ -z "$label" ]]; then
        read -p "Nome do log (default: manual): " label
        label="${label:-manual}"
    fi

    local file="$dir/$(date +%Y-%m-%d_%H-%M-%S)_${label}.md"
    
    mkdir -p "$dir"
    
    nano "$file"
    
    echo -e "\n💾 salvo em: $file"
}
