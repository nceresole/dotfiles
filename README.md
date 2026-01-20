# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io).

Supports **macOS**, **Linux**, and **WSL** with automatic platform detection.

## Quick Start

```bash
# One-liner installation
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nceresole/dotfiles/main/scripts/bootstrap.sh)"
```

Or with chezmoi directly:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nceresole
```

## What's Included

### Shell (zsh + Oh My Zsh)
- Topic-based configuration (git, python, node, docker, navigation)
- Platform-specific settings for macOS/Linux/WSL
- Project scaffolding functions (`newpy`, `newfastapi`, `newts`, `newnext`, `newvite`, `newexpress`)

### CLI Tools
- **Modern replacements**: bat, eza, zoxide, ripgrep, fd, delta
- **Shell enhancements**: Starship prompt, fzf, direnv
- **Development**: uv (Python), fnm (Node), gh (GitHub CLI)
- **Utilities**: tmux, broot, btop

### Configurations
- Git with platform-specific credential helpers
- SSH with macOS Keychain integration
- VS Code settings and extensions
- Starship prompt (Nord theme)
- tmux (Ctrl-a prefix, vim keybindings)

## Documentation

| Document | Description |
|----------|-------------|
| [Installation](docs/INSTALLATION.md) | Step-by-step setup for WSL, macOS, Linux |
| [Forking Guide](docs/FORKING.md) | How to fork and personalize this repo |
| [Structure](docs/STRUCTURE.md) | Directory layout and file organization |
| [Customization](docs/CUSTOMIZATION.md) | Adding tools, creating topics, managing secrets |
| [Chezmoi Guide](docs/CHEZMOI.md) | Chezmoi concepts and command reference |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions |

## Common Commands

```bash
chezmoi status              # View current state
chezmoi diff                # Preview changes
chezmoi apply               # Apply changes
chezmoi edit ~/.zshrc       # Edit a managed file
chezmoi add ~/.config/tool  # Add new file to management
chezmoi update              # Pull and apply latest
```

## Local Overrides

Machine-specific settings go in `.local` files (not tracked by git):

```bash
~/.zshrc.local          # Shell customizations
~/.gitconfig.local      # Git settings (e.g., work email)
~/.ssh/config.local     # SSH hosts
~/.secrets              # API keys (source in .zshrc)
```

## License

MIT
