#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

rpm_install "discord" "https://discord.com/api/download?platform=linux&format=rpm"
