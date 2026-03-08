#!/usr/bin/env bash

# compress_audio_to_ogg compresses any audio files into *.ogg extension
compress_audio_to_ogg() {
    local input="$1"
    local output="${2:-${input%.*}.ogg}"

    [[ -z "$input" ]] && {
        echo "Usage: compress_audio_to_ogg <input_audio> [output_audio]"; \
        return 1
    }
    
    command -v ffmpeg &>/dev/null || {
        echo "ffmpeg not installed"
        return 1
    }

    [[ ! -f "$input" ]] && {
        echo "File not found: $input"
        return 1
    }

    ffmpeg -y -i "$input" \
        -ac 1 \
        -ar 16000 \
        -c:a libvorbis -q:a 3 \
        "$output"

    echo "Saved: $output"
}
