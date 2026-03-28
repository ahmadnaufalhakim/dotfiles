#!/usr/bin/env bash

# Prevent sourcing
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    echo "Please run this script, do not source it."
    return 1
fi

set -e

# Resolve dotfiles dir
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# --- install .bashrc hook ---
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

# --- install .profile hook ---
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

# --- install .gitconfig include ---
GITCONFIG="${HOME}/.gitconfig"
GIT_INCLUDE_LINE="[include]\n	path = ${DOTFILES_DIR}/gitconfig"
if [[ -f "${GITCONFIG}" ]]; then
    if ! grep -q "path = ${DOTFILES_DIR}/gitconfig" "${GITCONFIG}"; then
        echo -e "\n# >>> dotfiles gitconfig include >>>" >> "${GITCONFIG}"
        echo -e "${GIT_INCLUDE_LINE}" >> "${GITCONFIG}"
        echo "# <<< dotfiles gitconfig include <<<" >> "${GITCONFIG}"
        echo "Dotfiles Git config include added."
    else
        echo "Dotfiles Git config include already present."
    fi
else
    # If .gitconfig does not exist in home, create it
    cat > "${GITCONFIG}" <<EOF
# >>> dotfiles gitconfig include >>>
[include]
    path = ${DOTFILES_DIR}/gitconfig
# <<< dotfiles gitconfig include <<<
EOF
    echo "Git config created with dotfiles include."
fi
