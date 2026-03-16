#!/usr/bin/env bash

prompt_add_left() {
    left_section+="${SEGMENT_TEXT}"
    (( left_width += SEGMENT_WIDTH ))
}

prompt_add_right() {
    right_section+="${SEGMENT_TEXT}"
    (( right_width += SEGMENT_WIDTH ))
}
