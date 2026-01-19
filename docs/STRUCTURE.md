# Directory Structure

This document explains the organization of the dotfiles repository.

## Overview

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl          # chezmoi configuration template
├── .chezmoiexternal.toml       # External dependencies (zsh plugins)
├── .chezmoiignore              # Files to ignore when applying
├── .chezmoiscripts/            # Scripts that run during apply
├── docs/                       # Documentation
├── scripts/                    # Utility scripts
│
├── Brewfile                    # Cross-platform packages
├── Brewfile.darwin             # macOS-specific packages
├── Brewfile.linux              # Linux-specific packages
│
├── dot_zshrc.tmpl              # → ~/.zshrc
├── dot_zprofile.tmpl           # → ~/.zprofile
├── dot_gitconfig.tmpl          # → ~/.gitconfig
├── dot_hushlogin               # → ~/.hushlogin
├── dot_tmux.conf               # → ~/.tmux.conf
├── dot_stignore                # → ~/.stignore (Syncthing)
│
├── private_dot_ssh/            # → ~/.ssh/
│   └── config.tmpl             # → ~/.ssh/config
│
├── dot_config/                 # → ~/.config/
│   ├── starship/               # Prompt configuration
│   ├── broot/                  # File manager
│   ├── btop/                   # System monitor
│   ├── gh/                     # GitHub CLI
│   ├── iterm2/                 # iTerm2 profile (macOS)
│   └── Code/User/              # VS Code settings
│
└── dot_oh-my-zsh/custom/       # → ~/.oh-my-zsh/custom/
    ├── topics/                 # Topic-based shell configs
    ├── exports.zsh.tmpl        # Environment variables
    ├── paths.zsh.tmpl          # PATH modifications
    └── completions/            # Custom completions
```

---

## Configuration Files

### `.chezmoi.toml.tmpl`

The main chezmoi configuration. Prompts for user data on first run:

- Full name (default: Nicolas Ceresole)
- Email (default: nceresole.dev@gmail.com)

Auto-detects:
- Platform (macOS, Linux, WSL)
- Homebrew prefix location

### `.chezmoiexternal.toml`

Manages external dependencies (downloaded from URLs):

- zsh-autosuggestions
- fast-syntax-highlighting
- zsh-completions

These are downloaded automatically on `chezmoi apply`.

### `.chezmoiignore`

Files in the source that shouldn't be copied to home:

- `README.md`, `docs/`
- `scripts/`, `Brewfile*`
- Platform-specific ignores (e.g., macOS scripts on Linux)

---

## Shell Configuration

### Loading Order

```
1. ~/.zprofile          # Login shell (once per session)
   ├── Homebrew setup
   ├── pyenv, nvm, cargo
   └── Local profile (~/.zprofile.local)

2. ~/.zshrc             # Interactive shell (every terminal)
   ├── Oh My Zsh
   ├── Plugins (syntax highlighting, autosuggestions)
   ├── Topic files (git, python, docker, etc.)
   ├── Integrations (fzf, starship, zoxide, etc.)
   └── Local config (~/.zshrc.local)
```

### Topic Files

Shell configuration is split by topic for maintainability:

| File | Contents |
|------|----------|
| `topics/git.zsh` | Git aliases (`gs`, `ga`, `gc`), functions (`qcommit`, `qpush`) |
| `topics/python.zsh` | Python/uv aliases, `newpy`, `newfastapi` scaffolding |
| `topics/node.zsh.tmpl` | fnm setup, npm/pnpm/bun aliases, `newts`, `newnext`, `newvite`, `newexpress` |
| `topics/docker.zsh` | Docker/compose aliases and functions |
| `topics/navigation.zsh` | eza/bat/zoxide setup, file utilities |
| `topics/platform.zsh.tmpl` | Platform-specific settings (macOS/Linux/WSL) |

### Template Files (`.tmpl`)

Files ending in `.tmpl` are rendered with platform-specific content:

- `exports.zsh.tmpl` - Homebrew settings based on platform
- `paths.zsh.tmpl` - PATH entries for different platforms
- `node.zsh.tmpl` - fnm paths differ on macOS vs Linux
- `platform.zsh.tmpl` - Completely different content per platform

---

## Scripts

### `.chezmoiscripts/`

Scripts that run automatically during `chezmoi apply`:

| Script | When | Purpose |
|--------|------|---------|
| `run_once_before_00-install-packages.sh.tmpl` | Before apply, once | Install Homebrew packages |
| `run_once_after_darwin-defaults.sh.tmpl` | After apply, once | Apply macOS preferences |

Naming convention:
- `run_once_` - Only runs once (tracked by chezmoi)
- `before_` / `after_` - When to run relative to file changes
- `00-` - Ordering (lower numbers run first)
- `.tmpl` - Platform-specific (only generates on matching OS)

### `scripts/`

Standalone utility scripts (not auto-run):

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | One-command installer for new machines |
| `macos-defaults.sh` | Apply macOS system preferences |

---

## Brewfiles

### `Brewfile` (Cross-platform)

Core CLI tools installed everywhere:

```
bat, eza, fzf, ripgrep      # Modern CLI replacements
starship, zoxide            # Shell enhancements
git, gh, delta              # Git tools
python@3.12, uv             # Python
fnm                         # Node version manager
chezmoi, age                # Dotfiles & encryption
```

### `Brewfile.darwin` (macOS only)

GUI applications and macOS-specific tools:

```
# CLI
mas, trash, duti

# Apps
iterm2, visual-studio-code, raycast, rectangle
docker, postman, tableplus
1password, arc, obsidian, notion

# Fonts
font-jetbrains-mono-nerd-font
font-fira-code-nerd-font
```

### `Brewfile.linux` (Linux/WSL only)

```
keychain                    # SSH key management
xclip                       # Clipboard (X11)
```

---

## Config Directories

### `dot_config/starship/`

Starship prompt configuration with Nord color palette.

### `dot_config/broot/`

Terminal file manager configuration:
- `conf.hjson` - Main config
- `verbs.hjson` - Custom commands
- `skins/` - Color themes

### `dot_config/btop/`

System monitor configuration.

### `dot_config/gh/`

GitHub CLI settings and aliases.

### `dot_config/iterm2/`

iTerm2 terminal profile (macOS only):
- `kdash.json` - Custom profile with Fira Code font, light/dark mode colors

### `dot_config/Code/User/`

VS Code configuration:
- `settings.json` - Editor settings, themes, formatters, language configs
- `extensions.txt` - Recommended extensions list

Install extensions with:
```bash
cat ~/.config/Code/User/extensions.txt | xargs -L 1 code --install-extension
```

---

## Terminal Multiplexer

### `dot_tmux.conf`

tmux configuration with:
- Prefix: `Ctrl-a` (like screen)
- Vim-style pane navigation (`h`, `j`, `k`, `l`)
- Mouse support enabled
- Split panes: `|` (vertical), `-` (horizontal)
- Nord-inspired status bar theme
- Fast escape time for vim users

---

## File Sync

### `dot_stignore`

Syncthing ignore patterns for:
- macOS garbage (`.DS_Store`, `._*`, `.Spotlight-V100`)
- Windows garbage (`Thumbs.db`, `desktop.ini`, `$RECYCLE.BIN`)
- Linux garbage (`.Trash-*`, `.directory`)
- Development files (`node_modules/`, `.venv/`, `__pycache__/`)
- Temporary files (`*.tmp`, `*.bak`, `*.swp`)

---

## Private Files

### `private_dot_ssh/`

SSH configuration (mode 600):
- `config.tmpl` - SSH config with platform-specific settings
  - `UseKeychain yes` only on macOS
  - GitHub and GitLab host configurations

**Note:** Private keys are NOT stored in the repo. Only the config file is managed.

---

## Local Overrides

These files are not managed by chezmoi but are sourced if they exist:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Machine-specific shell settings |
| `~/.zprofile.local` | Machine-specific login settings |
| `~/.gitconfig.local` | Machine-specific git config |
| `~/.ssh/config.local` | Machine-specific SSH hosts |
| `~/.secrets` | API keys and secrets |

This allows customization without modifying managed files.
