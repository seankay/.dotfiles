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
- Fedora: dnf entries from fedora-packages.txt (tested against Fedora 43)
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

install_fedora() {
  local manifest="${ROOT_DIR}/packages/fedora-packages.txt"
  local dnf_bin
  local package
  local line

  if ! dnf_bin="$(detect_dnf)"; then
    log_error "dnf not found on PATH."
    exit 3
  fi

  if [[ -n "${VERSION_ID:-}" ]] && [[ "${VERSION_ID}" != "43" ]]; then
    log_warn "Fedora VERSION_ID=${VERSION_ID}; Fedora 43 is the known target for this manifest."
  fi

  declare -A seen_packages=()
  local packages=()
  while IFS= read -r line; do
    case "${line}" in
      dnf:*)
        package="${line#dnf:}"
        ;;
      pacman:*|aur:*)
        package="${line#*:}"
        ;;
      *)
        package="${line}"
        ;;
    esac

    if [[ -z "${package}" ]]; then
      continue
    fi

    if [[ -z "${seen_packages[${package}]+x}" ]]; then
      seen_packages["${package}"]=1
      packages+=("${package}")
    fi
  done < <(read_manifest "${manifest}")

  if (( ${#packages[@]} == 0 )); then
    log_warn "No packages found in ${manifest}."
    return 0
  fi

  local failed=()
  for package in "${packages[@]}"; do
    local cmd=(sudo "${dnf_bin}" install --refresh)
    if "${DRY_RUN}"; then
      cmd+=(--assumeno)
    else
      cmd+=(--assumeyes)
    fi
    cmd+=("${package}")

    if ! exec_cmd "${cmd[@]}"; then
      failed+=("${package}")
      log_warn "Failed to install via ${dnf_bin}: ${package}"
    fi
  done

  if (( ${#failed[@]} )); then
    log_warn "Some Fedora packages were not installed (missing repo/renamed/etc): ${failed[*]}"
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
  fedora)
    log_info "Detected Fedora (${ID} ${VERSION_ID:-unknown})."
    install_fedora
    ;;
  *)
    log_error "Unsupported distribution: ${ID}"
    log_warn "Supported Linux distributions: Arch-based and Fedora."
    exit 5
    ;;
esac

log_info "Linux package bootstrap complete."
