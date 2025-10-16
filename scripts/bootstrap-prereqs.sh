#!/usr/bin/env bash
# Installs baseline tooling (Homebrew on macOS, chezmoi).
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
  cat <<EOF
Usage: $0 [--dry-run]

Bootstraps a fresh machine with required tooling:
- macOS: installs Homebrew (if missing) and ensures chezmoi via brew.
- Arch Linux: installs chezmoi via pacman (and yay when available).
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
      log_info "Would install packages via Homebrew: chezmoi"
      return
    fi

    log_info "Installing Homebrew (this may prompt for sudo)."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  else
    log_info "Homebrew already present."
  fi

  if "${DRY_RUN}"; then
    log_info "Would ensure Homebrew packages installed: chezmoi"
    return
  fi

  if brew list --formula chezmoi >/dev/null 2>&1; then
    log_info "chezmoi already installed."
  else
    run brew install chezmoi
  fi
}

install_arch() {
  packages=(chezmoi)
  cmd=(sudo pacman -S --needed)
  if ! "${DRY_RUN}"; then
    cmd+=(--noconfirm)
  fi
  cmd+=("${packages[@]}")
  run "${cmd[@]}"
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
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
      arch|endeavouros|manjaro)
        log_info "Detected Arch-based distribution (${ID})."
        install_arch
        ;;
      *)
        log_error "Unsupported distribution: ${ID}"
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
