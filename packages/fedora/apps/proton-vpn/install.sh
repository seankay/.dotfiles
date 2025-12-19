#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

version="1.0.3-1"
run_cmd wget "https://repo.protonvpn.com/fedora-$(cat /etc/fedora-release | cut -d' ' -f 3)-stable/protonvpn-stable-release/protonvpn-stable-release-${version}.noarch.rpm"
dnf_install ./protonvpn-stable-release-${version}.noarch.rpm || 0
dnf_install libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app
dnf_install proton-vpn-gnome-desktop
rm ./protonvpn-stable-release-${version}.noarch.rpm
