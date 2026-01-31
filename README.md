# Cross-Platform Dotfiles with Bash + Symlinks

This stack keeps dotfiles portable across macOS and Linux while staying close to native tooling.

- **Dotfiles management:** Bash templates + symlinks drive a single source of truth.
- **Packages:** Homebrew on macOS and `dnf` on Fedora.

## Layout

```
.
├── bootstrap               <-- Cross-platform entry point
├── scripts/                <-- OS-specific helpers invoked by bootstrap
│   ├── apply-dotfiles.sh       <-- Bash templates + symlink installer
│   ├── bootstrap-prereqs.sh    <-- Bootstrap prerequisites
│   ├── setup-macos.sh          <-- macOS package bootstrap
│   ├── setup-linux.sh          <-- Linux package bootstrap
│   └── fedora-installer-helpers.sh
├── packages/               <-- Declarative package manifests
│   ├── Brewfile
│   ├── Brewfile.personal
│   ├── Brewfile.work
│   └── fedora/
│       └── apps/          <-- One install.sh per Fedora application
├── config/                 <-- XDG config files symlinked into ~/.config
├── zshrc                   <-- Symlinked to ~/.zshrc
└── assets/                 <-- Misc assets
    ├── Agents.example.md
```

## Quick Start

### Fedora 43

> [!NOTE]
> Ensure the Kitty desktop entry has the following set:

```bash
# ~/.local/share/applications/kitty.desktop

Exec=kitty -o allow_remote_control=yes --single-instance --listen-on unix:@mykitty
Icon=/home/xep/.config/kitty/kitty.app.png
```

1. Install Git
2. Clone the repository: `git clone ssh://git@codeberg.org/seankay/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles`.
3. Run the bootstrapper: `./bootstrap --update` (executes the app installers under `packages/fedora/apps`).
4. `exec zsh`

### macOS

> [!NOTE]
> Kitty is launched with the options specified in ~/.config/kitty/macos-launch-services-cmdline.

1. Install Xcode Command Line Tools if prompted: `xcode-select --install`.
2. Clone the repository: `git clone git@github.com:seankay/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`.
3. Run the bootstrapper: `./bootstrap --update`.
4. `exec zsh`

## Machine Roles (Personal vs. Work)

- Create a local, untracked file at `~/.config/dotfiles/local.env` on each Mac with `MACHINE_ROLE=personal` or `MACHINE_ROLE=work`. The bootstrap scripts exit if this role is missing or invalid.
- The macOS bootstrap always applies the shared Brewfile (`packages/Brewfile`) so CLI tools stay in sync. It additionally runs `packages/Brewfile.personal` when `MACHINE_ROLE=personal` and `packages/Brewfile.work` when `MACHINE_ROLE=work`, so you can scope GUI/corp apps by role; cleanup runs against the combined manifest so role-specific packages survive.
- `~/.zshrc` sources the same file so the role is available in your shell if you need it for other conditionals.

## Extending the Stack

### Dotfiles

`config/` and `zshrc` are the authoritative sources.

- Zsh configuration lives in `zshrc` (aliases, functions, keymaps, oh-my-posh prompt).
- Git defaults (`~/.gitconfig`) are generated from `local.env`.

`local.env` must define git identity values:

```bash
export GIT_NAME="Sean Kay"
export GIT_EMAIL="email@example.com"
export GIT_SIGNING_KEY="ssh-ed25519 AAAA..."
# optional
export GIT_SSH_KEY="$HOME/.ssh/id_ed25519"
export GIT_GITHUB_HOST_ALIAS="github.com-work"
```

### Packages

- macOS: maintain shared CLI packages in `packages/Brewfile`. Role-specific extras belong in `packages/Brewfile.personal` or `packages/Brewfile.work`, which run only when the matching `MACHINE_ROLE` is set (the cleanup step uses the union so nothing gets pruned unintentionally).
- Fedora: maintain one installer per application under `packages/fedora/apps/<app>/install.sh`. Each script sources `${FEDORA_INSTALL_HELPERS}` to gain helper functions such as `dnf_install`, `dnf_group_install`, `flatpak_install`, `rpm_install`, `github_install`, and `repo_setup`. This keeps repo setup, RPM/Flatpak installs, and any application-specific tweaks close to the software they configure.

### What `bootstrap` Handles Automatically

- Installs prerequisite tooling (Homebrew) before applying dotfiles.
- Applies dotfiles via `scripts/apply-dotfiles.sh` (bash templates + symlinks).
- Runs the appropriate package installer for macOS and Fedora (Homebrew or the Fedora app installers) when `--update` is set.
- On macOS, prunes Homebrew packages that are not declared in the Brewfile.

## Testing & CI Hooks

- `./bootstrap --dry-run` surfaces package commands without executing them.
- `pre-commit run --all-files` executes the gitleaks scan locally, mirroring the enforced commit hook.

## Maintenance Workflow

1. Add or modify files in `config/` or `zshrc`.
2. Run `./scripts/apply-dotfiles.sh --dry-run` to preview changes.
3. Run `./bootstrap --update` to apply package updates on your machine.
4. Occasionally run `git submodule update`
