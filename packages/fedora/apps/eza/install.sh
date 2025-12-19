#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

ensure_tool curl

version="v0.23.4"
install_name="eza"
dest="/usr/local/bin/${install_name}"
url="https://github.com/eza-community/eza/releases/download/${version}/eza_x86_64-unknown-linux-gnu.tar.gz"

if "${DRY_RUN}"; then
  log_info "Would download GitHub asset ${url}"
  exit 0
fi

if ! tmp="$(mktemp "/tmp/github-${install_name}.XXXXXX")"; then
  log_warn "Unable to create temporary file for ${repo}:${asset}"
  exit 1
fi

if ! run_cmd curl -fsSL -o "${tmp}" "${url}"; then
  log_warn "Failed to download ${url}"
  rm -f "${tmp}"
  exit 1
fi

extract_target="/usr/bin"
if ! run_cmd tar --overwrite -xvzf "${tmp}" -C "${extract_target}"; then
  log_warn "Failed to extract ${tmp}"
  rm -f "${tmp}"
  exit 1
fi

rm -f "${tmp}"
