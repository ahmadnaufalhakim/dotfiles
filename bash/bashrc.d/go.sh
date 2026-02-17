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
