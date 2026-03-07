#!/usr/bin/env bash

# Runtime states
__TIMER_ACTIVE=0
__LAST_CMDNUM=0
__LAST_ERROR_SOUND=0
__ERROR_SOUND_ENABLED=0

ERROR_SOUND="$HOME/music/faah.mp3"
ERROR_SOUND_COOLDOWN=5 # seconds
BRANCH_ICONS=("𖣂" "𖦥" "⎇")

RIGHT_SEPARATOR=$'\uE0B0'
LEFT_SEPARATOR=$'\uE0B2'
RIGHT_BARRIER=$'\uE0B1'
LEFT_BARRIER=$'\uE0B3'
BARRIER="─"

# Checks if bash supports EPOCHREALTIME (bash >= 5)
if (( BASH_VERSINFO[0] >= 5 )); then
    USE_EPOCHREALTIME=1
else
    USE_EPOCHREALTIME=0
fi

# timer_start starts the command timer
# timer_stop calculates command duration in ms
if (( USE_EPOCHREALTIME )); then
    timer_start() {
        TIMER_START_US=${EPOCHREALTIME/./}
    }
    timer_stop() {
        TIMER_DURATION_MS=$(( (${EPOCHREALTIME/./} - TIMER_START_US) / 1000 ))
    }
else
    timer_start() {
        TIMER_START_MS=$(date +%s%3N)
    }
    timer_stop() {
        TIMER_DURATION_MS=$(( ($(date +%s%3N) - TIMER_START_MS) ))
    }
fi

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

# append_prompt_command safely appends a command to the current PROMPT_COMMAND
append_prompt_command() {
    local cmd="$1"
    if [[ -z "$PROMPT_COMMAND" ]]; then
        PROMPT_COMMAND="$cmd"
    elif [[ ";$PROMPT_COMMAND;" != *";$cmd;"* ]]; then
        PROMPT_COMMAND="${PROMPT_COMMAND%;};$cmd"
    fi
}

# error_sound_on enables the error sound
# error_sound_off disables the error sound
error_sound_on() {
    __ERROR_SOUND_ENABLED=1
    echo "Error sound enabled🔊"
}
error_sound_off() {
    __ERROR_SOUND_ENABLED=0
    echo "Error sound disabled🔇"
}

# toggle_error_sound toggles the error sound on or off
toggle_error_sound() {
    (( __ERROR_SOUND_ENABLED )) \
        && error_sound_off \
        || error_sound_on
}

# play_error_sound plays the error sound if enabled and cooldown has passed
play_error_sound() {
    (( __ERROR_SOUND_ENABLED == 0 )) && return

    local now

    if (( USE_EPOCHREALTIME )); then
        now=${EPOCHREALTIME%.*}
    else
        now=$(date +%s)
    fi

    # Check sound cooldown
    (( now - __LAST_ERROR_SOUND < ERROR_SOUND_COOLDOWN )) && return

    __LAST_ERROR_SOUND=$now
    if command -v mpv &>/dev/null && [[ -f "$ERROR_SOUND" ]]; then
        mpv --no-terminal --really-quiet --af=volume=.75 "$ERROR_SOUND" &>/dev/null &
        disown
    fi
}

# build_prompt assembles the PS1
build_prompt() {
    local exit_code=$?

    # Stop command timer
    if [[ $__TIMER_ACTIVE -eq 1 ]]; then
        timer_stop
        __TIMER_ACTIVE=0
    fi
    local duration_ms="$TIMER_DURATION_MS"
    TIMER_DURATION_MS=0

    # Detect empty or same command as before (HISTCMD doesn't increment)
    if (( HISTCMD == __LAST_CMDNUM )); then
        __CMD_WAS_EMPTY=1
    else
        __CMD_WAS_EMPTY=0
        __LAST_CMDNUM=$HISTCMD
    fi

    # Play error sound only if command isn't the same command as
    # before, and the command failed
    if (( __CMD_WAS_EMPTY == 0 && exit_code != 0 && exit_code != 130 )); then
        play_error_sound
    fi

    # Left section variables
    local branch_icon="${BRANCH_ICONS[RANDOM % ${#BRANCH_ICONS[@]}]}"
    local status_str
    local user_str=" $USER "
    local dir_str=$([[ "$PWD" == "$HOME"* ]] && echo " ~${PWD#$HOME} " || echo " $PWD ")
    local branch branch_str
    branch="$(git_branch)"
    local left_offset=2

    # Right section variables
    local date_str="\D{%Y-%m-%d %H:%M:%S}"
    local duration_str=""
    # Only show command duration if >250ms
    if (( duration_ms > 250 )); then
        local formatted
        formatted=$(format_duration "$duration_ms")
        duration_str=" ${formatted} "

        # Generate dynamic timer background color
        BG_TIMER=$(timer_color "$duration_ms" bg)

        # Choose readable foreground
        if (( duration_ms <= 30000 )); then
            FG_TIMER="${FG_BLACK}"
        else
            FG_TIMER="${FG_WHITE}"
        fi
    fi
    local right_offset=2

    # Left section prompt string
    local left_section=""
    ## Status segment
    if [[ "$exit_code" -eq 0 ]]; then
        status_str=" ✓ "
        left_section+="${INVERT}${FG_KT}${RIGHT_SEPARATOR}${RESET}"
        left_section+="${BOLD}${BG_KT}${FG_BLACK}${status_str}"
        left_section+="${BG_RY}${FG_KT}${RIGHT_SEPARATOR}"
    else
        status_str=" ✗ "
        left_section+="${INVERT}${BG_DEFAULT}${FG_WHITE}${RIGHT_SEPARATOR}${RESET}"
        left_section+="${BOLD}${BG_WHITE}${FG_KT}${status_str}"
        left_section+="${BG_RY}${FG_DEFAULT}${RIGHT_SEPARATOR}"
    fi
    ((left_offset++))
    ## User
    left_section+="${BG_RY}${FG_BLACK}${user_str}"
    left_section+="${BG_NJ}${FG_RY}${RIGHT_SEPARATOR}"
    ((left_offset++))
    ## Directory
    left_section+="${BG_NJ}${FG_BLACK}${dir_str}"
    ((left_offset++))
    ## Git branch (if in git directory)
    if [ -n "$branch" ]; then
        branch_str=" ${branch_icon} ${branch} "
        left_section+="${BG_BC}${FG_NJ}${RIGHT_SEPARATOR}"
        left_section+="${BG_BC}${FG_BLACK}${branch_str}"
        left_section+="${BG_DEFAULT}${FG_BC}${RIGHT_SEPARATOR}${RESET}"
        ((left_offset++))
    else
        left_section+="${BG_DEFAULT}${FG_NJ}${RIGHT_SEPARATOR}${RESET}"
    fi

    # Right section prompt string
    local right_section=""
    ## Command duration
    if [[ -n "$duration_str" ]]; then
        right_section+="${BG_DEFAULT}$(timer_color "$duration_ms" fg)${LEFT_SEPARATOR}"
        right_section+="${BOLD}${BG_TIMER}${FG_TIMER}${duration_str}"
        right_section+="${BG_TIMER}${FG_KK}${LEFT_SEPARATOR}"
        ((right_offset++))
    else
        right_section+="${BG_DEFAULT}${FG_KK}${LEFT_SEPARATOR}"
    fi
    ## Date
    right_section+="${BOLD}${BG_KK}${FG_WHITE} ${date_str} "
    right_section+="${INVERT}${FG_KK}${BG_DEFAULT}${LEFT_SEPARATOR}"
    ((right_offset++))

    # Right section alignment
    local left_length=$(( ${#status_str} + ${#user_str} + ${#dir_str} + ${#branch_str} ))
    local left_pos=$(( left_length + left_offset ))
    local right_length=$(( ${#duration_str} + ${#date_str} ))
    local right_pos=$(( COLUMNS - right_length - right_offset ))

    local barrier_len=$(( right_pos - left_pos ))
    if (( barrier_len < 0 )); then barrier_len=0; fi
    local barrier=""
    for (( i=0; i<barrier_len; i++)); do
        barrier+="$BARRIER"
    done

    PS1="${left_section}${RIGHT_BARRIER}${barrier}${LEFT_BARRIER}${right_section}${RESET}\n$ "
}

# DEBUG trap: starts timer before each command
__timer_debug() {
    [[ $- != *i* ]] && return
    [[ -n "$COMP_LINE" ]] && return
    [[ "$__TIMER_ACTIVE" -eq 1 ]] && return

    case "$BASH_COMMAND" in
        build_prompt|set_goprivate) return ;;
    esac

    __TIMER_ACTIVE=1
    timer_start
}

# Register prompt hooks
append_prompt_command build_prompt
append_prompt_command set_goprivate

# Start timer before commands run
trap '__timer_debug' DEBUG
