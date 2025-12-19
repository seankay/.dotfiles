#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

dnf_group_install "c-development"
dnf_group_install "development-tools"
dnf_install "libffi-devel"
dnf_install "libyaml-devel"
dnf_install "ncurses-devel"
