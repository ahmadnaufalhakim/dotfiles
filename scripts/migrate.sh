#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="$(cd "$(dirname "$0")/.." && pwd)/migrations"

usage() {
    echo "Usage: $(basename "$0") <command>"
    echo ""
    echo "Commands:"
    echo "  up               Apply all pending migrations"
    echo "  down             Rollback the last batch of migrations"
    echo "  new <name>       Create a new migration pair"
}

case "${1:-}" in
    up)
        if command -v migrate >/dev/null 2>&1; then
            shift
            migrate -path "$MIGRATIONS_DIR" "$@"
        else
            echo "migrate CLI not found."
            echo "Install with: go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest"
            echo ""
            echo "Pending migrations in: $MIGRATIONS_DIR"
            for f in "$MIGRATIONS_DIR"/*.up.sql; do
                [ -f "$f" ] && echo "  $(basename "$f")"
            done
        fi
        ;;
    down)
        if command -v migrate >/dev/null 2>&1; then
            shift
            migrate -path "$MIGRATIONS_DIR" down "$@"
        else
            echo "migrate CLI not found."
            echo "Install with: go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest"
            echo ""
            echo "Applied migrations in: $MIGRATIONS_DIR"
            for f in "$MIGRATIONS_DIR"/*.down.sql; do
                [ -f "$f" ] && echo "  $(basename "$f")"
            done
        fi
        ;;
    new)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $(basename "$0") new <name>"
            exit 1
        fi
        mkdir -p "$MIGRATIONS_DIR"
        ts=$(date -u +%Y%m%d%H%M%S)
        name="$2"
        up_file="$MIGRATIONS_DIR/${ts}_${name}.up.sql"
        down_file="$MIGRATIONS_DIR/${ts}_${name}.down.sql"

        cat > "$up_file" <<-EOF
		-- Migration: ${name}
		-- Created at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

		BEGIN;

		-- Your migration SQL here

		COMMIT;
		EOF

        cat > "$down_file" <<-EOF
		-- Rollback: ${name}
		-- Created at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

		BEGIN;

		-- Your rollback SQL here

		COMMIT;
		EOF

        echo "Created:"
        echo "  $up_file"
        echo "  $down_file"
        ;;
    *)
        usage
        exit 1
        ;;
esac
