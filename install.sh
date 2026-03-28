#!/usr/bin/env bash

# Prevent sourcing
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    echo "Please run this script, do not source it."
    return 1
fi

set -e

# Resolve dotfiles dir
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# install .bashrc hook
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
    echo "Bash hook already present."
fi

# install .profile hook
PROFILE="${HOME}/.profile"
HOOK_START="# >>> dotfiles profile loader >>>"
if [[ ! -f "${PROFILE}" ]] || ! grep -q "${HOOK_START}" "${PROFILE}"; then
    cat >> "${PROFILE}" <<EOF

# >>> dotfiles profile loader >>>
[[ -f "${DOTFILES_DIR}/profile/loader.sh" ]] && source "${DOTFILES_DIR}/profile/loader.sh"
# <<< dotfiles profile loader <<<
EOF
    echo "Profile hook installed."
else 
    echo "Profile hook already present."
fi
