#!/usr/bin/env bash

prompt_segment_duration() {
    local duration_ms="${__TIMER_DURATION_MS:-0}"
    local text=""
    SEGMENT_TEXT=0
    SEGMENT_WIDTH=0

    if (( duration_ms > 400 )); then
        local formatted
        formatted=$(format_duration "${duration_ms}")
        text=" ${formatted} "

        BG_TIMER=$(timer_color "${duration_ms}" bg)
        if (( duration_ms <= 30000 )); then
            FG_TIMER="${FG_BLACK}"
        else
            FG_TIMER="${FG_WHITE}"
        fi
    fi

    if [[ -n "${text}" ]]; then
        SEGMENT_TEXT="${BG_DEFAULT}$(timer_color "${duration_ms}" fg)${LEFT_SEPARATOR}"
        SEGMENT_TEXT+="${BOLD}${BG_TIMER}${FG_TIMER}${text}"
        SEGMENT_TEXT+="${BG_TIMER}${FG_KK}${LEFT_SEPARATOR}"
        SEGMENT_WIDTH=$(( ${#text} + 1 ))
    else
        SEGMENT_TEXT="${BG_DEFAULT}${FG_KK}${LEFT_SEPARATOR}"
    fi
}

# timer_color dynamically sets the color of
# the timer section based on the time it takes
# to execute a command
timer_color() {
    local ms=$1
    local type=$2

    local max=55000
    (( ms < 0 )) && ms=0
    (( ms > max )) && ms=$max

    local r=0 g=0

    if (( ms <= 20000 )); then
        r=$(( ms * 255 / 20000 ))
        g=255
    elif (( ms <= 40000 )); then
        r=255
        g=$(( (40000 - ms) * 255 / 20000 ))
    else
        r=$(( (60000 - ms) * 255 / 20000 ))
        g=0
    fi

    [[ $type == fg ]] && type=38 || type=48

    printf "\\[\\e[%s;2;%d;%d;79m\\]" "$type" "$r" "$g"
}

# format_duration converts duration (ms) into readable format
format_duration() {
    local ms=$1
    local sec=$(( ms / 1000 ))

    if (( sec < 60 )); then
        printf "%d.%03ds" "$sec" "$(( ms % 1000 ))"
    elif (( sec < 3600 )); then
        printf "%dm %02ds" "$(( sec / 60 ))" "$(( sec % 60 ))"
    else
        printf "%dh %02dm %02ds" "$(( sec / 3600 ))" "$(( (sec % 3600)/60 ))" "$(( sec % 60 ))"
    fi
}
