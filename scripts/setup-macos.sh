#!/usr/bin/env bash
# macOS bootstrap: Homebrew packages + macOS specific tweaks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
LOCAL_ENV_FILE="${XDG_CONFIG_HOME}/dotfiles/local.env"
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

load_machine_role() {
  if [[ -r "${LOCAL_ENV_FILE}" ]]; then
    log_debug "Loading machine role from ${LOCAL_ENV_FILE}"
    source "${LOCAL_ENV_FILE}"
  fi

  if [[ -z "${MACHINE_ROLE:-}" ]]; then
    log_error "MACHINE_ROLE not set. Create ${LOCAL_ENV_FILE} with MACHINE_ROLE=personal|work."
    exit 4
  fi

  if [[ "${MACHINE_ROLE}" != "personal" && "${MACHINE_ROLE}" != "work" ]]; then
    log_error "Invalid MACHINE_ROLE=${MACHINE_ROLE}. Expected 'personal' or 'work'."
    exit 5
  fi

  export MACHINE_ROLE
}

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [--update]

Installs Homebrew (if missing) and applies packages from packages/Brewfile.
Pass --update to install packages.
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
  log_info "Package updates disabled; skipping Homebrew package installs."
  exit 0
fi

load_machine_role

ensure_homebrew

if ! command -v brew >/dev/null 2>&1; then
  log_warn "Homebrew unavailable. Skipping brew bundle step."
  exit 0
fi

brewfile="${ROOT_DIR}/packages/Brewfile"
personal_brewfile="${ROOT_DIR}/packages/Brewfile.personal"
work_brewfile="${ROOT_DIR}/packages/Brewfile.work"

if [[ ! -f "${brewfile}" ]]; then
  log_error "Brewfile not found at ${brewfile}"
  exit 2
fi

cleanup_sources=("${brewfile}")

if "${DRY_RUN}"; then
  run brew bundle check --file "${brewfile}"
else
  run brew bundle --file "${brewfile}"
fi

if [[ "${MACHINE_ROLE}" == "personal" ]]; then
  if [[ -f "${personal_brewfile}" ]]; then
    if "${DRY_RUN}"; then
      run brew bundle check --file "${personal_brewfile}"
    else
      run brew bundle --file "${personal_brewfile}"
    fi
    cleanup_sources+=("${personal_brewfile}")
  else
    log_info "MACHINE_ROLE=personal; skipping missing personal Brewfile (${personal_brewfile})."
  fi
elif [[ "${MACHINE_ROLE}" == "work" ]]; then
  if [[ -f "${work_brewfile}" ]]; then
    if "${DRY_RUN}"; then
      run brew bundle check --file "${work_brewfile}"
    else
      run brew bundle --file "${work_brewfile}"
    fi
    cleanup_sources+=("${work_brewfile}")
  else
    log_info "MACHINE_ROLE=work; skipping missing work Brewfile (${work_brewfile})."
  fi
fi

if "${DRY_RUN}"; then
  log_info "Would prune Homebrew packages not listed in the combined Brewfile set: ${cleanup_sources[*]}"
else
  cleanup_file="${brewfile}"
  tmp_cleanup=""
  if ((${#cleanup_sources[@]} > 1)); then
    tmp_cleanup="$(mktemp)"
    for src in "${cleanup_sources[@]}"; do
      cat "${src}" >>"${tmp_cleanup}"
      printf "\n" >>"${tmp_cleanup}"
    done
    cleanup_file="${tmp_cleanup}"
  fi

  run brew bundle cleanup --force --file "${cleanup_file}"

  if [[ -n "${tmp_cleanup}" ]]; then
    rm -f "${tmp_cleanup}"
  fi
fi

log_info "macOS bootstrap complete."
