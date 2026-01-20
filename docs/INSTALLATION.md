# Installation Guide

Step-by-step instructions for setting up these dotfiles on different platforms.

## Table of Contents

- [Quick Start](#quick-start)
- [Fresh WSL Instance](#fresh-wsl-instance)
- [Fresh macOS Machine](#fresh-macos-machine)
- [Fresh Linux Machine](#fresh-linux-machine)
- [With Encrypted Secrets](#with-encrypted-secrets)
- [Post-Installation](#post-installation)

---

## Quick Start

For any platform, the one-liner:

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nceresole/dotfiles/main/scripts/bootstrap.sh)"
```

Or with chezmoi directly:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nceresole
```

---

## Fresh WSL Instance

### Option 1: One-liner bootstrap

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nceresole/dotfiles/main/scripts/bootstrap.sh)"
```

This script will:
1. Detect you're on WSL/Linux
2. Install system dependencies (curl, git, build-essential)
3. Install Homebrew for Linux
4. Install chezmoi
5. Clone and apply your dotfiles
6. Run `brew bundle` to install all CLI tools

### Option 2: Manual steps

```bash
# 1. Install system dependencies
sudo apt update && sudo apt install -y curl git build-essential

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Add Homebrew to PATH (for current session)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 4. Install chezmoi
brew install chezmoi

# 5. Initialize and apply dotfiles
chezmoi init --apply nceresole
```

### After installation

```bash
# Restart your shell or source the new config
exec zsh

# Verify everything loaded
echo $EDITOR          # Should show 'nano'
which starship        # Should find it
which eza             # Should find it
```

### WSL-specific features

Your dotfiles will automatically:
- Use the Linux Homebrew path (`/home/linuxbrew/.linuxbrew`)
- Skip macOS-only features (UseKeychain, osxkeychain credential helper)
- Use `git-credential-manager.exe` for Git credentials (Windows integration)
- Include `keychain` and `xclip` from `Brewfile.linux`
- Set up clipboard aliases (`pbcopy`/`pbpaste` → `clip.exe`/`powershell.exe`)
- Define `$WINHOME` pointing to your Windows user directory

---

## Fresh macOS Machine

### Option 1: One-liner bootstrap

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nceresole/dotfiles/main/scripts/bootstrap.sh)"
```

This will:
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Install chezmoi
4. Clone and apply dotfiles
5. Install all packages from Brewfile and Brewfile.darwin
6. Apply macOS system preferences

### Option 2: Manual steps

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Add Homebrew to PATH
# Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel Mac:
eval "$(/usr/local/bin/brew shellenv)"

# 4. Install chezmoi
brew install chezmoi

# 5. Initialize and apply dotfiles
chezmoi init --apply nceresole

# 6. Install packages
brew bundle --file=~/.local/share/chezmoi/Brewfile
brew bundle --file=~/.local/share/chezmoi/Brewfile.darwin

# 7. Apply macOS preferences (optional)
~/.local/share/chezmoi/scripts/macos-defaults.sh
```

### After installation

```bash
# Restart terminal or source config
exec zsh

# Verify tools
which starship eza bat

# Log out and back in for some macOS settings to take effect
```

### macOS-specific features

Your dotfiles will automatically:
- Use the correct Homebrew path (Apple Silicon vs Intel)
- Enable UseKeychain for SSH keys
- Use osxkeychain Git credential helper
- Install GUI apps (iTerm2, VS Code, Raycast, etc.)
- Install Nerd Fonts

---

## Fresh Linux Machine

### Debian/Ubuntu

```bash
# 1. Install dependencies
sudo apt update && sudo apt install -y curl git build-essential zsh

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Add Homebrew to PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 4. Install and apply
brew install chezmoi
chezmoi init --apply nceresole

# 5. Set zsh as default shell
chsh -s $(which zsh)
```

### Fedora

```bash
# 1. Install dependencies
sudo dnf install -y curl git gcc make zsh

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Add Homebrew to PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 4. Install and apply
brew install chezmoi
chezmoi init --apply nceresole

# 5. Set zsh as default shell
chsh -s $(which zsh)
```

### Arch Linux

```bash
# 1. Install dependencies
sudo pacman -S --noconfirm curl git base-devel zsh

# 2. Install Homebrew (or use pacman for tools)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Add Homebrew to PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 4. Install and apply
brew install chezmoi
chezmoi init --apply nceresole

# 5. Set zsh as default shell
chsh -s $(which zsh)
```

---

## With Encrypted Secrets

If you have encrypted files (SSH keys, API tokens), you need your age key before applying.

### On your existing machine

```bash
# Find your age key
cat ~/.config/chezmoi/key.txt
```

### On the new machine

```bash
# 1. Create config directory
mkdir -p ~/.config/chezmoi

# 2. Copy your age key (choose one method):

# Method A: Paste directly
cat > ~/.config/chezmoi/key.txt << 'EOF'
# paste your key here
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
EOF

# Method B: SCP from existing machine
scp user@oldmachine:~/.config/chezmoi/key.txt ~/.config/chezmoi/

# Method C: Copy from password manager or secure storage

# 3. Set correct permissions
chmod 600 ~/.config/chezmoi/key.txt

# 4. Now apply dotfiles - secrets will decrypt automatically
chezmoi init --apply nceresole
```

### Important

- **Back up your age key** to a password manager or secure location
- Without the key, you cannot decrypt your secrets on new machines
- Never commit `key.txt` to git

---

## Post-Installation

### Verify the installation

```bash
# Check shell is configured
echo $SHELL              # Should be zsh
echo $EDITOR             # Should be nano

# Check tools are available
which starship eza bat zoxide fzf

# Check prompt is working
starship --version

# Check platform detection
chezmoi data | grep -E "is_macos|is_linux|is_wsl"
```

### Install VS Code extensions

```bash
cat ~/.config/Code/User/extensions.txt | xargs -L 1 code --install-extension
```

### Set up Git credentials (first push)

```bash
# This will prompt for authentication
cd ~/.local/share/chezmoi
git push
```

### Optional: Install Oh My Zsh plugins manually

If plugins didn't install via externals:

```bash
chezmoi apply --refresh-externals
```

### Machine-specific settings

Create local override files for this machine:

```bash
# Shell settings not tracked in git
echo '# Machine-specific settings' > ~/.zshrc.local

# Git settings (e.g., work email)
echo '[user]
    email = work@company.com' > ~/.gitconfig.local

# SSH hosts
echo 'Host work-server
    HostName 192.168.1.100
    User admin' > ~/.ssh/config.local
```

---

## Updating

After initial setup, keep dotfiles updated:

```bash
# Pull latest and apply
chezmoi update

# Or step by step
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

---

## Uninstalling

To remove chezmoi management (keeps dotfiles in place):

```bash
# Remove chezmoi state
rm -rf ~/.local/share/chezmoi
rm -rf ~/.config/chezmoi
```

To fully reset (removes applied dotfiles):

```bash
# Back up first!
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup

# Then remove
rm ~/.zshrc ~/.zprofile ~/.gitconfig ~/.tmux.conf
rm -rf ~/.oh-my-zsh/custom/topics
rm -rf ~/.config/starship ~/.config/broot ~/.config/btop
```
