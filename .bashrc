# ================================
# 🧠 BASIC CONFIG
# ================================

case $- in
    *i*) ;;
    *) return;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s histappend
shopt -s checkwinsize

# ================================
# 🎨 PROMPT & COLORS
# ================================

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

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

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

alias ls='ls --color=auto'
alias bat='batcat'


# ================================
# 🔌 BASH COMPLETION
# ================================

if ! shopt -oq posix; then
    [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
    [ -f /etc/bash_completion ] && . /etc/bash_completion
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
    local file
    
    file=$(ls -t "$dir"/*.md 2>/dev/null | fzf \
        --preview 'glow {}' \
        --preview-window=right:70% \
        --prompt='📂 log > ' \
        --header='Enter: abrir • Ctrl-D: deletar' \
        --bind "ctrl-d:execute(rm {})+reload(ls -t $dir/*.md)")
        
    [[ -n "$file" ]] && glow "$file"
}