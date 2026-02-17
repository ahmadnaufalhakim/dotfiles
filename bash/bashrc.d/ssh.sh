#!/usr/bin/env bash

PRV_KEY="$HOME/.ssh/github_ed25519"

# Attempt to use existing agent
if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
    # Start a new agent and export the variables
    eval "$(ssh-agent -s)"
fi

# Add key if not already added
FINGERPRINT=$(ssh-keygen -lf "$PRV_KEY.pub" | awk '{print $2}')
if ssh-add -L | grep -q "$FINGERPRINT"; then
    echo "Key already added"
else
    ssh-add "$PRV_KEY"
fi
