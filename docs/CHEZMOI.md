# chezmoi Guide

**chezmoi** (French for "at my home") is a dotfiles manager that helps you manage your configuration files across multiple machines.

## Table of Contents

- [Core Concepts](#core-concepts)
- [Naming Conventions](#naming-conventions)
- [Templates](#templates)
- [Common Workflows](#common-workflows)
- [Command Reference](#command-reference)

---

## Core Concepts

### Source vs Target

```
Source (chezmoi manages)          Target (your home directory)
~/.local/share/chezmoi/           ~/
├── dot_zshrc.tmpl          →     .zshrc
├── dot_gitconfig.tmpl      →     .gitconfig
├── private_dot_ssh/        →     .ssh/
└── dot_config/             →     .config/
```

- **Source directory**: Where chezmoi stores your dotfiles (a git repo)
- **Target directory**: Your home directory where files get applied

### How It Works

1. You store dotfiles in `~/.local/share/chezmoi/` (the source)
2. chezmoi transforms filenames (e.g., `dot_zshrc` → `.zshrc`)
3. Templates are rendered with your machine-specific data
4. Files are copied/symlinked to your home directory (the target)

---

## Naming Conventions

chezmoi uses special prefixes to control how files are managed:

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | Becomes `.` | `dot_zshrc` → `.zshrc` |
| `private_` | chmod 600 (owner only) | `private_dot_ssh` → `.ssh` |
| `executable_` | chmod +x | `executable_script.sh` |
| `readonly_` | chmod 444 | `readonly_config` |
| `exact_` | Remove extra files in dir | `exact_dot_config` |
| `empty_` | Create empty file | `empty_dot_hushlogin` |
| `symlink_` | Create symlink | `symlink_dot_config` |
| `modify_` | Modify existing file | `modify_dot_zshrc` |
| `create_` | Create if doesn't exist | `create_dot_env` |
| `remove_` | Remove file | `remove_dot_oldconfig` |
| `run_` | Execute script | `run_install.sh` |
| `run_once_` | Execute only once | `run_once_setup.sh` |
| `run_onchange_` | Execute when content changes | `run_onchange_install.sh` |

### File Extensions

| Extension | Meaning |
|-----------|---------|
| `.tmpl` | Go template (rendered with data) |
| `.literal` | Treat literally (no processing) |

### Combined Examples

```
private_dot_ssh/config.tmpl
  → ~/.ssh/config (private, templated)

run_once_before_00-install.sh.tmpl
  → Runs once before applying, templated

exact_dot_config/htop
  → ~/.config/htop (removes unmanaged files in dir)
```

---

## Templates

Templates use Go's `text/template` syntax to customize files per-machine.

### Basic Syntax

```go
{{ .variableName }}              // Insert variable
{{ if .condition }}...{{ end }}  // Conditional
{{ if eq .os "darwin" }}...{{ end }}  // Equality check
{{- ... -}}                      // Trim whitespace
```

### Available Variables

View all available data:

```bash
chezmoi data
```

Common variables in this setup:

| Variable | Description | Example |
|----------|-------------|---------|
| `.name` | Your full name | `Nicolas Ceresole` |
| `.email` | Your email | `nceresole.dev@gmail.com` |
| `.is_macos` | Running on macOS | `true`/`false` |
| `.is_linux` | Running on Linux | `true`/`false` |
| `.is_wsl` | Running in WSL | `true`/`false` |
| `.homebrew_prefix` | Homebrew location | `/opt/homebrew` |
| `.chezmoi.os` | Operating system | `darwin`, `linux` |
| `.chezmoi.arch` | Architecture | `amd64`, `arm64` |
| `.chezmoi.hostname` | Machine hostname | `MacBook-Pro` |

### Template Examples

**Conditional content:**

```go
{{ if .is_macos }}
# macOS-specific configuration
alias update='brew update && brew upgrade'
{{ else if .is_linux }}
# Linux-specific configuration
alias update='sudo apt update && sudo apt upgrade'
{{ end }}
```

**Variable substitution:**

```go
[user]
    name = {{ .name }}
    email = {{ .email }}
```

**With whitespace control:**

```go
{{- if .is_macos }}
UseKeychain yes
{{- end }}
```

### Testing Templates

```bash
# Preview rendered output
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Test a template snippet
echo '{{ .chezmoi.os }}' | chezmoi execute-template
```

---

## Common Workflows

### 1. Initial Setup (New Machine)

**One-liner:**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nceresole
```

**Or step by step:**

```bash
# Install chezmoi
brew install chezmoi

# Clone dotfiles and generate config
chezmoi init nceresole

# Preview changes
chezmoi diff

# Apply
chezmoi apply
```

### 2. Daily Editing

```bash
# Edit a managed file
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply

# Or edit + apply together
chezmoi edit --apply ~/.zshrc
```

### 3. Adding New Files

```bash
# Add a regular file
chezmoi add ~/.config/app/config.yml

# Add as template (for platform-specific content)
chezmoi add --template ~/.bashrc

# Add with encryption (for secrets)
chezmoi add --encrypt ~/.ssh/id_ed25519_github

# Add entire directory
chezmoi add ~/.config/nvim
```

### 4. Syncing Across Machines

**Push changes (machine A):**

```bash
cd ~/.local/share/chezmoi
git add .
git commit -m "Update zsh config"
git push
```

**Pull changes (machine B):**

```bash
# Pull and apply in one command
chezmoi update

# Or step by step
chezmoi git pull
chezmoi diff
chezmoi apply
```

### 5. Working with Secrets

**Initial setup:**

```bash
# Generate encryption key (once per machine)
age-keygen -o ~/.config/chezmoi/key.txt

# Back up this key securely!
```

**Add encrypted files:**

```bash
chezmoi add --encrypt ~/.ssh/id_ed25519_github
chezmoi add --encrypt ~/.secrets
```

**On new machines:**

```bash
# Copy your key.txt to ~/.config/chezmoi/key.txt
# Then apply - files are decrypted automatically
chezmoi apply
```

### 6. Re-running Scripts

```bash
# Force re-run all scripts
chezmoi apply --force

# Re-run a specific script type
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### 7. Troubleshooting

```bash
# See what chezmoi would do (dry run)
chezmoi apply --dry-run --verbose

# Check for errors in templates
chezmoi verify

# See the source state
chezmoi source-path ~/.zshrc

# Compare source vs target
chezmoi diff ~/.zshrc
```

---

## Command Reference

### Essential Commands

| Command | Description |
|---------|-------------|
| `chezmoi init <user>` | Initialize with GitHub dotfiles |
| `chezmoi apply` | Apply changes to home directory |
| `chezmoi update` | Pull from git and apply |
| `chezmoi diff` | Show pending changes |
| `chezmoi status` | Show modified files |
| `chezmoi add <file>` | Add file to chezmoi |
| `chezmoi edit <file>` | Edit managed file |
| `chezmoi cd` | Open source directory |

### Information Commands

| Command | Description |
|---------|-------------|
| `chezmoi managed` | List all managed files |
| `chezmoi unmanaged` | List unmanaged files in home |
| `chezmoi data` | Show template data |
| `chezmoi doctor` | Check for problems |
| `chezmoi source-path <file>` | Show source path for file |

### Git Commands

| Command | Description |
|---------|-------------|
| `chezmoi git status` | Git status in source dir |
| `chezmoi git add .` | Stage changes |
| `chezmoi git commit -m "msg"` | Commit changes |
| `chezmoi git push` | Push to remote |
| `chezmoi git pull` | Pull from remote |

### Advanced Commands

| Command | Description |
|---------|-------------|
| `chezmoi execute-template` | Test template rendering |
| `chezmoi merge <file>` | Merge changes interactively |
| `chezmoi forget <file>` | Stop managing a file |
| `chezmoi re-add` | Re-add modified files |
| `chezmoi archive` | Create archive of target state |

### Flags

| Flag | Description |
|------|-------------|
| `--dry-run` | Don't make changes, just show |
| `--verbose` | Show detailed output |
| `--force` | Force re-run scripts |
| `--refresh-externals` | Update external dependencies |

---

## Learn More

- [Official Documentation](https://chezmoi.io/docs/)
- [Quick Start Guide](https://chezmoi.io/quick-start/)
- [User Guide](https://chezmoi.io/user-guide/)
- [Reference](https://chezmoi.io/reference/)
