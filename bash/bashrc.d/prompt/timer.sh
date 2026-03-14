#!/usr/bin/env bash

__TIMER_ACTIVE=0

# Checks if bash supports EPOCHREALTIME (bash >= 5)
if (( BASH_VERSINFO[0] >= 5 )); then
    USE_EPOCHREALTIME=1
else
    USE_EPOCHREALTIME=0
fi

# __timer_on captures the start timestamp
# __timer_off calculates command duration
# since the last __timer_on invokation in ms
if (( USE_EPOCHREALTIME )); then
    __timer_on() {
        __TIMER_START_US=${EPOCHREALTIME/./}
    }
    __timer_off() {
        __TIMER_DURATION_MS=$(( (${EPOCHREALTIME/./} - __TIMER_START_US) / 1000 ))
    }
else
    __timer_on() {
        __TIMER_START_MS=$(date +%s%3N)
    }
    __timer_off() {
        __TIMER_DURATION_MS=$(( $(date +%s%3N) - __TIMER_START_MS ))
    }
fi

# start_timer starts timer before each command
start_timer() {
    [[ $- != *i* ]] && return
    [[ -n "$COMP_LINE" ]] && return
    [[ "$__TIMER_ACTIVE" -eq 1 ]] && return

    case "$BASH_COMMAND" in
        build_prompt|set_goprivate) return ;;
    esac

    __TIMER_ACTIVE=1
    __timer_on
}

# stop_timer stops timer after each command
stop_timer() {
    if (( !__TIMER_ACTIVE )); then
        duration_ms=0
        return
    fi

    __timer_off
    __TIMER_ACTIVE=0
    duration_ms=$__TIMER_DURATION_MS
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