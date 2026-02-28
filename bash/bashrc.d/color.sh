#!/usr/bin/env bash

# Reset
RESET="\[\e[0m\]"
# Bold text
BOLD="\[\e[1m\]"
# Blink
BLINK="\[\e[5m\]"
# Invert fg/bg
INVERT="\[\e[7m\]"

# Background colors
BG_BLACK="\[\e[40m\]"
BG_RED="\[\e[41m\]"
BG_GREEN="\[\e[42m\]"
BG_YELLOW="\[\e[43m\]"
BG_BLUE="\[\e[44m\]"
BG_PURPLE="\[\e[45m\]"
BG_CYAN="\[\e[46m\]"
BG_WHITE="\[\e[47m\]"
BG_DEFAULT="\[\e[49m\]"

BG_BBLACK="\[\e[100m\]"
BG_BRED="\[\e[101m\]"
BG_BGREEN="\[\e[102m\]"
BG_BYELLOW="\[\e[103m\]"
BG_BBLUE="\[\e[104m\]"
BG_BMAGENTA="\[\e[105m\]"
BG_BCYAN="\[\e[106m\]"
BG_BWHITE="\[\e[107m\]"

# Foreground colors
FG_BLACK="\[\e[30m\]"
FG_RED="\[\e[31m\]"
FG_GREEN="\[\e[32m\]"
FG_YELLOW="\[\e[33m\]"
FG_BLUE="\[\e[34m\]"
FG_MAGENTA="\[\e[35m\]"
FG_CYAN="\[\e[36m\]"
FG_WHITE="\[\e[37m\]"
FG_DEFAULT="\[\e[39m\]"

FG_BBLACK="\[\e[90m\]"
FG_BRED="\[\e[91m\]"
FG_BGREEN="\[\e[92m\]"
FG_BYELLOW="\[\e[93m\]"
FG_BBLUE="\[\e[94m\]"
FG_BMAGENTA="\[\e[95m\]"
FG_BCYAN="\[\e[96m\]"
FG_BWHITE="\[\e[97m\]"

# keyword: ANSI escape codes
# bzr in truecolor (24-bit)
BG_KT="\[\e[48;2;235;0;0m\]"
BG_RY="\[\e[48;2;52;120;240m\]"
BG_NJ="\[\e[48;2;240;196;40m\]"
BG_BC="\[\e[48;2;255;95;175m\]"
BG_KK="\[\e[48;2;128;50;82m\]"

FG_KT="\[\e[38;2;235;0;0m\]"
FG_RY="\[\e[38;2;52;120;240m\]"
FG_NJ="\[\e[38;2;240;196;40m\]"
FG_BC="\[\e[38;2;255;95;175m\]"
FG_KK="\[\e[38;2;128;50;82m\]"

# Custom colors
BG_TIMER="\[\e[48;2;190;52;85m\]"
FG_TIMER="\[\e[38;2;190;52;85m\]"
