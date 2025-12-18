#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

run_cmd sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || true
run_cmd sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo || true

dnf_install "brave-browser"
