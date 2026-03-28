#!/usr/bin/env bash

# Resolve dotfiles dir if not already set
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Load custom profile
PROFILE_DIR="${DOTFILES_DIR}/profile/profile.d"
if [[ -d "${PROFILE_DIR}" ]]; then
    for file in "${PROFILE_DIR}"/*.sh; do
        [[ -r "${file}" ]] && source "${file}" && echo "source ${file}"
    done
fi
