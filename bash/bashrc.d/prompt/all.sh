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

# short_pwd construct the PWD dir, but shortened
short_pwd() {
    local depth=${1:-$PROMPT_DIR_DEPTH}
    local path

    # Replace $HOME with ~
    if [[ "$PWD" == "$HOME"* ]]; then
        path="~${PWD#$HOME}"
    else
        path="$PWD"
    fi

    # Split into components
    IFS='/' read -ra parts <<< "$path"
    local count=${#parts[@]}

    local tilde=0
    [[ ${parts[0]} == "~" ]] && tilde=1

    if (( count <= depth + tilde )); then
        printf "%s" "$path"
        return
    fi

    local start=$(( count - depth ))
    local result=""
    # Shorten skipped directories to first letter
    for (( i=tilde; i<start; i++ )); do
        result+="${parts[i]:0:1}/"
    done

    # Slice last segment and join with /
    local last_segments
    printf -v last_segments "%s/" "${parts[@]:start:depth}"
    last_segments=${last_segments%/}

    if (( tilde )); then
        printf "~/%s%s" "$result" "$last_segments"
    else
        printf "%s%s" "$result" "$last_segments"
    fi
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

    # Left section variables
    local branch_icon=""
    (( ${#BRANCH_ICONS[@]} > 0 )) && {
        local branch_idx=$(( RANDOM % ${#BRANCH_ICONS[@]} ))
        branch_icon=${BRANCH_ICONS[$branch_idx]}
    }
    local status_str
    local user_str=" $USER "
    local dir_str
    dir_str=" $(short_pwd "$PROMPT_DIR_DEPTH") "
    local branch branch_str
    branch="$(git_branch)"
    local left_offset=2

    # Right section variables
    local date_str="\D{%Y-%m-%d %H:%M:%S}"
    local duration_str=""
    # Only show command duration if >250ms
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
    printf -v barrier '%*s' "$barrier_len" ''
    barrier=${barrier// /$BARRIER}

    PS1="${left_section}${RIGHT_BARRIER}${barrier}${LEFT_BARRIER}${right_section}${RESET}\n$ "
}

# Register prompt hooks
append_prompt_command build_prompt
append_prompt_command set_goprivate
