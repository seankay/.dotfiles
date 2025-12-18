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
- Fedora: per-app installers under packages/fedora/apps (tested against Fedora 43)
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
  local apps_dir="${ROOT_DIR}/packages/fedora/apps"
  local helper="${SCRIPT_DIR}/installers/fedora/helpers.sh"
  local dnf_bin

  if ! dnf_bin="$(detect_dnf)"; then
    log_error "dnf not found on PATH."
    exit 3
  fi

  if [[ -n "${VERSION_ID:-}" ]] && [[ "${VERSION_ID}" != "43" ]]; then
    log_warn "Fedora VERSION_ID=${VERSION_ID}; Fedora 43 is the known target for this stack."
  fi

  if [[ ! -d "${apps_dir}" ]]; then
    log_error "Fedora apps directory not found: ${apps_dir}"
    exit 2
  fi

  if [[ ! -f "${helper}" ]]; then
    log_error "Fedora helper functions missing: ${helper}"
    exit 2
  fi

  local installers=()
  mapfile -t installers < <(find "${apps_dir}" -mindepth 2 -maxdepth 2 -name install.sh -print | sort)

  if (( ${#installers[@]} == 0 )); then
    log_warn "No Fedora install scripts found beneath ${apps_dir}."
    return 0
  fi

  if "${DRY_RUN}"; then
    log_info "Would refresh ${dnf_bin} metadata before running installers."
  else
    if ! exec_cmd sudo "${dnf_bin}" makecache --refresh; then
      log_warn "Failed to refresh ${dnf_bin} cache; continuing with installers."
    fi
  fi

  local failed=()
  local script
  for script in "${installers[@]}"; do
    local app_dir
    local app_name
    app_dir="$(dirname "${script}")"
    app_name="$(basename "${app_dir}")"

    log_info "Installing Fedora application: ${app_name}"
    if ! APP_NAME="${app_name}" \
        APP_DIR="${app_dir}" \
        FEDORA_INSTALL_HELPERS="${helper}" \
        DRY_RUN="${DRY_RUN}" \
        DNF_BIN="${dnf_bin}" \
        bash "${script}"; then
      failed+=("${app_name}")
      log_warn "Installation script failed for ${app_name}"
    fi
  done

  if (( ${#failed[@]} )); then
    log_warn "Some Fedora applications failed to install: ${failed[*]}"
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
