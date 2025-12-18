# Fedora Application Installers

Each Fedora application lives under `packages/fedora/apps/<name>/install.sh`. The bootstrapper sources these scripts in alphabetical order and provides the helper library at `${FEDORA_INSTALL_HELPERS}` which exposes:

- `dnf_install <pkg>` and `dnf_group_install <group>`
- `dnf_makecache` to refresh metadata on demand
- `repo_setup <description> <command...>` to run repo/key configuration
- `rpm_install <name> <url>`, `flatpak_install <remote> <ref>`, and `github_install <owner/repo> <asset> [install-name]`
- `run_cmd` and the `log_*` helpers used across the repo

A script should simply source the helper, run whatever repo/key setup it needs, and then call the primitives above. This keeps every application self-contained while reusing the shared plumbing for dry-runs and logging.
