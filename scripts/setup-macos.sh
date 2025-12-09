#!/usr/bin/env bash
# macOS bootstrap: Homebrew packages + macOS specific tweaks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
LOCAL_ENV_FILE="${XDG_CONFIG_HOME}/dotfiles/local.env"
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

load_machine_role() {
  if [[ -r "${LOCAL_ENV_FILE}" ]]; then
    log_debug "Loading machine role from ${LOCAL_ENV_FILE}"
    # shellcheck disable=SC1090
    source "${LOCAL_ENV_FILE}"
  fi
  : "${MACHINE_ROLE:=work}"
  export MACHINE_ROLE
}

usage() {
  cat <<EOF
Usage: $0 [--dry-run]

Installs Homebrew (if missing) and applies packages from packages/Brewfile.
EOF
}

run() {
  if "${DRY_RUN}"; then
    log_debug "(dry-run) $*"
  else
    log_debug "$*"
  fi
  "$@"
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log_info "Homebrew already installed."
    return
  fi

  if "${DRY_RUN}"; then
    log_warn "Homebrew not found. Would run official installer."
    return
  fi

  log_error "Homebrew not installed. Please install it first:"
  log_info '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 3
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

load_machine_role

ensure_homebrew

if ! command -v brew >/dev/null 2>&1; then
  log_warn "Homebrew unavailable. Skipping brew bundle step."
  exit 0
fi

brewfile="${ROOT_DIR}/packages/Brewfile"
personal_brewfile="${ROOT_DIR}/packages/Brewfile.personal"

if [[ ! -f "${brewfile}" ]]; then
  log_error "Brewfile not found at ${brewfile}"
  exit 2
fi

if "${DRY_RUN}"; then
  run brew bundle check --file "${brewfile}"
  log_info "Would prune Homebrew packages not listed in ${brewfile}"
  if [[ "${MACHINE_ROLE}" == "personal" ]] && [[ -f "${personal_brewfile}" ]]; then
    run brew bundle check --file "${personal_brewfile}"
    log_info "Would prune Homebrew packages not listed in ${personal_brewfile}"
  fi
else
  run brew bundle --file "${brewfile}"
  run brew bundle cleanup --force --file "${brewfile}"
  if [[ "${MACHINE_ROLE}" == "personal" ]] && [[ -f "${personal_brewfile}" ]]; then
    run brew bundle --file "${personal_brewfile}"
    run brew bundle cleanup --force --file "${personal_brewfile}"
  else
    log_info "MACHINE_ROLE=${MACHINE_ROLE}; skipping personal Brewfile (${personal_brewfile})."
  fi
fi

log_info "macOS bootstrap complete."
