#!/usr/bin/env bash

# Resolve dotfiles dir if not already set
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

BASH_MODULE_DIR="$DOTFILES_DIR/bash/bashrc.d"
if [ -d "$BASH_MODULE_DIR" ]; then
    for file in "$BASH_MODULE_DIR"/*.sh; do
        [ -r "$file" ] && source "$file"
    done
fi
