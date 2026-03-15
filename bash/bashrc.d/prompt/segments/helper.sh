#!/usr/bin/env bash

prompt_add_left() {
    left_section+="${SEGMENT_TEXT}"
    (( left_width += SEGMENT_WIDTH ))
}
