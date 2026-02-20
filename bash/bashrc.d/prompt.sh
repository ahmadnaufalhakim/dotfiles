#!/usr/bin/env bash

BRANCH_ICONS=("𖣂" "𖦥" "⎇")

RIGHT_SEPARATOR=$'\uE0B0'
LEFT_SEPARATOR=$'\uE0B2'

# git_branch prints current git branch
git_branch() {
    # Check if inside a git directory
    git rev-parse --is-inside-work-tree &>/dev/null || return
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# build_prompt assembles the PS1
build_prompt() {
    local exit_code=$?
    local branch="$(git_branch)"
    local branch_icon="${BRANCH_ICONS[RANDOM % ${#BRANCH_ICONS[@]}]}"

    PS1=""

    # Status segment
    if [[ "$exit_code" -eq 0 ]]; then
        PS1+="${INVERT}${FG_ORANGE}${RIGHT_SEPARATOR}${RESET}"
        PS1+="${BOLD}${BG_ORANGE}${FG_BLACK} ✓ "
        PS1+="${BG_BLUE}${FG_ORANGE}${RIGHT_SEPARATOR}"
    else
        PS1+="${INVERT}${FG_RED}${RIGHT_SEPARATOR}${RESET}"
        PS1+="${BOLD}${BG_RED}${FG_BLACK} ✗ "
        PS1+="${BG_BLUE}${FG_RED}${RIGHT_SEPARATOR}"
    fi

    # User
    PS1+="${BG_BLUE}${FG_BLACK} \u "
    PS1+="${BG_YELLOW}${FG_BLUE}${RIGHT_SEPARATOR}"

    # Directory
    PS1+="${BG_YELLOW}${FG_BLACK} \w "

    # Git branch (if in git directory)
    if [ -n "$branch" ]; then
        PS1+="${BG_PINK}${FG_YELLOW}${RIGHT_SEPARATOR}"
        PS1+="${BG_PINK}${FG_BLACK} ${branch_icon} ${BRANCH} ${branch} "
        PS1+="${BG_DEFAULT}${FG_PINK}${RIGHT_SEPARATOR}"
    else
        PS1+="${BG_DEFAULT}${FG_YELLOW}${RIGHT_SEPARATOR}"
    fi

    PS1+="${RESET}\n$ "
}

append_prompt_command build_prompt
append_prompt_command set_goprivate
