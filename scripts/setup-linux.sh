#!/usr/bin/env bash
# Linux bootstrap: distro-aware package installation helpers.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
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

Detects the Linux distribution and installs packages from packages/.
- Arch Linux: pacman + yay (AUR) entries from arch-packages.txt
EOF
}

exec_cmd() {
  if "${DRY_RUN}"; then
    log_debug "(dry-run) $*"
    return 0
  fi
  log_debug "$*"
  "$@"
}

read_manifest() {
  local manifest="$1"
  if [[ ! -f "${manifest}" ]]; then
    log_error "Manifest not found: ${manifest}"
    exit 2
  fi
  grep -v '^\s*#' "${manifest}" | awk 'length($0)>0'
}

install_arch() {
  local manifest="${ROOT_DIR}/packages/arch-packages.txt"
  local pacman_packages=()
  local aur_packages=()
  local line

  while IFS= read -r line; do
    case "${line}" in
      pacman:*)
        pacman_packages+=("${line#pacman:}")
        ;;
      aur:*)
        aur_packages+=("${line#aur:}")
        ;;
      *)
        pacman_packages+=("${line}")
        ;;
    esac
  done < <(read_manifest "${manifest}")

  if (( ${#pacman_packages[@]} )); then
    cmd=(sudo pacman -S --needed)
    if ! "${DRY_RUN}"; then
      cmd+=(--noconfirm)
    fi
    cmd+=("${pacman_packages[@]}")
    exec_cmd "${cmd[@]}"
  fi

  if (( ${#aur_packages[@]} )); then
    if ! command -v yay >/dev/null 2>&1; then
      if "${DRY_RUN}"; then
        log_warn "yay not found. Would install AUR packages: ${aur_packages[*]}"
      else
        log_error "yay (AUR helper) required but not installed."
        exit 3
      fi
    else
      cmd=(yay -S --needed)
      if ! "${DRY_RUN}"; then
        cmd+=(--noconfirm)
      else
        cmd+=(--dry-run)
      fi
      cmd+=("${aur_packages[@]}")
      exec_cmd "${cmd[@]}"
    fi
  fi
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

if [[ ! -r /etc/os-release ]]; then
  log_error "/etc/os-release not found. Unable to detect distribution."
  exit 4
fi

. /etc/os-release

case "${ID}" in
  arch|endeavouros|manjaro)
    log_info "Detected Arch-based distribution (${ID})."
    install_arch
    ;;
  *)
    log_error "Unsupported distribution: ${ID}"
    log_warn "This bootstrap only targets Arch-based systems. Update setup-linux.sh if you need broader coverage."
    exit 5
    ;;
esac

log_info "Linux package bootstrap complete."
