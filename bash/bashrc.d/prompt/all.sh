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
    # local duration_ms

    stop_timer
    detect_empty_command

    # Play error sound only if command isn't the same command as
    # before, and the command failed
    if (( __CMD_WAS_EMPTY == 0 && exit_code != 0 && exit_code != 130 )); then
        play_error_sound
    fi

    # Segment temp vars
    SEGMENT_TEXT=""
    SEGMENT_WIDTH=0

    # Left section state
    local left_section=""
    local left_width=0
    # Build left side of the prompt
    prompt_segment_status "${exit_code}"
    prompt_add_left
    prompt_segment_user
    prompt_add_left
    prompt_segment_directory
    prompt_add_left
    prompt_segment_branch
    prompt_add_left

    # Right section state
    local right_section=""
    local right_width=0
    # Build right side of the prompt
    prompt_segment_duration "${duration_ms}"
    prompt_add_right
    prompt_segment_date
    prompt_add_right

    local barrier
    barrier=$(prompt_barrier "${left_width}" "${right_width}")

    PS1="${left_section}${RIGHT_BARRIER}${barrier}${LEFT_BARRIER}${right_section}${RESET}\n$ "
}

# Register prompt hooks
append_prompt_command build_prompt
append_prompt_command set_goprivate
