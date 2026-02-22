#!/usr/bin/env bash

# Check for Go binary
if [ -x /usr/local/go/bin/go ]; then
    export PATH="/usr/local/go/bin:$PATH"
fi

# Configure Go environment variable
export GOPATH="${GOPATH:-$HOME/go}"
case ":$PATH:" in
    *":$GOPATH/bin:"*) ;;
    *) export PATH="$GOPATH/bin:$PATH" ;;
esac

# set_goprivate sets Go GOPRIVATE environment variable
function set_goprivate() {
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
