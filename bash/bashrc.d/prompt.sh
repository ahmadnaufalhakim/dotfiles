#!/usr/bin/env bash

# BRANCH_ICONS=("𖣂" "𖦥" "⎇")
BRANCH_ICONS=("𖣂")

RIGHT_SEPARATOR=$'\uE0B0'
LEFT_SEPARATOR=$'\uE0B2'

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
    local exit_code=$?
    local branch="$(git_branch)"
    local branch_icon="${BRANCH_ICONS[RANDOM % ${#BRANCH_ICONS[@]}]}"
    local date_str="\D{%Y-%m-%d %H:%M:%S}"

    # Left section
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
        left_section+="${BG_BC}${FG_BLACK} ${branch_icon} ${BRANCH} ${branch} "
        left_section+="${BG_DEFAULT}${FG_BC}${RIGHT_SEPARATOR}${RESET}"
    else
        left_section+="${BG_DEFAULT}${FG_NJ}${RIGHT_SEPARATOR}${RESET}"
    fi

    # Right section
    local right_section=""
    ## Date
    right_section+="${BG_DEFAULT}${FG_KK}${LEFT_SEPARATOR}"
    right_section+="${BOLD}${BG_KK}${FG_WHITE} ${date_str} "
    right_section+="${INVERT}${FG_KK}${BG_DEFAULT}${LEFT_SEPARATOR}"

    # Right section alignment
    local cols="$COLUMNS"
    local right_length=${#date_str}
    local right_pos=$(( cols - right_length - 1 ))

    PS1="${left_section}\[\e[${right_pos}G\]${right_section}${RESET}\n$ "
}

append_prompt_command build_prompt
append_prompt_command set_goprivate
