#!/usr/bin/env bash

# Resolve dotfiles root from this script's real path (follows symlink)
DOTFILES_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

source "${DOTFILES_DIR}/bash/bashrc.d/tips.sh"
dotfiles-tips --motd
