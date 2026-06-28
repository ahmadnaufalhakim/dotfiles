#!/usr/bin/env bash

prompt_segment_status() {
    local exit_code="$1"
    local text

    if (( exit_code == 0 )); then
        text=" ✓ "
        SEGMENT_TEXT="${INVERT}${COLOR_ACCENT_FG}${RIGHT_SEPARATOR}${RESET}${BOLD}${COLOR_ACCENT_BG}${FG_BLACK}${text}${COLOR_USER_BG}${COLOR_ACCENT_FG}${RIGHT_SEPARATOR}"
    else
        text=" ✗ "
        SEGMENT_TEXT="${INVERT}${BG_DEFAULT}${FG_WHITE}${RIGHT_SEPARATOR}${RESET}${BOLD}${BG_WHITE}${COLOR_ACCENT_FG}${text}${COLOR_USER_BG}${FG_DEFAULT}${RIGHT_SEPARATOR}"
    fi

    SEGMENT_WIDTH=$(( ${#text} + 2 ))
}
