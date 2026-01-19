#!/usr/bin/env bash
# =============================================================================
# Dotfiles Bootstrap Script
# One-command installer for a complete development environment
# =============================================================================
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

command_exists() {
    command -v "$1" &> /dev/null
}

# -----------------------------------------------------------------------------
# Detect platform
# -----------------------------------------------------------------------------
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Darwin)
            PLATFORM="macos"
            ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                PLATFORM="wsl"
            else
                PLATFORM="linux"
            fi

            # Detect Linux distribution
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="$ID"
            elif [ -f /etc/debian_version ]; then
                DISTRO="debian"
            elif [ -f /etc/fedora-release ]; then
                DISTRO="fedora"
            elif [ -f /etc/arch-release ]; then
                DISTRO="arch"
            else
                DISTRO="unknown"
            fi
            ;;
        *)
            error "Unsupported operating system: $OS"
            ;;
    esac

    info "Detected platform: $PLATFORM ($OS $ARCH)"
    if [ "$PLATFORM" = "linux" ] || [ "$PLATFORM" = "wsl" ]; then
        info "Linux distribution: $DISTRO"
    fi
}

# -----------------------------------------------------------------------------
# Install system dependencies
# -----------------------------------------------------------------------------
install_system_deps() {
    info "Installing system dependencies..."

    case "$PLATFORM" in
        macos)
            # Xcode Command Line Tools
            if ! xcode-select -p &> /dev/null; then
                info "Installing Xcode Command Line Tools..."
                xcode-select --install
                # Wait for installation
                until xcode-select -p &> /dev/null; do
                    sleep 5
                done
            fi
            success "Xcode Command Line Tools installed"
            ;;

        linux|wsl)
            case "$DISTRO" in
                ubuntu|debian)
                    sudo apt update
                    sudo apt install -y build-essential curl git zsh
                    ;;
                fedora)
                    sudo dnf install -y @development-tools curl git zsh
                    ;;
                arch)
                    sudo pacman -Syu --noconfirm base-devel curl git zsh
                    ;;
                *)
                    warn "Unknown distribution. Please install: build-essential curl git zsh"
                    ;;
            esac
            success "System dependencies installed"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Install Homebrew
# -----------------------------------------------------------------------------
install_homebrew() {
    if command_exists brew; then
        success "Homebrew already installed"
        return
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for current session
    case "$PLATFORM" in
        macos)
            if [ -f "/opt/homebrew/bin/brew" ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -f "/usr/local/bin/brew" ]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;
        linux|wsl)
            if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            fi
            ;;
    esac

    success "Homebrew installed"
}

# -----------------------------------------------------------------------------
# Install chezmoi
# -----------------------------------------------------------------------------
install_chezmoi() {
    if command_exists chezmoi; then
        success "chezmoi already installed"
        return
    fi

    info "Installing chezmoi..."

    if command_exists brew; then
        brew install chezmoi
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi

    success "chezmoi installed"
}

# -----------------------------------------------------------------------------
# Install Oh My Zsh
# -----------------------------------------------------------------------------
install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh My Zsh already installed"
        return
    fi

    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    success "Oh My Zsh installed"
}

# -----------------------------------------------------------------------------
# Setup age encryption (optional)
# -----------------------------------------------------------------------------
setup_encryption() {
    read -p "Do you want to set up age encryption for secrets? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Skipping encryption setup"
        return
    fi

    if ! command_exists age; then
        if command_exists brew; then
            brew install age
        else
            error "Please install age manually: https://github.com/FiloSottile/age"
        fi
    fi

    local key_file="$HOME/.config/chezmoi/key.txt"
    if [ ! -f "$key_file" ]; then
        mkdir -p "$(dirname "$key_file")"
        age-keygen -o "$key_file"
        chmod 600 "$key_file"
        success "Age encryption key generated at $key_file"
        warn "Back up this key securely! You'll need it to decrypt your secrets."
    else
        success "Age encryption key already exists"
    fi
}

# -----------------------------------------------------------------------------
# Clone and apply dotfiles
# -----------------------------------------------------------------------------
apply_dotfiles() {
    local REPO_URL="${DOTFILES_REPO:-https://github.com/nceresole/dotfiles.git}"

    info "Initializing chezmoi with dotfiles..."

    if [ -d "$HOME/.local/share/chezmoi" ]; then
        info "chezmoi source directory already exists, updating..."
        chezmoi update
    else
        chezmoi init "$REPO_URL"
    fi

    info "Applying dotfiles..."
    chezmoi apply

    success "Dotfiles applied"
}

# -----------------------------------------------------------------------------
# Install packages via Homebrew
# -----------------------------------------------------------------------------
install_packages() {
    if ! command_exists brew; then
        warn "Homebrew not installed, skipping package installation"
        return
    fi

    local chezmoi_source="$HOME/.local/share/chezmoi"

    info "Installing packages from Brewfile..."

    # Install base packages
    if [ -f "$chezmoi_source/Brewfile" ]; then
        brew bundle --file="$chezmoi_source/Brewfile"
    fi

    # Install platform-specific packages
    case "$PLATFORM" in
        macos)
            if [ -f "$chezmoi_source/Brewfile.darwin" ]; then
                brew bundle --file="$chezmoi_source/Brewfile.darwin"
            fi
            ;;
        linux|wsl)
            if [ -f "$chezmoi_source/Brewfile.linux" ]; then
                brew bundle --file="$chezmoi_source/Brewfile.linux"
            fi
            ;;
    esac

    success "Packages installed"
}

# -----------------------------------------------------------------------------
# Apply macOS defaults
# -----------------------------------------------------------------------------
apply_macos_defaults() {
    if [ "$PLATFORM" != "macos" ]; then
        return
    fi

    read -p "Do you want to apply macOS system preferences? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Skipping macOS defaults"
        return
    fi

    local script="$HOME/.local/share/chezmoi/scripts/macos-defaults.sh"
    if [ -f "$script" ]; then
        info "Applying macOS defaults..."
        bash "$script"
        success "macOS defaults applied"
    else
        warn "macOS defaults script not found"
    fi
}

# -----------------------------------------------------------------------------
# Set default shell to zsh
# -----------------------------------------------------------------------------
set_default_shell() {
    if [ "$SHELL" = "$(which zsh)" ]; then
        success "Zsh is already the default shell"
        return
    fi

    local zsh_path
    zsh_path="$(which zsh)"

    if ! grep -q "$zsh_path" /etc/shells; then
        info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    info "Setting zsh as default shell..."
    chsh -s "$zsh_path"

    success "Default shell set to zsh"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo "=============================================="
    echo "     Dotfiles Bootstrap Script"
    echo "=============================================="
    echo ""

    detect_platform
    install_system_deps
    install_homebrew
    install_chezmoi
    install_ohmyzsh
    setup_encryption
    apply_dotfiles
    install_packages
    apply_macos_defaults
    set_default_shell

    echo ""
    echo "=============================================="
    success "Bootstrap complete!"
    echo "=============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Open a new terminal or run: exec zsh"
    echo "  2. Review and customize ~/.zshrc.local for machine-specific settings"
    echo "  3. Run 'chezmoi edit' to modify dotfiles"
    echo ""
}

main "$@"
