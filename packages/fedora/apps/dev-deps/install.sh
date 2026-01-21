#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

dnf_install "gcc"
dnf_install "glibc-devel"
dnf_install "glibc-headers"
dnf_install "kernel-headers"
dnf_install "clang-devel"
dnf_install "llvm-devel"
dnf_group_install "c-development"
dnf_group_install "development-tools"
dnf_install "libffi-devel"
dnf_install "libyaml-devel"
dnf_install "ncurses-devel"
