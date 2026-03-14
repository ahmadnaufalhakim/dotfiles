#!/usr/bin/env bash

for f in "${DOTFILES_DIR}/bash/bashrc.d/prompt/"*.sh; do
    [[ -r "$f" ]] && source "$f"
done
