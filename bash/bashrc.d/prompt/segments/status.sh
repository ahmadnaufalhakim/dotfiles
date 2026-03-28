#!/usr/bin/env bash

prompt_segment_status() {
    local exit_code="$1"
    local text

    if (( exit_code == 0 )); then
        text=" ✓ "
        SEGMENT_TEXT="${INVERT}${FG_KT}${RIGHT_SEPARATOR}${RESET}${BOLD}${BG_KT}${FG_BLACK}${text}${BG_RY}${FG_KT}${RIGHT_SEPARATOR}"
    else
        text=" ✗ "
        SEGMENT_TEXT="${INVERT}${BG_DEFAULT}${FG_WHITE}${RIGHT_SEPARATOR}${RESET}${BOLD}${BG_WHITE}${FG_KT}${text}${BG_RY}${FG_DEFAULT}${RIGHT_SEPARATOR}"
    fi

    SEGMENT_WIDTH=$(( ${#text} + 2 ))
}
