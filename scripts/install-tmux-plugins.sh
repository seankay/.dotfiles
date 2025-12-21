#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false

RESET="\033[0m"
INFO_COLOR="\033[94m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"

log_info() {
  printf "${INFO_COLOR}> %s${RESET}\n" "$*"
}

log_debug() {
  printf "${CYAN}> %s${RESET}\n" "$*"
}

log_warn() {
  printf "${YELLOW}! %s${RESET}\n" "$*"
}

log_error() {
  printf "${RED}✖ %s${RESET}\n" "$*"
}

usage() {
  cat <<'USAGE'
Usage: $0 [--dry-run]

Clones TPM (tmux plugin manager) if it is not already installed under ~/.local/share/tmux/plugins/tpm.
Run inside a terminal after installing tmux. After cloning, open tmux and press Prefix + I to install/update plugins.
USAGE
}

run() {
  if "$DRY_RUN"; then
    log_debug "(dry-run) $*"
    return 0
  fi
  log_debug "$*"
  "$@"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
 done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_error "Missing required command: $1"
    exit 1
  fi
}

require_cmd git

PLUGINS_DIR="${HOME}/.local/share/tmux/plugins"
TPM_DIR="${PLUGINS_DIR}/tpm"
RESURRECT_DIR="${HOME}/.local/state/tmux/resurrect"

if "$DRY_RUN"; then
  log_info "Would ensure tmux plugin directories exist: ${PLUGINS_DIR}, ${RESURRECT_DIR}"
else
  run mkdir -p "${PLUGINS_DIR}" "${RESURRECT_DIR}"
fi

if [[ -d "$TPM_DIR/.git" ]]; then
  log_info "TPM already installed at ${TPM_DIR}."
  if ! "$DRY_RUN"; then
    (cd "$TPM_DIR" && git fetch --quiet && git pull --ff-only --quiet) || log_warn "Warning: unable to update TPM automatically."
  else
    log_info "Would update TPM with 'git pull --ff-only'."
  fi
else
  run git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

log_info "Open tmux and press Prefix + I to install or update configured plugins."
