#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

repo_file="/etc/yum.repos.d/1password.repo"

write_repo() {
  if "${DRY_RUN}"; then
    log_info "Would write ${repo_file}"
    return 0
  fi
  sudo tee "${repo_file}" >/dev/null <<'REPO'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
REPO
}

run_cmd sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc || true
write_repo

dnf_install "1password"
