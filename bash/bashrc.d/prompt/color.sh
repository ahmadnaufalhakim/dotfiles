#!/usr/bin/env bash

# Reset
RESET="\[\e[0m\]"
# Bold text
BOLD="\[\e[1m\]"
# Blink
BLINK="\[\e[5m\]"
# Invert fg/bg
INVERT="\[\e[7m\]"

# Background colors (standard 8 + default)
BG_BLACK="\[\e[40m\]"
BG_RED="\[\e[41m\]"
BG_GREEN="\[\e[42m\]"
BG_YELLOW="\[\e[43m\]"
BG_BLUE="\[\e[44m\]"
BG_PURPLE="\[\e[45m\]"
BG_CYAN="\[\e[46m\]"
BG_WHITE="\[\e[47m\]"
BG_DEFAULT="\[\e[49m\]"

# Background colors (bright)
BG_BBLACK="\[\e[100m\]"
BG_BRED="\[\e[101m\]"
BG_BGREEN="\[\e[102m\]"
BG_BYELLOW="\[\e[103m\]"
BG_BBLUE="\[\e[104m\]"
BG_BMAGENTA="\[\e[105m\]"
BG_BCYAN="\[\e[106m\]"
BG_BWHITE="\[\e[107m\]"

# Foreground colors (standard 8 + default)
FG_BLACK="\[\e[30m\]"
FG_RED="\[\e[31m\]"
FG_GREEN="\[\e[32m\]"
FG_YELLOW="\[\e[33m\]"
FG_BLUE="\[\e[34m\]"
FG_MAGENTA="\[\e[35m\]"
FG_CYAN="\[\e[36m\]"
FG_WHITE="\[\e[37m\]"
FG_DEFAULT="\[\e[39m\]"

# Foreground colors (bright)
FG_BBLACK="\[\e[90m\]"
FG_BRED="\[\e[91m\]"
FG_BGREEN="\[\e[92m\]"
FG_BYELLOW="\[\e[93m\]"
FG_BBLUE="\[\e[94m\]"
FG_BMAGENTA="\[\e[95m\]"
FG_BCYAN="\[\e[96m\]"
FG_BWHITE="\[\e[97m\]"

# --- Theme system ---
__PROMPT_DIR="${BASH_SOURCE[0]%/*}"

__load_theme() {
    local theme_file="${__PROMPT_DIR}/themes/${1}.sh"
    [[ -f "$theme_file" ]] && source "$theme_file" && return 0
    return 1
}

# Fallback chain: saved theme > PROMPT_THEME > default.sh > inline Bocchi > bare PS1
__THEME_NAME="${PROMPT_THEME:-default}"
[[ -f "${HOME}/.prompt_theme" ]] && __THEME_NAME=$(<"${HOME}/.prompt_theme")
__THEME_NAME="${__THEME_NAME#PROMPT_THEME=}"

if ! __load_theme "$__THEME_NAME"; then
    if [[ "$__THEME_NAME" != "default" ]] && __load_theme "default"; then
        :
    else
        # Inline Bocchi fallback (hardcoded default theme)
        COLOR_ACCENT_BG="\[\e[48;2;235;0;0m\]"; COLOR_ACCENT_FG="\[\e[38;2;235;0;0m\]"
        COLOR_USER_BG="\[\e[48;2;52;120;240m\]";   COLOR_USER_FG="\[\e[38;2;52;120;240m\]"
        COLOR_DIR_BG="\[\e[48;2;240;196;40m\]";    COLOR_DIR_FG="\[\e[38;2;240;196;40m\]"
        COLOR_GIT_BG="\[\e[48;2;255;95;175m\]";    COLOR_GIT_FG="\[\e[38;2;255;95;175m\]"
        COLOR_META_BG="\[\e[48;2;128;50;82m\]";    COLOR_META_FG="\[\e[38;2;128;50;82m\]"
    fi
fi
