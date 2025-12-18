#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

repo_file="/etc/yum.repos.d/google-chrome.repo"

write_repo() {
  if "${DRY_RUN}"; then
    log_info "Would write ${repo_file}"
    return 0
  fi
  sudo tee "${repo_file}" >/dev/null <<'REPO'
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
REPO
}

run_cmd sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || true
write_repo

dnf_install "google-chrome"
