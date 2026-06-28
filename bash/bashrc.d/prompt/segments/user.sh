#!/usr/bin/env bash

prompt_segment_user() {
    local text=" $USER "
    SEGMENT_TEXT="${COLOR_USER_BG}${FG_BLACK}${text}${COLOR_DIR_BG}${COLOR_USER_FG}${RIGHT_SEPARATOR}"
    SEGMENT_WIDTH=$(( ${#text} + 1 ))
}
