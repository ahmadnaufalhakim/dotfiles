#!/usr/bin/env bash

PRV_KEY="$HOME/.ssh/github_ed25519"
AGENT_FILE="$HOME/.ssh/.agent.env"

# start_agent starts a new ss-agent, saves its
# environment variables to a file for reuse
function start_agent() {
    eval "$(ssh-agent -s)" >/dev/null
    {
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID"
    } > "$AGENT_FILE"
    chmod 600 "$AGENT_FILE"
}

# Load existing ssh agent if possible
if [ -f "$AGENT_FILE" ]; then
    source "$AGENT_FILE" >/dev/null
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        start_agent
    fi
else
    start_agent
fi

# Add key if not already added
FINGERPRINT=$(ssh-keygen -lf "$PRV_KEY.pub" | awk '{print $2}')
if ! ssh-add -L &>/dev/null | grep -q "$FINGERPRINT"; then
    ssh-add "$PRV_KEY" &>/dev/null
fi
