#!/usr/bin/env bash

prompt_barrier() {
    local left_width="$1"
    local right_width="$2"

    local barrier_len=$(( COLUMNS - ( right_width + 1 ) - ( left_width + 1 ) ))
    (( barrier_len < 0 )) && barrier_len=0

    printf -v barrier '%*s' "${barrier_len}" ''
    barrier=${barrier// /$BARRIER}
    
    printf "%s" "${barrier}"
}
