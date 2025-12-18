#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

repo_file="/etc/yum.repos.d/protonvpn.repo"

write_repo() {
  if "${DRY_RUN}"; then
    log_info "Would write ${repo_file}"
    return 0
  fi
  sudo tee "${repo_file}" >/dev/null <<'REPO'
[protonvpn]
name=ProtonVPN Stable
baseurl=https://repo.protonvpn.com/fedora/protonvpn-stable
enabled=1
gpgcheck=1
gpgkey=https://repo.protonvpn.com/fedora/protonvpn_public.asc
REPO
}

run_cmd sudo rpm --import https://repo.protonvpn.com/fedora/protonvpn_public.asc || true
write_repo

dnf_install "proton-vpn-gtk-app"
