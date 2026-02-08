# Cross-Platform Dotfiles with Bash + Symlinks

This stack keeps dotfiles portable across macOS and Linux.

- **Dotfiles management:** Bash templates + symlinks drive a single source of truth.
- **Packages:** Homebrew on macOS and `dnf` on Fedora.

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
- Mise is leveraged for dev tooling where possible
