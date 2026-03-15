#!/usr/bin/env bash

prompt_segment_user() {
    local text=" $USER "
    SEGMENT_TEXT="${BG_RY}${FG_BLACK}${text}${BG_NJ}${FG_RY}${RIGHT_SEPARATOR}"
    SEGMENT_WIDTH=$(( ${#text} + 1 ))
}
