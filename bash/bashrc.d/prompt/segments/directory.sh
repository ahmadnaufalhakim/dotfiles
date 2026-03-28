#!/usr/bin/env bash

prompt_segment_directory() {
    local text=" $(short_pwd "${PROMPT_DIR_DEPTH}") "
    SEGMENT_TEXT="${BG_NJ}${FG_BLACK}${text}"
    SEGMENT_WIDTH=$(( ${#text} + 1 ))
}

# short_pwd construct the PWD dir, but shortened
short_pwd() {
    local depth=${1:-$PROMPT_DIR_DEPTH}
    local path

    # Replace $HOME with ~
    if [[ "$PWD" == "$HOME"* ]]; then
        path="~${PWD#$HOME}"
    else
        path="$PWD"
    fi

    # Split into components
    IFS='/' read -ra parts <<< "$path"
    local count=${#parts[@]}

    local tilde=0
    [[ ${parts[0]} == "~" ]] && tilde=1

    if (( count <= depth + tilde )); then
        printf "%s" "$path"
        return
    fi

    local start=$(( count - depth ))
    local result=""
    # Shorten skipped directories to first letter
    for (( i=tilde; i<start; i++ )); do
        result+="${parts[i]:0:1}/"
    done

    # Slice last segment and join with /
    local last_segments
    printf -v last_segments "%s/" "${parts[@]:start:depth}"
    last_segments=${last_segments%/}

    if (( tilde )); then
        printf "~/%s%s" "$result" "$last_segments"
    else
        printf "%s%s" "$result" "$last_segments"
    fi
}