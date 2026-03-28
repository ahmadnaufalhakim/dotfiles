#!/usr/bin/env bash

prompt_segment_date() {
    local text=" \D{%Y-%m-%d %H:%M:%S} "
    SEGMENT_TEXT="${BOLD}${BG_KK}${FG_WHITE}${text}"
    SEGMENT_TEXT+="${INVERT}${FG_KK}${BG_DEFAULT}${LEFT_SEPARATOR}"
    SEGMENT_WIDTH=$(( ${#text} ))
}
