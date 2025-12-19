#!/usr/bin/env bash
set -euo pipefail

source "${FEDORA_INSTALL_HELPERS}"

version=v3.4.0
dir=~/.local/share/fonts
marker="${dir}/.nerd-fonts-hack-${version}.installed"

if [[ -f "${marker}" ]]; then
  echo "nerd-fonts Hack ${version} already installed; skipping."
  exit 0
fi

run_cmd wget -P ${dir} https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/Hack.zip
cd ${dir}
unzip ${dir}/Hack.zip
rm ${dir}/Hack.zip
fc-cache -fv
touch "${marker}"
