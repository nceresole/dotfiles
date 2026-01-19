# Customization Guide

This guide explains how to customize the dotfiles for your needs.

## Table of Contents

- [Quick Customizations](#quick-customizations)
- [Machine-Specific Settings](#machine-specific-settings)
- [Adding New Tools](#adding-new-tools)
- [Creating Topic Files](#creating-topic-files)
- [Working with Templates](#working-with-templates)
- [Managing Secrets](#managing-secrets)
- [Project Scaffolding Functions](#project-scaffolding-functions)

---

## Quick Customizations

### Change Your Identity

```bash
chezmoi edit-config
```

Edit the `[data]` section:

```toml
[data]
    name = "Your Name"
    email = "your.email@example.com"
```

Then re-apply:

```bash
chezmoi apply
```

### Change Default Editor

Edit `dot_oh-my-zsh/custom/exports.zsh.tmpl`:

```bash
chezmoi edit ~/.oh-my-zsh/custom/exports.zsh
```

Change:

```bash
export EDITOR='nano'
export VISUAL='nano'
```

To your preferred editor:

```bash
export EDITOR='nvim'
export VISUAL='nvim'
```

### Add Shell Aliases

Edit the appropriate topic file or create `~/.zshrc.local`:

```bash
# Quick: add to local file (not tracked)
echo "alias myproject='cd ~/projects/myproject'" >> ~/.zshrc.local

# Or: add to tracked topic file
chezmoi edit ~/.oh-my-zsh/custom/topics/navigation.zsh
```

---

## Machine-Specific Settings

Use `.local` files for settings that shouldn't sync across machines:

### `~/.zshrc.local`

```bash
# Work machine settings
export WORK_DIR="$HOME/work"
alias vpn='sudo openconnect vpn.company.com'

# Project shortcuts
alias myapp='cd ~/projects/myapp && code .'
```

### `~/.gitconfig.local`

```ini
# Work email for this machine
[user]
    email = nicolas@company.com

# Work-specific signing
[commit]
    gpgsign = true
```

### `~/.ssh/config.local`

```
# Work servers
Host prod
    HostName production.company.com
    User deploy
    IdentityFile ~/.ssh/id_work

Host staging
    HostName staging.company.com
    User deploy
    IdentityFile ~/.ssh/id_work
```

---

## Adding New Tools

### Add a CLI Tool

1. Add to `Brewfile`:

```bash
chezmoi edit ~/.local/share/chezmoi/Brewfile
```

```ruby
brew "neovim"
brew "lazygit"
```

2. Install:

```bash
brew bundle --file=~/.local/share/chezmoi/Brewfile
```

### Add a macOS App

1. Add to `Brewfile.darwin`:

```bash
chezmoi edit ~/.local/share/chezmoi/Brewfile.darwin
```

```ruby
cask "spotify"
cask "slack"
```

2. Install:

```bash
brew bundle --file=~/.local/share/chezmoi/Brewfile.darwin
```

### Add Tool Configuration

1. Configure the tool manually first
2. Add to chezmoi:

```bash
chezmoi add ~/.config/nvim
chezmoi add ~/.config/lazygit/config.yml
```

### Add Tool Integration to Shell

Edit `dot_zshrc.tmpl` to add initialization:

```bash
# lazygit
if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi
```

---

## Creating Topic Files

### When to Create a New Topic

Create a new topic when you have:
- Multiple related aliases
- Related functions
- Tool-specific configuration

### Creating a Non-Templated Topic

For configuration that's the same across all platforms:

```bash
chezmoi edit ~/.local/share/chezmoi/dot_oh-my-zsh/custom/topics/rust.zsh
```

```bash
# =============================================================================
# Rust Configuration
# Topic: rust.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cbr='cargo build --release'

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Create new Rust project
newrust() {
    if [ -z "$1" ]; then
        echo "Usage: newrust <project-name>"
        return 1
    fi
    cargo new "$1"
    cd "$1"
    echo "Created Rust project: $1"
}
```

### Creating a Templated Topic

For platform-specific configuration:

```bash
chezmoi edit ~/.local/share/chezmoi/dot_oh-my-zsh/custom/topics/cloud.zsh.tmpl
```

```bash
# =============================================================================
# Cloud Tools Configuration
# Topic: cloud.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# AWS
# -----------------------------------------------------------------------------
{{- if or .is_macos .is_linux }}
if command -v aws &>/dev/null; then
    alias awswho='aws sts get-caller-identity'

    # AWS profile switcher
    awsp() {
        export AWS_PROFILE="$1"
        echo "Switched to AWS profile: $AWS_PROFILE"
    }
fi
{{- end }}

# -----------------------------------------------------------------------------
# kubectl
# -----------------------------------------------------------------------------
if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    alias kg='kubectl get'
    alias kd='kubectl describe'
    alias kl='kubectl logs -f'

{{- if .is_macos }}
    # macOS: use keychain for kubectl credentials
    export KUBECONFIG="$HOME/.kube/config"
{{- end }}
fi
```

---

## Working with Templates

### Adding Platform Checks

Common patterns:

```go
{{- if .is_macos }}
# macOS only
{{- end }}

{{- if .is_linux }}
# Linux only
{{- end }}

{{- if .is_wsl }}
# WSL only
{{- end }}

{{- if or .is_linux .is_wsl }}
# Linux or WSL
{{- end }}

{{- if not .is_macos }}
# Everything except macOS
{{- end }}
```

### Using Variables

```go
# User info
{{ .name }}
{{ .email }}

# Paths
{{ .homebrew_prefix }}
{{ .chezmoi.homeDir }}
{{ .chezmoi.sourceDir }}

# System info
{{ .chezmoi.os }}
{{ .chezmoi.arch }}
{{ .chezmoi.hostname }}
```

### Adding New Template Variables

1. Edit `.chezmoi.toml.tmpl`:

```bash
chezmoi edit ~/.local/share/chezmoi/.chezmoi.toml.tmpl
```

Add a new variable:

```go
{{- $work_machine := promptBoolOnce . "work_machine" "Is this a work machine" false -}}

[data]
    # ... existing data ...
    work_machine = {{ $work_machine }}
```

2. Re-initialize:

```bash
chezmoi init
```

3. Use in templates:

```go
{{- if .work_machine }}
# Work-specific settings
export CORPORATE_PROXY="http://proxy.company.com:8080"
{{- end }}
```

### Testing Templates

```bash
# Test full template
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Test snippet
echo '{{ if .is_macos }}macOS{{ else }}not macOS{{ end }}' | chezmoi execute-template

# See all available data
chezmoi data
```

---

## Managing Secrets

### Initial Setup

```bash
# Generate encryption key (once)
age-keygen -o ~/.config/chezmoi/key.txt

# IMPORTANT: Back up this key securely!
# Without it, you can't decrypt your secrets on new machines
```

### Adding Encrypted Files

```bash
# SSH keys
chezmoi add --encrypt ~/.ssh/id_ed25519_github
chezmoi add --encrypt ~/.ssh/id_ed25519_gitlab

# API keys file
chezmoi add --encrypt ~/.secrets

# Environment file
chezmoi add --encrypt ~/.env.secret
```

### Structure for Secrets

Create `~/.secrets` for API keys:

```bash
# ~/.secrets - Encrypted by chezmoi
export OPENAI_API_KEY='sk-...'
export GITHUB_TOKEN='ghp_...'
export AWS_ACCESS_KEY_ID='AKIA...'
export AWS_SECRET_ACCESS_KEY='...'
```

Source it in your shell config (already done in `exports.zsh.tmpl`):

```bash
if [[ -f ~/.secrets ]]; then
    source ~/.secrets
fi
```

### On New Machines

1. Copy your `key.txt` to `~/.config/chezmoi/key.txt`
2. Run `chezmoi apply` - files are decrypted automatically

### Rotating Keys

```bash
# Generate new key
age-keygen -o ~/.config/chezmoi/key-new.txt

# Re-encrypt all files with new key
chezmoi re-add --encrypt

# Replace old key
mv ~/.config/chezmoi/key-new.txt ~/.config/chezmoi/key.txt
```

---

## Project Scaffolding Functions

The dotfiles include ready-to-use functions for creating new projects with common setups.

### Python Projects

| Command | Description |
|---------|-------------|
| `newpy <name>` | Create Python project with uv, .venv, and .python-version (3.12) |
| `newfastapi <name>` | Full FastAPI project with app structure, uvicorn, SQLAlchemy |

**Example:**
```bash
newpy myproject
# Creates: myproject/.venv, pyproject.toml, .python-version (3.12)

newfastapi myapi
# Creates: myapi/app/{api,models,schemas,services}, main.py, .env
# Run with: uvicorn app.main:app --reload
```

### Node.js/TypeScript Projects

| Command | Description |
|---------|-------------|
| `newnode <name>` | Basic Node.js project with npm init |
| `newts <name>` | TypeScript project with tsconfig, nodemon, ts-node |
| `newnext <name>` | Next.js + TypeScript + Tailwind + App Router |
| `newvite <name>` | Vite + React + TypeScript |
| `newexpress <name>` | Express + TypeScript API with cors, dotenv |

**Example:**
```bash
newts mylib
# Creates: mylib/src/index.ts, tsconfig.json, package.json
# Scripts: npm run dev (nodemon), npm run build (tsc)

newnext myapp
# Uses create-next-app with --typescript --tailwind --eslint --app --src-dir

newvite mysite
# Uses Vite's react-ts template

newexpress myapi
# Creates: myapi/src/index.ts with Express server, routes/, middleware/
# Includes: cors, dotenv, @types/*, nodemon
```

### Utility Functions

| Command | Description |
|---------|-------------|
| `ncu` | Update all npm packages (uses npm-check-updates) |
| `nclean` | Remove node_modules and reinstall |
| `serve [port]` | Quick Python HTTP server (default: 8000) |

---

## Best Practices

### Do

- Use `.local` files for machine-specific settings
- Create topic files for related aliases/functions
- Test templates before committing
- Keep secrets encrypted
- Document unusual configurations

### Don't

- Hardcode machine-specific paths in tracked files
- Store unencrypted secrets
- Make large changes without testing
- Forget to commit after `chezmoi add`

### Workflow

```bash
# 1. Make changes
chezmoi edit ~/.zshrc

# 2. Test locally
chezmoi diff
chezmoi apply

# 3. Verify it works
source ~/.zshrc

# 4. Commit
chezmoi cd
git add -A
git commit -m "Add new alias"
git push
```
