#!/usr/bin/env bash

# Runtime states
__LAST_CMDNUM=0

PROMPT_DIR_DEPTH=2

# Powerline characters (unicode)
BRANCH_ICONS=("𖣂" "𖦥" "⎇")
RIGHT_SEPARATOR=$'\uE0B0'   #  - hard separator
LEFT_SEPARATOR=$'\uE0B2'    #  - hard separator (reverse)
RIGHT_BARRIER=$'\uE0B1'     #  - soft separator
LEFT_BARRIER=$'\uE0B3'      #  - soft separator (reverse)
BARRIER="─"

# --- Theme switcher ---
prompt_theme() {
    local theme_name="${1:-}"
    local themes_dir
    themes_dir="$(dirname "${BASH_SOURCE[0]}")/themes"

    if [[ -z "$theme_name" ]]; then
        local names=() max_len=0 name
        for f in "${themes_dir}/"*.sh; do
            name="$(basename "$f" .sh)"
            names+=("$name")
            (( ${#name} > max_len )) && max_len=${#name}
        done

        echo "Available themes:"
        local _r="${RESET//\\[/}"
        _r="${_r//\\]/}"
        for name in "${names[@]}"; do
            source "${themes_dir}/${name}.sh"
            printf "  %-*s  " "$max_len" "$name"
            for c in "$COLOR_ACCENT_BG" "$COLOR_USER_BG" "$COLOR_DIR_BG" "$COLOR_GIT_BG" "$COLOR_META_BG"; do
                local raw="${c//\\[/}"
                raw="${raw//\\]/}"
                printf "${raw}  ${_r}"
            done
            echo ""
        done

        # Re-source current theme
        local current_theme="default"
        [[ -f "${HOME}/.prompt_theme" ]] && current_theme=$(<"${HOME}/.prompt_theme")
        current_theme="${current_theme#PROMPT_THEME=}"
        if [[ -f "${themes_dir}/${current_theme}.sh" ]]; then
            source "${themes_dir}/${current_theme}.sh"
        else
            source "${themes_dir}/default.sh"
        fi
        return 0
    fi

    local theme_file="${themes_dir}/${theme_name}.sh"
    if [[ ! -f "$theme_file" ]]; then
        echo "Theme not found: ${theme_name}" >&2
        echo "Available themes:"
        for f in "${themes_dir}/"*.sh; do
            echo "  $(basename "$f" .sh)"
        done
        return 1
    fi

    source "$theme_file"
    echo "PROMPT_THEME=${theme_name}" > "${HOME}/.prompt_theme"
    echo "Switched to theme: ${theme_name}"
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

    # Bare-minimum fallback if theme system catastrophically failed
    if [[ -z "${COLOR_ACCENT_BG:-}" ]]; then
        PS1='\[\e[0m\]\u@\h \w \$ '
        return
    fi

    stop_timer
    detect_empty_command

    # Play error sound only if command isn't the same command as
    # before, and the command failed
    if (( __CMD_WAS_EMPTY == 0 && exit_code != 0 && exit_code != 130 )); then
        play_error_sound
    elif (( __CMD_WAS_EMPTY )); then
        reset_timer
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
    prompt_segment_duration
    prompt_add_right
    prompt_segment_date
    prompt_add_right

    # Barrier (fill line between left and right)
    local barrier
    barrier=$(prompt_barrier "${left_width}" "${right_width}")

    PS1="${left_section}${RIGHT_BARRIER}${barrier}${LEFT_BARRIER}${right_section}${RESET}\n$ "
}

# Registered in PROMPT_COMMAND (order matters: set_goprivate runs second)
append_prompt_command build_prompt
append_prompt_command set_goprivate
