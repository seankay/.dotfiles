#!/usr/bin/env bash

set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

# Install Sesh
if command -v go &>/dev/null; then
  run_cmd mise install go@latest
fi
run_cmd go install github.com/joshmedeski/sesh/v2@latest

# Generate completion script
sesh completion zsh > _sesh
run_cmd sudo mkdir -p /usr/local/share/zsh/site-functions
run_cmd sudo cp _sesh /usr/local/share/zsh/site-functions/
run_cmd rm _sesh
