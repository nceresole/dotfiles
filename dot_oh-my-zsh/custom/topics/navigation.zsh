# =============================================================================
# Navigation & File Management
# Topic: navigation.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# Modern CLI Replacements
# -----------------------------------------------------------------------------

# eza (better ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -la --icons --git'
    alias la='eza -a --icons'
    alias lt='eza --tree --icons --level=2'
    alias l='eza -CF --icons'
else
    alias ll='ls -lah'
    alias la='ls -A'
    alias l='ls -CF'
fi

# bat (better cat)
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

# zoxide (smart cd)
if command -v zoxide &>/dev/null; then
    alias cd='z'
    alias cdi='zi'
fi

# -----------------------------------------------------------------------------
# Navigation Shortcuts
# -----------------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Directory shortcuts (customize these!)
alias projects='cd ~/projects'
alias dev='cd ~/development'

# -----------------------------------------------------------------------------
# Safety Aliases
# -----------------------------------------------------------------------------
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------
alias c='clear'
alias h='history'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me'

# System monitor
alias monitor="btop"

# -----------------------------------------------------------------------------
# Navigation Functions
# -----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <file>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "File not found: $1"
        return 1
    fi

    case "$1" in
        *.tar.gz|*.tgz)  tar -xzf "$1"   ;;
        *.tar.bz2|*.tbz) tar -xjf "$1"   ;;
        *.tar.xz)        tar -xJf "$1"   ;;
        *.tar)           tar -xf "$1"    ;;
        *.zip)           unzip "$1"      ;;
        *.rar)           unrar x "$1"    ;;
        *.7z)            7z x "$1"       ;;
        *.gz)            gunzip "$1"     ;;
        *.bz2)           bunzip2 "$1"    ;;
        *)               echo "Unknown archive format: $1" ;;
    esac
}

# Find and kill process by port
killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port>"
        return 1
    fi

    lsof -ti:$1 | xargs kill -9 2>/dev/null
    echo "Killed process on port $1"
}

# Search command history
hsearch() {
    if [ -z "$1" ]; then
        echo "Usage: hsearch <query>"
        return 1
    fi
    history | grep "$1"
}

# Create backup of file
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created"
}

# Directory shortcuts (shortcuts.zsh content)
hd=~/__HomeDir
hdinbox=~/__HomeDir/0__temp/Inbox
