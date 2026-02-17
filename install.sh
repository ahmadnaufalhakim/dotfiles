#!/usr/bin/env bash
set -e

BASHRC="$HOME/.bashrc"
HOOK_START="# >>> dotfiles loader >>>"

if ! grep -q "$HOOK_START" "$BASHRC"; then
    cat >> "$BASHRC" <<'EOF'

# >>> dotfiles loader >>>
[ -f "$HOME/.dotfiles/bash/loader.sh" ] && source "$HOME/.dotfiles/bash/loader.sh"
# <<< dotfiles loader <<<
EOF
    echo "Bash hook installed."
else
    echo "Bash hook already present"
fi
