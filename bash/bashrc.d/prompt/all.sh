#!/usr/bin/env bash

# Runtime states
__LAST_CMDNUM=0

PROMPT_DIR_DEPTH=2

BRANCH_ICONS=("𖣂" "𖦥" "⎇")
RIGHT_SEPARATOR=$'\uE0B0'
LEFT_SEPARATOR=$'\uE0B2'
RIGHT_BARRIER=$'\uE0B1'
LEFT_BARRIER=$'\uE0B3'
BARRIER="─"

# append_prompt_command safely appends a command to the current PROMPT_COMMAND
append_prompt_command() {
    local cmd="$1"
    if [[ -z "$PROMPT_COMMAND" ]]; then
        PROMPT_COMMAND="$cmd"
    elif [[ ";$PROMPT_COMMAND;" != *";$cmd;"* ]]; then
        PROMPT_COMMAND="${PROMPT_COMMAND%;};$cmd"
    fi
}

# detect_empty_command detects if current command is
# empty (or the same) as the previous command (HISTCMD doesn't increment)
detect_empty_command() {
    if (( HISTCMD == __LAST_CMDNUM )); then
        __CMD_WAS_EMPTY=1
    else
        __CMD_WAS_EMPTY=0
        __LAST_CMDNUM=$HISTCMD
    fi
}

# build_prompt assembles the PS1
build_prompt() {
    local exit_code=$?
    local duration_ms

    stop_timer
    detect_empty_command

    # Play error sound only if command isn't the same command as
    # before, and the command failed
    if (( __CMD_WAS_EMPTY == 0 && exit_code != 0 && exit_code != 130 )); then
        play_error_sound
    fi

    # Right section variables
    local date_str="\D{%Y-%m-%d %H:%M:%S}"
    local duration_str=""
    if (( duration_ms > 400 )); then
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

    # Segment temp vars
    SEGMENT_TEXT=""
    SEGMENT_WIDTH=0

    # Left section state
    local left_section=""
    local left_width=0

    # Build left side of the prompt
    prompt_segment_status "$exit_code"
    prompt_add_left
    prompt_segment_user
    prompt_add_left
    prompt_segment_directory
    prompt_add_left
    prompt_segment_branch
    prompt_add_left

    # Right section prompt string
    local right_section=""
    local right_offset=2
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
    local right_length=$(( ${#duration_str} + ${#date_str} ))
    local right_pos=$(( COLUMNS - right_length - right_offset ))

    local barrier_len=$(( right_pos - ( left_width + 1 ) ))
    if (( barrier_len < 0 )); then barrier_len=0; fi
    printf -v barrier '%*s' "$barrier_len" ''
    barrier=${barrier// /$BARRIER}

    PS1="${left_section}${RIGHT_BARRIER}${barrier}${LEFT_BARRIER}${right_section}${RESET}\n$ "
}

# Register prompt hooks
append_prompt_command build_prompt
append_prompt_command set_goprivate
