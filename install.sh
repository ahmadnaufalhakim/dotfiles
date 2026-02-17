#!/usr/bin/env bash

# Prevent sourcing
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    echo "Please run this script, do not source it."
    return 1
fi

set -e

BASHRC="$HOME/.bashrc"
HOOK_START="# >>> dotfiles loader >>>"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

if [ ! -f "$BASHRC" ] || ! grep -q "$HOOK_START" "$BASHRC"; then
    cat >> "$BASHRC" <<EOF

# >>> dotfiles loader >>>
[ -f "$DOTFILES_DIR/bash/loader.sh" ] && source "$DOTFILES_DIR/bash/loader.sh"
# <<< dotfiles loader <<<
EOF
    echo "Bash hook installed."
else
    echo "Bash hook already present."
fi
