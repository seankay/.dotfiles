#!/usr/bin/env bash
set -euo pipefail

: "${DRY_RUN:=false}"
: "${DNF_BIN:=dnf}"

RESET="\033[0m"
INFO_COLOR="\033[94m"
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

run_cmd() {
  if "${DRY_RUN}"; then
    log_debug "(dry-run) $*"
    return 0
  fi
  log_debug "$*"
  "$@"
}

ensure_tool() {
  local tool="$1"
  if ! command -v "${tool}" >/dev/null 2>&1; then
    log_error "Required tool not found: ${tool}"
    exit 3
  fi
}

dnf_makecache() {
  run_cmd sudo "${DNF_BIN}" makecache --refresh
}

dnf_install() {
  local package="$1"
  local cmd=(sudo "${DNF_BIN}" install --assumeyes "${package}")
  run_cmd "${cmd[@]}"
}

dnf_group_install() {
  local group="$1"
  local cmd=(sudo "${DNF_BIN}" group install --assumeyes "${group}")
  run_cmd "${cmd[@]}"
}

repo_setup() {
  local description="$1"
  shift
  log_info "Configuring repo: ${description}"
  run_cmd sudo bash -c "$*"
}

rpm_install() {
  local name="$1"
  local url="$2"
  ensure_tool curl

  if "${DRY_RUN}"; then
    log_info "Would install RPM ${name} from ${url}"
    return 0
  fi

  local tmp
  if ! tmp="$(mktemp "/tmp/${name}.XXXXXX.rpm")"; then
    log_warn "Unable to create temporary RPM for ${name}"
    return 1
  fi

  if ! run_cmd curl -fsSL -o "${tmp}" "${url}"; then
    log_warn "Failed to download ${url}"
    rm -f "${tmp}"
    return 1
  fi

  if ! run_cmd sudo rpm -Uvh --replacepkgs "${tmp}"; then
    rm -f "${tmp}"
    return 1
  fi

  rm -f "${tmp}"
}

flatpak_install() {
  local remote="$1"
  local ref="$2"
  ensure_tool flatpak
  local cmd=(flatpak install --assumeyes "${remote}" "${ref}")
  run_cmd "${cmd[@]}"
}
