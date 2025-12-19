#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

dnf_install "dnf-plugins-core"
run_cmd sudo dnf config-manager addrepo --overwrite --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf_install "brave-browser"
