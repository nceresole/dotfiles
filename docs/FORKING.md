# Forking Guide

How to fork this repository and make it your own.

## Table of Contents

- [Quick Start](#quick-start)
- [Initial Setup](#initial-setup)
- [Personalization Checklist](#personalization-checklist)
- [Understanding the Structure](#understanding-the-structure)
- [Common Customizations](#common-customizations)
- [Adding Your Own Tools](#adding-your-own-tools)
- [Removing What You Don't Need](#removing-what-you-dont-need)
- [Testing Your Changes](#testing-your-changes)
- [Keeping Up with Upstream](#keeping-up-with-upstream)

---

## Quick Start

```bash
# 1. Fork on GitHub (click the Fork button)

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles

# 3. Update the GitHub username in bootstrap.sh
sed -i 's/nceresole/YOUR_USERNAME/g' scripts/bootstrap.sh

# 4. Update default identity in .chezmoi.toml.tmpl
# Edit the promptStringOnce defaults with your name/email

# 5. Commit and push
git add -A
git commit -m "Personalize for YOUR_USERNAME"
git push
```

---

## Initial Setup

### 1. Fork the Repository

Click the **Fork** button on GitHub to create your own copy.

### 2. Clone Locally

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
```

### 3. Update Core Identity

Edit `.chezmoi.toml.tmpl`:

```bash
# Find these lines and change the defaults
{{- $name := promptStringOnce . "name" "Your full name" "YOUR NAME" -}}
{{- $email := promptStringOnce . "email" "Your email address" "your@email.com" -}}
```

### 4. Update Bootstrap Script

Edit `scripts/bootstrap.sh`:

```bash
# Change this line
GITHUB_USERNAME="YOUR_USERNAME"
```

### 5. Update README

Edit `README.md` to reflect your repository:

```bash
# Update the one-liner URL
sh -c "$(curl -fsLS https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/bootstrap.sh)"

# Update chezmoi init command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply YOUR_USERNAME
```

---

## Personalization Checklist

Use this checklist when forking:

### Required Changes

- [ ] `.chezmoi.toml.tmpl` - Update default name and email
- [ ] `scripts/bootstrap.sh` - Update `GITHUB_USERNAME`
- [ ] `README.md` - Update installation URLs and username references

### Recommended Changes

- [ ] `dot_gitconfig.tmpl` - Review Git aliases and settings
- [ ] `Brewfile` - Remove tools you don't use, add ones you need
- [ ] `Brewfile.darwin` - Customize macOS apps
- [ ] `dot_config/starship/starship.toml` - Customize your prompt
- [ ] `dot_oh-my-zsh/custom/topics/*.zsh` - Review aliases and functions

### Optional Changes

- [ ] `dot_tmux.conf` - Adjust keybindings or theme
- [ ] `dot_config/Code/User/settings.json` - VS Code preferences
- [ ] `scripts/macos-defaults.sh` - macOS system preferences
- [ ] `docs/` - Update documentation for your setup

---

## Understanding the Structure

### File Naming Conventions

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | Becomes `.` | `dot_zshrc` → `~/.zshrc` |
| `private_` | Mode 600 | `private_dot_ssh/` → `~/.ssh/` (private) |
| `.tmpl` | Template file | `dot_zshrc.tmpl` → rendered `~/.zshrc` |
| `run_once_` | Script runs once | Tracked by chezmoi |
| `run_` | Script runs every apply | Not tracked |

### Template Variables

Available in `.tmpl` files:

```go
{{ .name }}              // Your configured name
{{ .email }}             // Your configured email
{{ .is_macos }}          // true on macOS
{{ .is_linux }}          // true on Linux (including WSL)
{{ .is_wsl }}            // true on WSL specifically
{{ .homebrew_prefix }}   // /opt/homebrew or /home/linuxbrew/.linuxbrew
{{ .chezmoi.hostname }}  // Machine hostname
{{ .chezmoi.os }}        // darwin, linux, windows
```

### Directory Layout

```
.local/share/chezmoi/
├── .chezmoi.toml.tmpl      # YOUR IDENTITY - edit this first
├── .chezmoiexternal.toml   # External plugins (zsh)
├── .chezmoiscripts/        # Auto-run scripts
│
├── dot_zshrc.tmpl          # Main shell - customize aliases here
├── dot_gitconfig.tmpl      # Git - your preferences
│
├── dot_oh-my-zsh/custom/
│   └── topics/             # MAIN CUSTOMIZATION AREA
│       ├── git.zsh         # Git workflow
│       ├── python.zsh      # Python development
│       ├── node.zsh.tmpl   # Node.js development
│       └── ...
│
├── Brewfile                # CLI tools to install
├── Brewfile.darwin         # macOS apps
└── Brewfile.linux          # Linux-specific tools
```

---

## Common Customizations

### Change Your Editor

Edit `dot_oh-my-zsh/custom/exports.zsh.tmpl`:

```bash
# Change from nano to your preferred editor
export EDITOR='nvim'
export VISUAL='nvim'
```

### Change Shell Theme

Edit `dot_config/starship/starship.toml` or replace with your own Starship config.

For Oh My Zsh themes, edit `dot_zshrc.tmpl`:

```bash
ZSH_THEME="agnoster"  # or your preferred theme
```

### Add Your Aliases

Option 1: Add to existing topic file:

```bash
# Edit dot_oh-my-zsh/custom/topics/git.zsh
alias glog='git log --oneline --graph'
```

Option 2: Create a new topic file:

```bash
# Create dot_oh-my-zsh/custom/topics/custom.zsh
alias myproject='cd ~/projects/myproject'
```

### Change Git Defaults

Edit `dot_gitconfig.tmpl`:

```ini
[init]
    defaultBranch = main  # or master

[pull]
    rebase = true  # or false

[alias]
    # Add your own aliases
    lg = log --oneline --graph --all
```

### Customize Homebrew Packages

Edit the Brewfile(s):

```ruby
# Brewfile - add tools
brew "neovim"
brew "lazygit"
brew "htop"

# Remove tools you don't need by deleting lines
```

---

## Adding Your Own Tools

### Add a New CLI Tool

1. Add to `Brewfile`:
   ```ruby
   brew "mytool"
   ```

2. Add configuration (if needed):
   ```bash
   # After installing locally, add config to chezmoi
   chezmoi add ~/.config/mytool/config.yml
   ```

3. Add shell integration (if needed):
   ```bash
   # Edit dot_zshrc.tmpl or create a topic file
   if command -v mytool &> /dev/null; then
       eval "$(mytool init zsh)"
   fi
   ```

### Add a New Topic File

Create `dot_oh-my-zsh/custom/topics/mytopic.zsh`:

```bash
# =============================================================================
# My Topic Configuration
# Topic: mytopic.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias mt='mytool'
alias mtr='mytool run'

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
myfunction() {
    echo "Hello from my function"
}
```

### Add Platform-Specific Config

Create a `.tmpl` file with conditionals:

```bash
# dot_oh-my-zsh/custom/topics/mytopic.zsh.tmpl

{{- if .is_macos }}
# macOS-specific settings
alias finder='open .'
{{- end }}

{{- if .is_linux }}
# Linux-specific settings
alias open='xdg-open'
{{- end }}

{{- if .is_wsl }}
# WSL-specific settings
alias explorer='explorer.exe .'
{{- end }}
```

---

## Removing What You Don't Need

### Remove a Tool

1. Delete from `Brewfile`/`Brewfile.darwin`/`Brewfile.linux`
2. Remove any config files (e.g., `rm -r dot_config/toolname/`)
3. Remove shell integrations from `dot_zshrc.tmpl` or topic files

### Remove a Topic

```bash
# Simply delete the topic file
rm dot_oh-my-zsh/custom/topics/docker.zsh
```

### Remove Platform Support

If you only use macOS, you can:

1. Delete `Brewfile.linux`
2. Remove Linux conditionals from `.tmpl` files
3. Simplify `.chezmoi.toml.tmpl`

### Simplify the Setup

Don't need all the features? Remove:

- `dot_tmux.conf` - if you don't use tmux
- `dot_config/broot/` - if you don't use broot
- `dot_config/iterm2/` - if you don't use iTerm2
- `dot_stignore` - if you don't use Syncthing
- `scripts/macos-defaults.sh` - if you don't want system preferences changed

---

## Testing Your Changes

### Before Committing

```bash
# Check template syntax
chezmoi execute-template < dot_zshrc.tmpl > /dev/null && echo "OK"

# Preview what would be applied
chezmoi diff

# Dry run
chezmoi apply --dry-run --verbose
```

### Test Locally

```bash
# Apply changes
chezmoi apply

# Source shell config
source ~/.zshrc

# Verify aliases work
alias | grep youralias
```

### Test on Fresh System

The best test is a fresh VM or container:

```bash
# Docker test (quick)
docker run -it ubuntu:22.04 bash
# Then run your bootstrap script

# Or use a fresh WSL instance
wsl --install -d Ubuntu-22.04
```

---

## Keeping Up with Upstream

If you want to pull updates from the original repo:

### One-Time Setup

```bash
# Add upstream remote
git remote add upstream https://github.com/nceresole/dotfiles.git
```

### Pulling Updates

```bash
# Fetch upstream changes
git fetch upstream

# Merge (or rebase) into your branch
git merge upstream/main
# or
git rebase upstream/main

# Resolve any conflicts
# Your customizations in .chezmoi.toml.tmpl, Brewfiles, etc. may conflict

# Push to your fork
git push
```

### Cherry-Pick Specific Changes

If you only want specific updates:

```bash
# View upstream commits
git log upstream/main --oneline

# Cherry-pick specific commits
git cherry-pick <commit-hash>
```

---

## Tips for Maintaining Your Fork

1. **Keep identity separate** - All personal info should be in `.chezmoi.toml.tmpl` defaults and `bootstrap.sh`. This makes merging easier.

2. **Use local override files** - For machine-specific settings, use:
   - `~/.zshrc.local`
   - `~/.gitconfig.local`
   - `~/.ssh/config.local`

3. **Document your changes** - Update the docs to reflect your setup.

4. **Test before applying** - Always use `chezmoi diff` before `chezmoi apply`.

5. **Commit often** - Small, focused commits make it easier to track changes.

---

## Need Help?

- [chezmoi documentation](https://chezmoi.io/docs/)
- [chezmoi GitHub discussions](https://github.com/twpayne/chezmoi/discussions)
- File an issue on this repo
