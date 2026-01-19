# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io).

Supports **macOS**, **Linux**, and **WSL** with automatic platform detection.

## Documentation

| Document | Description |
|----------|-------------|
| [CHEZMOI.md](docs/CHEZMOI.md) | Complete chezmoi guide and command reference |
| [STRUCTURE.md](docs/STRUCTURE.md) | Directory structure and file organization |
| [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) | How to customize for your needs |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues and solutions |

## Quick Start

```bash
# One-liner installation
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nceresole/dotfiles/main/.local/share/chezmoi/scripts/bootstrap.sh)"
```

Or with chezmoi directly:

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nceresole
```

## Manual Installation

1. **Install chezmoi**
   ```bash
   # macOS/Linux with Homebrew
   brew install chezmoi

   # Or standalone
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. **Initialize dotfiles**
   ```bash
   chezmoi init https://github.com/nceresole/dotfiles.git
   ```

3. **Preview changes**
   ```bash
   chezmoi diff
   ```

4. **Apply dotfiles**
   ```bash
   chezmoi apply
   ```

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl          # Config with platform detection
├── .chezmoiexternal.toml       # Oh My Zsh + plugins
├── .chezmoiscripts/            # Run scripts
│   ├── run_once_before_00-install-packages.sh.tmpl
│   └── run_once_after_darwin-defaults.sh.tmpl
│
├── dot_zshrc.tmpl              # Main shell config
├── dot_zprofile.tmpl           # Login shell
├── dot_gitconfig.tmpl          # Git config
├── dot_hushlogin               # Suppress login message
│
├── private_dot_ssh/config.tmpl # SSH config
│
├── dot_config/
│   ├── starship/               # Prompt theming
│   ├── broot/                  # File manager
│   ├── btop/                   # System monitor
│   └── gh/                     # GitHub CLI
│
├── dot_oh-my-zsh/custom/
│   ├── topics/                 # Topic-based organization
│   │   ├── git.zsh             # Git aliases + functions
│   │   ├── python.zsh          # Python/uv/FastAPI
│   │   ├── node.zsh.tmpl       # Node.js (platform-specific)
│   │   ├── docker.zsh          # Docker aliases
│   │   ├── navigation.zsh      # File management
│   │   └── platform.zsh.tmpl   # macOS/Linux/WSL specifics
│   ├── exports.zsh.tmpl
│   └── paths.zsh.tmpl
│
├── Brewfile                    # Cross-platform packages
├── Brewfile.darwin             # macOS casks & fonts
├── Brewfile.linux              # Linux-specific
│
└── scripts/
    ├── bootstrap.sh            # One-command installer
    └── macos-defaults.sh       # macOS system preferences
```

## Common Commands

```bash
# View current state
chezmoi status

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply

# Edit a managed file
chezmoi edit ~/.zshrc

# Add a new file to management
chezmoi add ~/.config/app/config

# Add an encrypted file
chezmoi add --encrypt ~/.ssh/id_ed25519_github

# Pull and apply latest changes
chezmoi update

# Re-run templates (after changing data)
chezmoi init

# See what chezmoi would do
chezmoi apply --dry-run --verbose
```

## Customization

### Machine-Specific Settings

Create `~/.zshrc.local` for machine-specific configurations:

```bash
# ~/.zshrc.local
export WORK_PROJECT_DIR="~/work/projects"
alias myproject="cd $WORK_PROJECT_DIR/myapp"
```

### Git Identity

The git config prompts for your name and email on first run. To update:

```bash
chezmoi edit-config
# Edit the [data] section, then:
chezmoi apply
```

### Secrets Management

For sensitive data, use age encryption:

```bash
# Generate encryption key (one-time)
age-keygen -o ~/.config/chezmoi/key.txt

# Add encrypted file
chezmoi add --encrypt ~/.secrets

# The key is needed to decrypt on other machines
```

## Topic Files

Shell configuration is organized by topic for better maintainability:

| Topic | Contents |
|-------|----------|
| `git.zsh` | Git aliases, qcommit, qpush functions |
| `python.zsh` | Python/uv aliases, newpy, newfastapi |
| `node.zsh.tmpl` | fnm setup, npm aliases |
| `docker.zsh` | Docker/compose aliases |
| `navigation.zsh` | eza/bat/zoxide, file utilities |
| `platform.zsh.tmpl` | macOS/Linux/WSL-specific settings |

## Included Tools

### CLI Replacements
- **bat** - Better `cat` with syntax highlighting
- **eza** - Better `ls` with icons and git status
- **zoxide** - Smarter `cd` that learns your habits
- **delta** - Better `git diff` viewer
- **ripgrep** - Faster `grep`
- **fd** - Faster `find`

### Shell
- **Starship** - Cross-shell prompt
- **fzf** - Fuzzy finder
- **direnv** - Per-directory environment
- **fnm** - Fast Node Manager

### Development
- **uv** - Fast Python package manager
- **gh** - GitHub CLI
- **broot** - Terminal file manager

## Troubleshooting

### chezmoi diff shows unexpected changes

```bash
# Verify template output
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Check data values
chezmoi data
```

### Homebrew packages not installing

```bash
# Run package installation manually
~/.local/share/chezmoi/.chezmoiscripts/run_once_before_00-install-packages.sh.tmpl
```

### Oh My Zsh plugins missing

```bash
# Force external dependency update
chezmoi update --refresh-externals
```

### Platform detection issues

```bash
# Check detected values
chezmoi data | grep -E "is_macos|is_linux|is_wsl"
```

## Updating

```bash
# Pull latest and apply
chezmoi update

# Or step by step
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

## Contributing

1. Make changes to files in `~/.local/share/chezmoi/`
2. Test with `chezmoi diff` and `chezmoi apply`
3. Commit and push

## Documentation

For detailed guides, see the `docs/` folder:

- **[CHEZMOI.md](docs/CHEZMOI.md)** - How chezmoi works, concepts, and full command reference
- **[STRUCTURE.md](docs/STRUCTURE.md)** - Explanation of every file and directory
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** - How to add tools, create topics, manage secrets
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Solutions to common problems

## License

MIT
