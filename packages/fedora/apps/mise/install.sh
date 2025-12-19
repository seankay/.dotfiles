#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

run_cmd sudo dnf config-manager addrepo --overwrite --from-repofile=https://mise.jdx.dev/rpm/mise.repo
dnf_install "mise"
