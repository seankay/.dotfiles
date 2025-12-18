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
- Fedora: dnf + rpm + flatpak entries from fedora-packages.txt (tested against Fedora 43)
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

install_fedora_rpm_packages() {
  local rpm_specs=("$@")
  local spec
  local rpm_name
  local rpm_url
  local tmp_rpm
  local failed=()

  if (( ${#rpm_specs[@]} == 0 )); then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required to download RPM packages."
    exit 3
  fi

  for spec in "${rpm_specs[@]}"; do
    rpm_name="${spec%%|*}"
    rpm_url="${spec#*|}"

    if [[ -z "${rpm_name}" || -z "${rpm_url}" || "${rpm_name}" == "${spec}" ]]; then
      log_warn "Skipping invalid rpm entry: ${spec}"
      continue
    fi

    if "${DRY_RUN}"; then
      log_info "Would install RPM package ${rpm_name} from ${rpm_url}"
      continue
    fi

    if ! tmp_rpm="$(mktemp "/tmp/${rpm_name}.XXXXXX.rpm")"; then
      log_warn "Unable to create temporary file for ${rpm_name}."
      failed+=("${rpm_name}")
      continue
    fi

    if ! exec_cmd curl -fsSL -o "${tmp_rpm}" "${rpm_url}"; then
      log_warn "Failed to download ${rpm_name} from ${rpm_url}"
      failed+=("${rpm_name}")
      rm -f "${tmp_rpm}"
      continue
    fi

    if ! exec_cmd sudo rpm -Uvh --replacepkgs "${tmp_rpm}"; then
      log_warn "Failed to install RPM package ${rpm_name}"
      failed+=("${rpm_name}")
    fi

    rm -f "${tmp_rpm}"
  done

  if (( ${#failed[@]} )); then
    log_warn "Some RPM packages were not installed: ${failed[*]}"
  fi
}

install_fedora_flatpak_packages() {
  local flatpak_specs=("$@")
  local spec
  local remote
  local ref
  local failed=()

  if (( ${#flatpak_specs[@]} == 0 )); then
    return 0
  fi

  if ! command -v flatpak >/dev/null 2>&1; then
    log_error "flatpak is required to install Flatpak packages."
    exit 3
  fi

  for spec in "${flatpak_specs[@]}"; do
    remote="${spec%%|*}"
    ref="${spec#*|}"

    if [[ -z "${remote}" || -z "${ref}" || "${remote}" == "${spec}" ]]; then
      log_warn "Skipping invalid Flatpak entry: ${spec}"
      continue
    fi

    if "${DRY_RUN}"; then
      log_info "Would install Flatpak ${ref} from remote ${remote}"
      continue
    fi

    local cmd=(flatpak install --assumeyes "${remote}" "${ref}")
    if ! exec_cmd "${cmd[@]}"; then
      log_warn "Failed to install Flatpak ${ref}"
      failed+=("${ref}")
    fi
  done

  if (( ${#failed[@]} )); then
    log_warn "Some Flatpak packages were not installed: ${failed[*]}"
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
  declare -A seen_rpm=()
  declare -A seen_flatpak=()
  local packages=()
  local rpm_specs=()
  local flatpak_specs=()
  local entry
  local rpm_name
  local rpm_url
  local remote
  local flatpak_id
  local spec_key
  while IFS= read -r line; do
    case "${line}" in
      dnf:*)
        package="${line#dnf:}"
        ;;
      pacman:*|aur:*)
        package="${line#*:}"
        ;;
      rpm:*)
        entry="${line#rpm:}"
        entry="${entry#${entry%%[![:space:]]*}}"

        if [[ -z "${entry}" ]]; then
          log_warn "Skipping empty rpm entry in ${manifest}."
          continue
        fi

        if [[ "${entry}" != *[[:space:]]* ]]; then
          log_warn "RPM entries must be formatted as 'rpm:<name> <url>': ${line}"
          continue
        fi

        rpm_name="${entry%%[[:space:]]*}"
        rpm_url="${entry#${rpm_name}}"
        rpm_url="${rpm_url#${rpm_url%%[![:space:]]*}}"

        if [[ -z "${rpm_name}" || -z "${rpm_url}" ]]; then
          log_warn "Invalid RPM entry (missing name or URL): ${line}"
          continue
        fi

        if [[ -z "${seen_rpm[${rpm_name}]+x}" ]]; then
          seen_rpm["${rpm_name}"]=1
          rpm_specs+=("${rpm_name}|${rpm_url}")
        fi
        continue
        ;;
      flatpak:*)
        entry="${line#flatpak:}"
        entry="${entry#${entry%%[![:space:]]*}}"

        if [[ -z "${entry}" ]]; then
          log_warn "Skipping empty flatpak entry in ${manifest}."
          continue
        fi

        remote="${entry%%[[:space:]]*}"
        flatpak_id=""

        if [[ "${entry}" == "${remote}" ]]; then
          flatpak_id="${remote}"
          remote="flathub"
        else
          flatpak_id="${entry#${remote}}"
          flatpak_id="${flatpak_id#${flatpak_id%%[![:space:]]*}}"
        fi

        if [[ -z "${flatpak_id}" ]]; then
          log_warn "Invalid Flatpak entry (missing ref): ${line}"
          continue
        fi

        spec_key="${remote}|${flatpak_id}"
        if [[ -z "${seen_flatpak[${spec_key}]+x}" ]]; then
          seen_flatpak["${spec_key}"]=1
          flatpak_specs+=("${spec_key}")
        fi
        continue
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

  if (( ${#packages[@]} == 0 )) && (( ${#rpm_specs[@]} == 0 )) && (( ${#flatpak_specs[@]} == 0 )); then
    log_warn "No packages found in ${manifest}."
    return 0
  fi

  if (( ${#packages[@]} )); then
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
  fi

  if (( ${#rpm_specs[@]} )); then
    install_fedora_rpm_packages "${rpm_specs[@]}"
  fi

  if (( ${#flatpak_specs[@]} )); then
    install_fedora_flatpak_packages "${flatpak_specs[@]}"
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
