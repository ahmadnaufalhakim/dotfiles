#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${0}")")/.." && pwd)"
TEMPLATE="${DOTFILES_DIR}/config/opencode/opencode.json.example"
OUTPUT="${HOME}/.config/opencode/opencode.json"
ENV_FILE="${DOTFILES_DIR}/config/.env"

[ -f "${TEMPLATE}" ] || { echo "Missing template: ${TEMPLATE}" >&2; exit 1; }
[ -f "${ENV_FILE}" ] || { echo "Missing ${ENV_FILE} — create it from config/.env.example" >&2; exit 1; }

set -a && source "${ENV_FILE}" && set +a

[ -n "${OPENMODEL_API_KEY:-}" ] || { echo "OPENMODEL_API_KEY not set in ${ENV_FILE}" >&2; exit 1; }

mkdir -p "$(dirname "${OUTPUT}")"
envsubst '${OPENMODEL_API_KEY}' < "${TEMPLATE}" > "${OUTPUT}"

echo "Generated ${OUTPUT}"
