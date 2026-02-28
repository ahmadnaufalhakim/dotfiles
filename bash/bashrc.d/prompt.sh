#!/usr/bin/env bash

# BRANCH_ICONS=("𖣂" "𖦥" "⎇")
BRANCH_ICONS=("𖣂")
RIGHT_SEPARATOR=$'\uE0B0'
LEFT_SEPARATOR=$'\uE0B2'

# Check if current bash version is at least 5
if (( BASH_VERSINFO[0] >= 5 )); then
    USE_EPOCHREALTIME=1
else
    USE_EPOCHREALTIME=0
fi

# timer_start starts the timer for the current command
# timer_stop stops the timer after the command is finish running
if (( USE_EPOCHREALTIME )); then
    function timer_start() {
        TIMER_START_MS=$(awk "BEGIN {printf \"%d\", $EPOCHREALTIME * 1000}")
    }
    function timer_stop() {
        local now
        now=$(awk "BEGIN {printf \"%d\", $EPOCHREALTIME * 1000}")
        TIMER_DURATION_MS=$(( now - TIMER_START_MS ))
    }
else
    function timer_start() {
        TIMER_START_MS=$(date +%s%3N)
    }
    function timer_stop() {
        local now=$(date +%s%3N)
        dur_ms=$(( now - TIMER_START_MS ))
        TIMER_DURATION_MS=$(awk "BEGIN {printf \"%.3f\", $dur_ms/1000}")
    }
fi

# timer_color_bg dynamically sets the background color of
# the terminal based on the command time value
timer_color_bg() {
    local ms=$1
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

    printf "\\[\\e[48;2;%d;%d;0m\\]" "$r" "$g"
}

# timer_color_fg dynamically sets the foreground color of
# the terminal based on the command time value
timer_color_fg() {
    local ms=$1
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

    printf "\\[\\e[38;2;%d;%d;0m\\]" "$r" "$g"
}

# append_prompt_command appends a command to the current PROMPT_COMMAND
function append_prompt_command() {
    local cmd="$1"
    case ";$PROMPT_COMMAND" in
        *";$cmd;"*) ;; # already added
        *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}$cmd"
    esac
}

# git_branch prints current git branch
function git_branch() {
    # Check if inside a git directory
    git rev-parse --is-inside-work-tree &>/dev/null || return
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# build_prompt assembles the PS1
function build_prompt() {
    # Left section variables
    local exit_code=$?
    timer_stop
    local branch_icon="${BRANCH_ICONS[RANDOM % ${#BRANCH_ICONS[@]}]}"
    local branch
    branch="$(git_branch)"

    # Right section variables
    local date_str="\D{%Y-%m-%d %H:%M:%S}"
    local duration_str""
    # Only show command duration if >250ms
    if (( TIMER_DURATION_MS > 250 )); then
        local formatted
        formatted=$(awk "BEGIN {printf \"%.3f\", $TIMER_DURATION_MS / 1000}")
        duration_str=" ${formatted}s "

        # Generate dynamic timer background color
        BG_TIMER=$(timer_color_bg "$TIMER_DURATION_MS")

        # Choose readable foreground
        if (( TIMER_DURATION_MS <= 20000 )); then
            FG_TIMER="${FG_BLACK}"
        else
            FG_TIMER="${FG_WHITE}"
        fi
    fi

    # Right section character offset
    local offset=0

    # Left section prompt string
    local left_section=""
    ## Status segment
    if [[ "$exit_code" -eq 0 ]]; then
        left_section+="${INVERT}${FG_KT}${RIGHT_SEPARATOR}${RESET}"
        left_section+="${BOLD}${BG_KT}${FG_BLACK} ✓ "
        left_section+="${BG_RY}${FG_KT}${RIGHT_SEPARATOR}"
    else
        left_section+="${INVERT}${BG_DEFAULT}${FG_WHITE}${RIGHT_SEPARATOR}${RESET}"
        left_section+="${BOLD}${BG_WHITE}${FG_KT} ✗ "
        left_section+="${BG_RY}${FG_DEFAULT}${RIGHT_SEPARATOR}"
    fi
    ## User
    left_section+="${BG_RY}${FG_BLACK} \u "
    left_section+="${BG_NJ}${FG_RY}${RIGHT_SEPARATOR}"
    ## Directory
    left_section+="${BG_NJ}${FG_BLACK} \w "
    ## Git branch (if in git directory)
    if [ -n "$branch" ]; then
        left_section+="${BG_BC}${FG_NJ}${RIGHT_SEPARATOR}"
        left_section+="${BG_BC}${FG_BLACK} ${branch_icon} ${branch} "
        left_section+="${BG_DEFAULT}${FG_BC}${RIGHT_SEPARATOR}${RESET}"
    else
        left_section+="${BG_DEFAULT}${FG_NJ}${RIGHT_SEPARATOR}${RESET}"
    fi

    # Right section prompt string
    local right_section=""
    ## Command duration
    if [[ -n "$duration_str" ]]; then
        right_section+="${BG_DEFAULT}$(timer_color_fg $TIMER_DURATION_MS)${LEFT_SEPARATOR}"
        right_section+="${BOLD}${BG_TIMER}${FG_TIMER}${duration_str}"
        right_section+="${BG_TIMER}${FG_KK}${LEFT_SEPARATOR}"
        ((offset++))
    else
        right_section+="${BG_DEFAULT}${FG_KK}${LEFT_SEPARATOR}"
    fi
    ## Date
    right_section+="${BOLD}${BG_KK}${FG_WHITE} ${date_str} "
    right_section+="${INVERT}${FG_KK}${BG_DEFAULT}${LEFT_SEPARATOR}"
    ((offset++))

    # Right section alignment
    local cols="$COLUMNS"
    local right_length=$(( ${#duration_str} + ${#date_str} ))
    local right_pos=$(( cols - right_length - offset ))

    PS1="${left_section}\[\e[${right_pos}G\]${right_section}${RESET}\n$ "
}

append_prompt_command build_prompt
append_prompt_command set_goprivate
# Start timer before each command
trap '[[ $BASH_COMMAND != "build_prompt" ]] && timer_start' DEBUG
