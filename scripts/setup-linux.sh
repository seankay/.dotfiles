#!/usr/bin/env bash
# Linux bootstrap: distro-aware package installation helpers.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DRY_RUN=false
PKG_UPDATE="${PKG_UPDATE:-1}"

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
- Fedora: per-app installers under packages/fedora/apps (tested against Fedora 43)
Set PKG_UPDATE=0 to skip package installs.
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
  local apps_dir="${ROOT_DIR}/packages/fedora/apps"
  local helper="${SCRIPT_DIR}/fedora-installer-helpers.sh"
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

if [[ "${PKG_UPDATE}" == "0" ]]; then
  log_info "PKG_UPDATE=0 set; skipping Linux package installs."
  exit 0
fi

if [[ ! -r /etc/os-release ]]; then
  log_error "/etc/os-release not found. Unable to detect distribution."
  exit 4
fi

. /etc/os-release

case "${ID}" in
  fedora)
    log_info "Detected Fedora (${ID} ${VERSION_ID:-unknown})."
    install_fedora
    ;;
  *)
    log_error "Unsupported distribution: ${ID}"
    log_warn "Supported Linux distributions: Fedora."
    exit 5
    ;;
esac

log_info "Linux package bootstrap complete."
