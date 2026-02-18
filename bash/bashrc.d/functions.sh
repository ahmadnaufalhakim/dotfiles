#!/usr/bin/env bash

# append_prompt_command appends a command to the current PROMPT_COMMAND
append_prompt_command() {
    local cmd="$1"
    case ";$PROMPT_COMMAND" in
        *";$cmd;"*) ;; # already added
        *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}$cmd"
    esac
}

# Load config
[ -f "$DOTFILES_DIR/config/.env" ] && source "$DOTFILES_DIR/config/.env"

# set_goprivate sets Go GOPRIVATE environment variable
set_goprivate() {
    command -v go &>/dev/null || return

    local in_work=0
    [[ "$PWD" == "$HOME/coding/work"* ]] && in_work=1

    # Only update GOPRIVATE when directory state changed
    if [[ "$in_work" != "$__LAST_GOPRIVATE_STATE" ]]; then
        if (( in_work )); then
            go env -w GOPRIVATE="$GOPRIVATE_DOMAIN"
        else
            go env -u GOPRIVATE
        fi

        # Cache directory state
        __LAST_GOPRIVATE_STATE=$in_work
    fi
}
