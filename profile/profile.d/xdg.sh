#!/usr/bin/env bash

# XDG Base Directory Specification

# Config files (default: ~/.config)
: "${XDG_CONFIG_HOME:=${HOME}/.config}"

# User data (default: ~/.local/share)
: "${XDG_DATA_HOME:=${HOME}/.local/share}"

# Cache files (default: ~/.cache)
: "${XDG_CACHE_HOME:=${HOME}/.cache}"

# State files (logs, history, etc.) (default: ~/.local/state)
: "${XDG_STATE_HOME:=${HOME}/.local/state}"

# Export them
export XDG_CONFIG_HOME
export XDG_DATA_HOME
export XDG_CACHE_HOME
export XDG_STATE_HOME

# Ensure directories exist (safe, no-op if already there)
mkdir -p \
    "${XDG_CONFIG_HOME}" \
    "${XDG_DATA_HOME}" \
    "${XDG_CACHE_HOME}" \
    "${XDG_STATE_HOME}"
