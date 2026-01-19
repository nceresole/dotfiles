# Troubleshooting Guide

Solutions to common issues with the dotfiles setup.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Template Errors](#template-errors)
- [Shell Issues](#shell-issues)
- [Sync Issues](#sync-issues)
- [Platform-Specific Issues](#platform-specific-issues)

---

## Installation Issues

### chezmoi not found after install

**Symptom:** `command not found: chezmoi`

**Solution:** Add to PATH:

```bash
# For current session
export PATH="$HOME/.local/bin:$PATH"

# Permanently (add to ~/.zprofile.local)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile.local
```

### Homebrew packages fail to install

**Symptom:** `brew bundle` errors

**Solution:**

```bash
# Update Homebrew
brew update

# Check for issues
brew doctor

# Install manually
brew install <package-name>

# Skip problematic packages temporarily
brew bundle --file=Brewfile || true
```

### Oh My Zsh already installed

**Symptom:** Error about existing `~/.oh-my-zsh`

**Solution:**

```bash
# Back up and remove
mv ~/.oh-my-zsh ~/.oh-my-zsh.backup

# Apply dotfiles
chezmoi apply

# Or use existing installation
# (Edit .zshrc to use your existing Oh My Zsh)
```

### Permission denied errors

**Symptom:** Can't write to files

**Solution:**

```bash
# Fix ownership
sudo chown -R $USER:$USER ~/.local/share/chezmoi

# Fix SSH permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
```

---

## Template Errors

### Template syntax error

**Symptom:** `template: ... error`

**Solution:**

```bash
# Find the error
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Common issues:
# - Missing {{ end }} for {{ if }}
# - Typo in variable name
# - Missing quotes around strings
```

### Variable not defined

**Symptom:** `map has no entry for key "variableName"`

**Solution:**

```bash
# Check available data
chezmoi data

# Add missing variable to .chezmoi.toml.tmpl
chezmoi edit ~/.local/share/chezmoi/.chezmoi.toml.tmpl

# Re-initialize
chezmoi init
```

### Config file template changed warning

**Symptom:** `warning: config file template has changed`

**Solution:**

```bash
# Re-run init to regenerate config
chezmoi init

# Or force apply
chezmoi apply --force
```

### Inconsistent state error

**Symptom:** `inconsistent state` for external files

**Solution:**

```bash
# Clear external cache
rm -rf ~/.cache/chezmoi

# Re-apply with fresh externals
chezmoi apply --refresh-externals
```

---

## Shell Issues

### Aliases not working

**Symptom:** `command not found` for aliases

**Possible causes:**

1. **Topic file not sourced:**

```bash
# Check if topic files are loaded
ls ~/.oh-my-zsh/custom/topics/

# Source manually to test
source ~/.oh-my-zsh/custom/topics/git.zsh
```

2. **Syntax error in topic file:**

```bash
# Check for errors
zsh -n ~/.oh-my-zsh/custom/topics/git.zsh
```

3. **File not applied:**

```bash
chezmoi status
chezmoi apply
```

### Slow shell startup

**Symptom:** Terminal takes seconds to open

**Solution:**

```bash
# Profile startup time
time zsh -i -c exit

# Find slow parts
zsh -xv 2>&1 | head -100

# Common fixes:
# - Disable nvm (use fnm instead)
# - Lazy-load heavy tools
# - Reduce plugins
```

### Plugin errors

**Symptom:** Errors about missing plugins

**Solution:**

```bash
# Refresh external dependencies
chezmoi apply --refresh-externals

# Or reinstall plugins manually
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
chezmoi apply
```

### Starship prompt not showing

**Symptom:** Plain prompt instead of Starship

**Solution:**

```bash
# Check if installed
which starship

# Install if missing
brew install starship

# Check config path
echo $STARSHIP_CONFIG

# Test starship
starship init zsh
```

---

## Sync Issues

### Changes not applying

**Symptom:** `chezmoi apply` does nothing

**Solution:**

```bash
# Check status
chezmoi status

# Force apply
chezmoi apply --force

# Check diff
chezmoi diff
```

### Merge conflicts

**Symptom:** Conflicts when pulling

**Solution:**

```bash
# View conflict
chezmoi merge ~/.zshrc

# Accept source (your dotfiles repo)
chezmoi apply --force

# Or accept target (local changes)
chezmoi re-add
```

### Git push rejected

**Symptom:** Can't push changes

**Solution:**

```bash
cd ~/.local/share/chezmoi

# Pull first
git pull --rebase

# Resolve conflicts if any
git status

# Push
git push
```

### External dependencies not updating

**Symptom:** Plugins are outdated

**Solution:**

```bash
# Force refresh
chezmoi apply --refresh-externals

# Or clear cache
rm -rf ~/.cache/chezmoi
chezmoi apply
```

---

## Platform-Specific Issues

### macOS

#### Keychain errors

**Symptom:** `UseKeychain: command not found`

**Solution:** This option is macOS-only. Check that your SSH config template has the correct conditional:

```go
{{- if .is_macos }}
    UseKeychain yes
{{- end }}
```

#### Homebrew path issues

**Symptom:** `brew: command not found`

**Solution:**

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"

# Check which is installed
ls /opt/homebrew/bin/brew /usr/local/bin/brew 2>/dev/null
```

#### macOS defaults not applying

**Symptom:** System preferences unchanged

**Solution:**

```bash
# Run manually
~/.local/share/chezmoi/scripts/macos-defaults.sh

# Log out and back in for some settings
# Restart for others
```

### Linux

#### Missing packages

**Symptom:** Tools not available

**Solution:**

```bash
# Install via system package manager
sudo apt install zsh curl git  # Debian/Ubuntu
sudo dnf install zsh curl git  # Fedora
sudo pacman -S zsh curl git    # Arch

# Or use Homebrew on Linux
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### fzf keybindings not working

**Symptom:** Ctrl+R doesn't show fzf

**Solution:**

```bash
# Check fzf installation
which fzf

# Source keybindings manually
source /usr/share/doc/fzf/examples/key-bindings.zsh
```

### WSL

#### Windows path issues

**Symptom:** Can't access Windows files

**Solution:**

```bash
# Check mount
ls /mnt/c

# Access Windows home
cd "$WINHOME"

# If WINHOME is empty, set manually
export WINHOME="/mnt/c/Users/YourUsername"
```

#### Clipboard not working

**Symptom:** `pbcopy`/`pbpaste` errors

**Solution:**

The WSL platform file defines these. Check it's loading:

```bash
# Verify platform detected correctly
chezmoi data | grep is_wsl

# Test clipboard
echo "test" | clip.exe
powershell.exe -Command Get-Clipboard
```

#### Slow file operations

**Symptom:** Shell is slow in Windows directories

**Solution:**

```bash
# Work in Linux filesystem when possible
cd ~

# Disable Windows path
# Add to ~/.zshrc.local:
export PATH=$(echo "$PATH" | sed -e 's/:\/mnt[^:]*//g')
```

---

## Getting Help

### Diagnostic Commands

```bash
# Check chezmoi status
chezmoi doctor

# See applied vs source state
chezmoi status

# View all data available to templates
chezmoi data

# Test template rendering
chezmoi execute-template < file.tmpl

# Dry run
chezmoi apply --dry-run --verbose
```

### Logs and Debug

```bash
# Verbose output
chezmoi apply --verbose

# Debug mode
chezmoi apply --debug

# Check git status
chezmoi git status
```

### Reset Everything

**Nuclear option** - start fresh:

```bash
# Back up current state
cp -r ~/.local/share/chezmoi ~/.local/share/chezmoi.backup

# Remove chezmoi state
rm -rf ~/.local/share/chezmoi
rm -rf ~/.config/chezmoi

# Re-initialize
chezmoi init nceresole
chezmoi apply
```
