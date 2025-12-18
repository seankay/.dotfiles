#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

flatpak_install "flathub" "com.spotify.Client"
