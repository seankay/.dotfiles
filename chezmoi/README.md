# ChezMoi Dotfiles

Initialize chezmoi to use this source:

```bash
chezmoi init --source="${PWD}/chezmoi" --apply
```

## Structure

- `chezmoi.yaml.tmpl` – defaults for all hosts (edit templates under `.chezmoitemplates/` if needed).
- `dotfiles/` – plain files that will be applied to `$HOME` (zshrc, gitconfig, tmux.conf, etc.).
- Add host- or OS-specific configurations via `dotfiles/.config/<feature>/<file>.tmpl` and conditionals in templates.
- `chezmoiscripts/` contains setup helpers; `run_once_install_gh_notify.sh.tmpl` installs the GitHub CLI notification extension when `gh` is present.

Templates can use built-in `chezmoi` variables such as `.chezmoi.os` or `.chezmoi.hostname`. Example snippet:

```tmpl
{{ if eq .chezmoi.os "darwin" }}
export HOMEBREW_PREFIX="/opt/homebrew"
{{ end }}
```

> **Note:** Update `data.age_recipient` in `chezmoi.yaml.tmpl` to match your Age public key if you plan to encrypt files.

## Local overrides

Set machine- or identity-specific values in `~/.config/dotfiles/local.env` (read by zsh and available to templates). Example:

```bash
export MACHINE_ROLE=work # still used by other scripts (e.g., Brewfile selection)

export GIT_NAME="Sean Kay"
export GIT_EMAIL="email@example.com"
export GIT_SIGNING_KEY="ssh-ed25519 AAAA..."
# Optional: force a specific SSH key for git
export GIT_SSH_KEY="$HOME/.ssh/id_ed25519_work"
# Optional: rewrite github.com to an SSH host alias (e.g., github.com-work)
export GIT_GITHUB_HOST_ALIAS="github.com-work"
```
