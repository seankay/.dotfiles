#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

dnf_install "fzf"
