# =============================================================================
# Git Configuration
# Topic: git.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# Git Aliases
# -----------------------------------------------------------------------------
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate -10'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gdc='git diff --cached'

# Git UI (lazygit)
if command -v lazygit &>/dev/null; then
    alias lg='lazygit'
fi

# -----------------------------------------------------------------------------
# Git Functions
# -----------------------------------------------------------------------------

# Quick git commit with message
qcommit() {
    if [ -z "$1" ]; then
        echo "Usage: qcommit <message>"
        return 1
    fi
    git add . && git commit -m "$1"
}

# Quick git commit and push
qpush() {
    if [ -z "$1" ]; then
        echo "Usage: qpush <message>"
        return 1
    fi
    git add . && git commit -m "$1" && git push
}

# Create a new branch and switch to it
gnew() {
    if [ -z "$1" ]; then
        echo "Usage: gnew <branch-name>"
        return 1
    fi
    git checkout -b "$1"
}

# Delete a branch (local)
gdel() {
    if [ -z "$1" ]; then
        echo "Usage: gdel <branch-name>"
        return 1
    fi
    git branch -d "$1"
}
