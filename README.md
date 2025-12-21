# Cross-Platform Dotfiles with chezmoi

This stack keeps dotfiles portable across macOS and Linux while staying close to native tooling.

- **Dotfiles management:** [`chezmoi`](https://www.chezmoi.io/) templates drive a single source of truth.
- **Packages:** Homebrew on macOS, `pacman`/`yay` on Arch Linux, and `dnf` on Fedora.
- **System automation:** Shell scripts keep the bootstrap idempotent while staying lightweight.
- **Secrets:** Store confidential files via `chezmoi`'s `age` integration or a separate secret manager; the structure leaves room for either.

## Layout

```
.
├── bootstrap               <-- Cross-platform entry point
├── scripts/                <-- OS-specific helpers invoked by bootstrap
│   ├── setup-macos.sh
│   ├── setup-linux.sh
│   └── bootstrap-prereqs.sh
├── packages/               <-- Declarative package manifests
│   ├── Brewfile
│   ├── Brewfile.personal
│   ├── Brewfile.work
│   ├── arch-packages.txt
│   └── fedora/
│       └── apps/          <-- One install.sh per Fedora application
├── chezmoi/                <-- chezmoi source state (templates + dotfiles)
│   ├── README.md
│   ├── chezmoi.yaml.tmpl
│   ├── dot_config/
│   ├── dot_gitconfig.tmpl
│   ├── dot_local/
│   └── dot_zshrc.tmpl
├── bin/                    <-- Helper executables exposed via symlinks
└── assets/                 <-- Misc assets
    ├── Agents.example.md
```

## Quick Start

### (Arch) Linux

1. Install Git
2. Install 1Password
3. Copy SSH keys from 1Password
   - `mkdir -p ~/.ssh && chmod 700 ~/.ssh`
   - Copy private key from 1Password and save as `~/.ssh/id_ed25519`, then `chmod 600 ~/.ssh/id_ed25519`
   - Add GitHub to known hosts: `ssh-keyscan github.com >> ~/.ssh/known_hosts && chmod 644 ~/.ssh/known_hosts`
   - Test SSH access: `ssh -T git@github.com`
4. Clone the repository: `git clone git@github.com:seankay/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`.
5. Run the bootstrapper: `./bootstrap`.
6. Open tmux and press Prefix + `I` to install/update configured plugins (tokyonight theme, navigator, battery, online-status, resurrect, continuum).
7. `exec zsh`

### Fedora 43

1. Install Git
2. Clone the repository: `git clone git@github.com:seankay/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`.
3. Run the bootstrapper: `./bootstrap` (executes the app installers under `packages/fedora/apps`).
4. `exec zsh`

### macOS

1. Install Xcode Command Line Tools if prompted: `xcode-select --install`.
2. Install 1Password
3. Install Git and copy SSH keys from 1Password
   - `mkdir -p ~/.ssh && chmod 700 ~/.ssh`
   - Copy private key from 1Password and save as `~/.ssh/id_rsa`, then `chmod 600 ~/.ssh/id_rsa`
   - Add GitHub to known hosts: `ssh-keyscan github.com >> ~/.ssh/known_hosts && chmod 644 ~/.ssh/known_hosts`
   - Test SSH access: `ssh -T git@github.com`
4. Clone the repository: `git clone git@github.com:seankay/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`.
5. Run the bootstrapper: `./bootstrap`.
6. Open tmux and press Prefix + `I` to install/update configured plugins (tokyonight theme, navigator, battery, online-status, resurrect, continuum).
7. `exec zsh`

## Machine Roles (Personal vs. Work)

- Create a local, untracked file at `~/.config/dotfiles/local.env` on each Mac with `MACHINE_ROLE=personal` or `MACHINE_ROLE=work`. The bootstrap scripts exit if this role is missing or invalid.
- The macOS bootstrap always applies the shared Brewfile (`packages/Brewfile`) so CLI tools stay in sync. It additionally runs `packages/Brewfile.personal` when `MACHINE_ROLE=personal` and `packages/Brewfile.work` when `MACHINE_ROLE=work`, so you can scope GUI/corp apps by role; cleanup runs against the combined manifest so role-specific packages survive.
- `~/.zshrc` sources the same file so the role is available in your shell if you need it for other conditionals.

## Extending the Stack

### Dotfiles

`chezmoi/` is the authoritative chezmoi source directory. Add files using `chezmoi add path/to/file`. Templates can differentiate OS- or host-specific values using `.chezmoitemplates`.

- Zsh configuration lives in `.zshrc.tmpl` (aliases, functions, keymaps, tmux auto-attach, oh-my-posh prompt).
- Git defaults (.gitconfig) include SSH signing via 1Password.
- Tmux configuration resides at `.config/tmux/tmux.conf`; `bootstrap` bootstraps TPM so you can press Prefix + `I` inside tmux to fetch plugins.
- Direnv, btop, and other app configs sit under `dot_config/` (symlinked to the existing `config/` directory where appropriate).
- Execution helpers in `bin/` are added to your PATH via `~/.dotfiles/bin`, so scripts like `colorscripts-squares` and `e` remain available regardless of OS.

Keep secrets out of the repo. Suggested options:

- `chezmoi` `age` integration (`chezmoi secret add`).
- External secret manager (e.g., 1Password CLI, Bitwarden) referenced in templates.

### Packages

- macOS: maintain shared CLI packages in `packages/Brewfile`. Role-specific extras belong in `packages/Brewfile.personal` or `packages/Brewfile.work`, which run only when the matching `MACHINE_ROLE` is set (the cleanup step uses the union so nothing gets pruned unintentionally).
- Arch Linux: maintain `packages/arch-packages.txt`. Use `pacman:<pkg>` for core packages and `aur:<pkg>` for AUR entries (requires `yay`).
- Fedora: maintain one installer per application under `packages/fedora/apps/<app>/install.sh`. Each script sources `${FEDORA_INSTALL_HELPERS}` to gain helper functions such as `dnf_install`, `dnf_group_install`, `flatpak_install`, `rpm_install`, `github_install`, and `repo_setup`. This keeps repo setup, RPM/Flatpak installs, and any application-specific tweaks close to the software they configure.

### What `bootstrap` Handles Automatically

- Installs prerequisite tooling (Homebrew, chezmoi) before applying dotfiles.
- Runs the appropriate package installer for macOS/Arch (using Homebrew or `pacman`/`yay`).
- On macOS, prunes Homebrew packages that are not declared in the Brewfile.
- Ensures `~/.local/bin` exists so your PATH includes a per-user bin directory.
- Bootstraps TPM so tmux plugins can be installed with Prefix + `I`.
- Installs the repository's `pre-commit` hooks (gitleaks) when `pre-commit` is available.

## Testing & CI Hooks

- `./bootstrap --dry-run` surfaces package commands without executing them.
- `pre-commit run --all-files` executes the gitleaks scan locally, mirroring the enforced commit hook.

## Maintenance Workflow

1. Add or modify files in `chezmoi/`.
2. Run `./bootstrap --dry-run` to preview changes.
3. Run `./bootstrap` to apply updates on your machine.
