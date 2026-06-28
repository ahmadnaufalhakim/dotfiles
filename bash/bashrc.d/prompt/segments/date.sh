#!/usr/bin/env bash

prompt_segment_date() {
    local text=" \D{%Y-%m-%d %H:%M:%S} "
    SEGMENT_TEXT="${BOLD}${COLOR_META_BG}${FG_WHITE}${text}"
    SEGMENT_TEXT+="${INVERT}${COLOR_META_FG}${BG_DEFAULT}${LEFT_SEPARATOR}"
    SEGMENT_WIDTH=$(( ${#text} ))
}
