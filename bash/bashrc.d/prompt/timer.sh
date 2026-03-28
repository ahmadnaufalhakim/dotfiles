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
    (( __TIMER_ACTIVE )) || return

    __timer_off
    __TIMER_ACTIVE=0
}

# reset_timer resets the __TIMER_DURATION_MS value back to 0
reset_timer() {
    __TIMER_DURATION_MS=0
}
