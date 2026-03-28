#!/usr/bin/env bash

__ERROR_SOUND_ENABLED=1
__LAST_ERROR_SOUND=0

ERROR_SOUND_COOLDOWN=5 # seconds
ERROR_SOUND_DIR="${HOME}/music/effects/error"
ERROR_SOUNDS=()

if [[ -d "$ERROR_SOUND_DIR" ]]; then
    shopt -s nullglob
    ERROR_SOUNDS=("$ERROR_SOUND_DIR"/*.ogg)
    shopt -u nullglob
fi

# _error_sound_on enables the error sound
# _error_sound_off disables the error sound
_error_sound_on() {
    __ERROR_SOUND_ENABLED=1
    echo "Error sound enabled🔊"
}
_error_sound_off() {
    __ERROR_SOUND_ENABLED=0
    echo "Error sound disabled🔇"
}

# toggle_error_sound toggles the error sound on or off
toggle_error_sound() {
    (( __ERROR_SOUND_ENABLED )) \
        && _error_sound_off \
        || _error_sound_on
}

# play_error_sound plays the error sound if enabled and cooldown has passed
play_error_sound() {
    (( !__ERROR_SOUND_ENABLED )) && return
    (( ${#ERROR_SOUNDS[@]} == 0 )) && return

    local now

    if (( USE_EPOCHREALTIME )); then
        now=${EPOCHREALTIME%.*}
    else
        printf -v now '%(%s)T' -1
    fi

    # Check sound cooldown
    (( now - __LAST_ERROR_SOUND < ERROR_SOUND_COOLDOWN )) && return
    __LAST_ERROR_SOUND=$now

    command -v mpv &>/dev/null || return
    local sound=${ERROR_SOUNDS[RANDOM % ${#ERROR_SOUNDS[@]}]}

    mpv --no-terminal --really-quiet --af=volume=.5 "$sound" &>/dev/null &
    disown
}
