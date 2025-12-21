#!/usr/bin/env bash
# Installs baseline tooling (Homebrew on macOS).
set -euo pipefail

DRY_RUN=false
UPDATE=false

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
  cat <<EOF
Usage: $0 [--dry-run] [--update]

Bootstraps a fresh machine with required tooling:
- macOS: installs Homebrew (if missing).
- Fedora: no-op (package installs happen later).
Pass --update to install prerequisites.
EOF
}

run() {
  if "${DRY_RUN}"; then
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
    --update)
      UPDATE=true
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

if [[ "${UPDATE}" != "true" ]]; then
  log_info "Package updates disabled; skipping prerequisite installs."
  exit 0
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_error "Required command '${1}' not found. Install it and re-run the bootstrap."
    exit 1
  fi
}

require_cmd curl
if [[ "$(id -u)" -ne 0 ]]; then
  require_cmd sudo
fi

install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
  if "${DRY_RUN}"; then
    log_warn "Homebrew not found. Would run official installer."
    return
  fi

    log_info "Installing Homebrew (this may prompt for sudo)."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  else
    log_info "Homebrew already present."
  fi

}
detect_dnf() {
  if command -v dnf >/dev/null 2>&1; then
    printf '%s\n' "dnf"
    return 0
  fi
  if command -v dnf5 >/dev/null 2>&1; then
    printf '%s\n' "dnf5"
    return 0
  fi
  return 1
}

install_fedora() {
  local dnf_bin
  if ! dnf_bin="$(detect_dnf)"; then
    log_error "dnf not found on PATH."
    exit 3
  fi

  log_info "No additional prerequisites needed for Fedora."
}

case "$(uname -s)" in
  Darwin)
    install_macos
    ;;
  Linux)
    if [[ ! -r /etc/os-release ]]; then
      log_error "/etc/os-release not found. Cannot detect distribution."
      exit 2
    fi
    . /etc/os-release
    case "${ID:-}" in
      fedora)
        log_info "Detected Fedora (${ID} ${VERSION_ID:-unknown})."
        install_fedora
        ;;
      *)
        log_error "Unsupported distribution: ${ID:-unknown}"
        exit 3
        ;;
    esac
    ;;
  *)
    log_error "Unsupported OS: $(uname -s)"
    exit 4
    ;;
esac

log_info "Prerequisite bootstrap complete."
