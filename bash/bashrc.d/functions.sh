#!/usr/bin/env bash

append_prompt_command() {
    local cmd="$1"
    case ";$PROMPT_COMMAND" in
        *";$cmd;"*) ;; # already added
        *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}$cmd"
    esac
}

# Load config
[ -f "$DOTFILES_DIR/config/.env" ] && source "$DOTFILES_DIR/config/.env"

set_goprivate() {
    command -v go &>/dev/null || return

    [[ "$PWD" == "$HOME/coding/work"* ]] \
        && go env -w GOPRIVATE="$GOPRIVATE_DOMAIN" \
        || go env -u GOPRIVATE
}
