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
