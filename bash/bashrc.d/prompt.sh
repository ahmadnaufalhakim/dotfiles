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

    PS1=""

    # Status segment
    if [[ "$exit_code" -eq 0 ]]; then
        PS1+="${INVERT}${FG_KT}${RIGHT_SEPARATOR}${RESET}"
        PS1+="${BOLD}${BG_KT}${FG_BLACK} ✓ "
        PS1+="${BG_RY}${FG_KT}${RIGHT_SEPARATOR}"
    else
        PS1+="${INVERT}${BG_DEFAULT}${FG_WHITE}${RIGHT_SEPARATOR}${RESET}"
        PS1+="${BOLD}${BG_WHITE}${FG_KT} ✗ "
        PS1+="${BG_RY}${FG_DEFAULT}${RIGHT_SEPARATOR}"
    fi

    # User
    PS1+="${BG_RY}${FG_BLACK} \u "
    PS1+="${BG_NJ}${FG_RY}${RIGHT_SEPARATOR}"

    # Directory
    PS1+="${BG_NJ}${FG_BLACK} \w "

    # Git branch (if in git directory)
    if [ -n "$branch" ]; then
        PS1+="${BG_BC}${FG_NJ}${RIGHT_SEPARATOR}"
        PS1+="${BG_BC}${FG_BLACK} ${branch_icon} ${BRANCH} ${branch} "
        PS1+="${BG_DEFAULT}${FG_BC}${RIGHT_SEPARATOR}"
    else
        PS1+="${BG_DEFAULT}${FG_NJ}${RIGHT_SEPARATOR}"
    fi

    PS1+="${RESET}\n$ "
}

append_prompt_command build_prompt
append_prompt_command set_goprivate
