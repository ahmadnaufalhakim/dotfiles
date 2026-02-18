#!/usr/bin/env bash

BRANCH_ICONS=("𖣂" "𖦥" "⎇")

# git_branch prints current git branch
git_branch() {
    # Check if inside a git directory
    git rev-parse --is-inside-work-tree &>/dev/null || return
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# prompt_status prints the exit code of the last command
prompt_status() {
    local exit_code=$?

    if [[ "$exit_code" -eq 0 ]]; then
        printf "${BG_ORANGE}${FG_BLACK} ✓ ${RESET}"
    else
        printf "${BG_RED}${FG_BLACK} ✗ ${RESET}"
    fi
}

# build_prompt assembles the PS1
build_prompt() {
    local status="$(prompt_status)"
    local branch="$(git_branch)"

    PS1="${status}"
    PS1+="${BG_BLUE}${FG_BLACK} \u ${RESET}"
    PS1+="${BG_YELLOW}${FG_BLACK} \w ${RESET}"

    if [ -n "$branch" ]; then
        local branch_icon="${BRANCH_ICONS[RANDOM % ${#BRANCH_ICONS[@]}]}"
        PS1+="${BG_PINK}${FG_BLACK} ${branch_icon} ${branch} ${RESET}"
    fi

    PS1+="\n$ "
}

append_prompt_command build_prompt
append_prompt_command set_goprivate
