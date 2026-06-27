#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${0}")")/.." && pwd)"
TEMPLATE="${DOTFILES_DIR}/config/opencode/opencode.json.example"
OPENCODE_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/opencode"
OUTPUT="${OPENCODE_CONFIG_DIR}/opencode.json"
ENV_FILE="${DOTFILES_DIR}/config/.env"

[ -f "${TEMPLATE}" ] || { echo "Missing template: ${TEMPLATE}" >&2; exit 1; }
[ -f "${ENV_FILE}" ] || { echo "Missing ${ENV_FILE} — create it from config/.env.example" >&2; exit 1; }

set -a && source "${ENV_FILE}" && set +a

[ -n "${OPENMODEL_API_KEY:-}" ] || { echo "OPENMODEL_API_KEY not set in ${ENV_FILE}" >&2; exit 1; }

mkdir -p "$(dirname "${OUTPUT}")"
envsubst '${OPENMODEL_BASE_URL} ${OPENMODEL_API_KEY}' < "${TEMPLATE}" > "${OUTPUT}"

echo "Generated ${OUTPUT}"

# --- sync agent markdown files ---
AGENTS_SRC="${DOTFILES_DIR}/config/opencode/agents"
AGENTS_DST="${OPENCODE_CONFIG_DIR}/agents"
if [ -d "${AGENTS_SRC}" ]; then
  mkdir -p "${AGENTS_DST}"
  cp -r "${AGENTS_SRC}/." "${AGENTS_DST}/"
  echo "Synced agents to ${AGENTS_DST}"
fi
