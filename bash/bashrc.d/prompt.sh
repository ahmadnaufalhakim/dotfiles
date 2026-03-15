#!/usr/bin/env bash

PROMPT_DIR="${BASH_MODULE_DIR}/prompt"
SEGMENTS_DIR="${PROMPT_DIR}/segments"

for f in "${SEGMENTS_DIR}/"*.sh; do
    [[ -r "$f" ]] && source "$f" && echo "prompt sourcing "${f}""
done

for f in "${PROMPT_DIR}/"*.sh; do
    [[ -r "$f" ]] && source "$f"
done
