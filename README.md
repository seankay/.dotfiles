# Cross-Platform Dotfiles with chezmoi

This stack keeps dotfiles portable across macOS and Linux while staying close to native tooling.

- **Dotfiles management:** [`chezmoi`](https://www.chezmoi.io/) templates drive a single source of truth.
- **Packages:** Homebrew on macOS and `pacman`/`yay` on Arch Linux.
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
│   └── arch-packages.txt
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
6. Open tmux and press Prefix + `I` to install/update configured plugins (catppuccin theme, navigator, battery, online-status, resurrect, continuum).
7. `exec zsh`

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
6. Open tmux and press Prefix + `I` to install/update configured plugins (catppuccin theme, navigator, battery, online-status, resurrect, continuum).
7. `exec zsh`

## Machine Roles (Personal vs. Work)

- Create a local, untracked file at `~/.config/dotfiles/local.env` on each Mac with `MACHINE_ROLE=personal` or `MACHINE_ROLE=work`. If absent, it defaults to `work` for safety.
- The macOS bootstrap always applies the shared Brewfile (`packages/Brewfile`) so CLI tools stay in sync. It only runs the personal Brewfile (`packages/Brewfile.personal`)—intended for casks/GUI apps—when `MACHINE_ROLE=personal`, so your work Mac is left alone for apps.
- `~/.zshrc` sources the same file so the role is available in your shell if you need it for other conditionals.

## Extending the Stack

### Dotfiles

`chezmoi/` is the authoritative chezmoi source directory. Add files using `chezmoi add path/to/file`. Templates can differentiate OS- or host-specific values using `.chezmoitemplates`.

- Zsh configuration lives in `.zshrc.tmpl` (aliases, functions, keymaps, tmux auto-attach, oh-my-posh prompt).
- Git defaults (.gitconfig) include SSH signing via 1Password.
- Tmux configuration resides at `.config/tmux/tmux.conf`; `bootstrap` bootstraps TPM so you can press Prefix + `I` inside tmux to fetch plugins.
- Direnv, btop, and other app configs sit under `dot_config/` (symlinked to the existing `config/` directory where appropriate).
- `symlink_bin.tmpl` keeps `$HOME/bin` pointing at the repository’s `bin/` directory so helper scripts are shared across machines.
- Execution helpers in `bin/` are exposed both as `~/bin` and `~/.local/bin` via symlinks, so scripts like `colorscripts-squares` and `e` remain on your PATH regardless of OS.
  - Update the symlink targets in `chezmoi.yaml.tmpl` if you relocate the repository.

Keep secrets out of the repo. Suggested options:

- `chezmoi` `age` integration (`chezmoi secret add`).
- External secret manager (e.g., 1Password CLI, Bitwarden) referenced in templates.

Update `data.bin_source` in `chezmoi.yaml.tmpl` if your repository layout differs and you need the symlink to target a different path.

### Packages

- macOS: maintain shared CLI packages in `packages/Brewfile`. GUI apps (casks) go in `packages/Brewfile.personal`, which only runs when `MACHINE_ROLE=personal`.
- Arch Linux: maintain `packages/arch-packages.txt`. Use `pacman:<pkg>` for core packages and `aur:<pkg>` for AUR entries (requires `yay`).

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
