#!/usr/bin/env bash
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

BASHRC="$HOME/.bashrc"
HOOK_START="# >>> dotfiles loader >>>"

if [ ! -f "$BASHRC" ] || ! grep -q "$HOOK_START" "$BASHRC"; then
    cat >> "$BASHRC" <<EOF

# >>> dotfiles loader >>>
[ -f "$DOTFILES_DIR/bash/loader.sh" ] && source "$DOTFILES_DIR/bash/loader.sh"
# <<< dotfiles loader <<<
EOF
    echo "Bash hook installed."
else
    echo "Bash hook already present"
fi
