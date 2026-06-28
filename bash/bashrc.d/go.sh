#!/usr/bin/env bash

# Check for Go binary
if [ -x /usr/local/go/bin/go ]; then
    export PATH="/usr/local/go/bin:$PATH"
fi

# Configure Go environment variable
export GOPATH="${GOPATH:-$HOME/go}"
case ":$PATH:" in
    *":$GOPATH/bin:"*) ;;
    *) export PATH="$GOPATH/bin:$PATH" ;;
esac

# set_goprivate sets Go GOPRIVATE environment variable
set_goprivate() {
    command -v go &>/dev/null || return

    local in_work=0
    [[ "$PWD" == "$HOME/coding/work"* ]] && in_work=1

    # Only update GOPRIVATE when directory state changed
    if [[ "$in_work" != "$__LAST_GOPRIVATE_STATE" ]]; then
        if (( in_work )); then
            go env -w GOPRIVATE="$GOPRIVATE_DOMAIN"
        else
            go env -u GOPRIVATE
        fi

        # Cache directory state
        __LAST_GOPRIVATE_STATE=$in_work
    fi
}

# init_go bootstraps a Go project interactively
init_go() {
    local project_name="${1:-}"
    local target_dir="."

    if [[ -z "$project_name" ]]; then
        local dir_basename
        dir_basename="$(basename "$(pwd)")"
        read -rp "Bootstrap Go project in '${dir_basename}'? (y/n) " confirm
        [[ "$confirm" == "y" ]] || return 1
        read -rp "Are you really sure? (y/n) " confirm
        [[ "$confirm" == "y" ]] || return 1
        project_name="$dir_basename"
        target_dir="."
    else
        target_dir="$project_name"
        if [[ -d "$target_dir" ]]; then
            echo "Directory already exists: $target_dir" >&2
            return 1
        fi
        mkdir -p "$target_dir"
    fi

    cd "$target_dir"

    local project_type=""
    while [[ -z "$project_type" ]]; do
        echo ""
        echo "What type of project?"
        echo "  1) CLI     — Command-line app. Flag parsing (plain or Cobra)."
        echo "  2) Web API — HTTP server with handler/service/repository layers."
        read -rp "Pick [1/2]: " choice
        case "$choice" in
            1) project_type="cli" ;;
            2) project_type="web" ;;
            *) echo "Invalid choice." ;;
        esac
    done

    local use_cobra=""
    if [[ "$project_type" == "cli" ]]; then
        while [[ -z "$use_cobra" ]]; do
            echo ""
            echo "Use Cobra CLI framework?"
            echo "  1) Yes — Standard CLI framework (used by Docker, K8s, Hugo). Adds cmd/ tree."
            echo "  2) No  — Plain flag package. Single main.go + internal/app/."
            read -rp "Pick [1/2]: " choice
            case "$choice" in
                1) use_cobra="yes" ;;
                2) use_cobra="no" ;;
                *) echo "Invalid choice." ;;
            esac
        done
    fi

    local framework=""
    if [[ "$project_type" == "web" ]]; then
        while [[ -z "$framework" ]]; do
            echo ""
            echo "Which HTTP framework?"
            echo "  1) net/http — Standard library. Zero dependencies."
            echo "  2) Chi      — Lightweight router. Idiomatic stdlib-compatible handlers."
            echo "  3) Gin      — Full-featured framework. Very popular."
            echo "  4) Echo     — Minimalist. Fast, with built-in middleware."
            read -rp "Pick [1-4]: " choice
            case "$choice" in
                1) framework="nethttp" ;;
                2) framework="chi" ;;
                3) framework="gin" ;;
                4) framework="echo" ;;
                *) echo "Invalid choice." ;;
            esac
        done
    fi

    local module_path="github.com/ahmadnaufalhakim/${project_name}"

    # --- Create directory structure ---
    mkdir -p "internal"
    if [[ "$project_type" == "cli" ]]; then
        mkdir -p "internal/app"
        [[ "$use_cobra" == "yes" ]] && mkdir -p "cmd"
    fi
    if [[ "$project_type" == "web" ]]; then
        mkdir -p "internal/config" "internal/handler" "internal/service" "internal/repository" \
                 "migrations" "scripts"
    fi

    # --- Write files ---

    # .gitignore
    cat > ".gitignore" <<'EOF'
build/
*.o
*.obj
*.exe
*.out
*.swp
*.swo
*~
.DS_Store
.vscode/
.air.toml
EOF

    # Makefile (uses @@ placeholders for sed substitution)
    cat > "Makefile" << 'MAKEEOF'
APP_NAME    := @@APP_NAME@@
MODULE_PATH := @@MODULE_PATH@@

GIT_COMMIT  := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_AUTHOR  := $(shell git log -1 --format='%an' 2>/dev/null || echo "unknown")
BUILD_DATE  := $(shell date -u '+%Y-%m-%dT%H:%M:%SZ')
VERSION     := $(shell git describe --tags 2>/dev/null || echo "dev")

LDFLAGS := -ldflags "\
    -X $${MODULE_PATH}/main.Version=$${VERSION} \
    -X $${MODULE_PATH}/main.Commit=$${GIT_COMMIT} \
    -X $${MODULE_PATH}/main.Date=$${BUILD_DATE} \
    -X $${MODULE_PATH}/main.Author=$${GIT_AUTHOR}"

.PHONY: dev download build run test tidy lint migrate migrate-new

dev:
	@command -v air >/dev/null 2>&1 || { echo "Missing: air — install with 'go install github.com/cosmtrek/air@latest'"; exit 1; }
	air

download:
	go mod download

build:
	mkdir -p build
	go build $${LDFLAGS} -o build/$${APP_NAME} .

run:
	go run .

test:
	go test ./... -v

tidy:
	go mod tidy

lint:
	@command -v golangci-lint >/dev/null 2>&1 || { echo "Missing: golangci-lint — install from https://golangci-lint.run/"; exit 1; }
	golangci-lint run ./...

migrate:
	./scripts/migrate.sh up

migrate-new:
	@read -p "Migration name: " name; ./scripts/migrate.sh new $$name
MAKEEOF

    sed -i "s|@@APP_NAME@@|${project_name}|g; s|@@MODULE_PATH@@|${module_path}|g" "Makefile"

    # --- CLI plain (no Cobra) ---
    if [[ "$project_type" == "cli" && "$use_cobra" == "no" ]]; then
        cat > "main.go" <<EOF
package main

import (
	"flag"
	"fmt"
	"os"

	"${module_path}/internal/app"
)

var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
	author  = "unknown"
)

func main() {
	showVersion := flag.Bool("version", false, "Show version information")
	flag.Parse()

	if *showVersion {
		fmt.Printf("Version: %s\nCommit: %s\nDate: %s\nAuthor: %s\n", version, commit, date, author)
		os.Exit(0)
	}

	app.Run()
}
EOF

        cat > "internal/app/run.go" <<EOF
package app

import "fmt"

func Run() {
	fmt.Println("Hello from ${project_name}!")
}
EOF

    # --- CLI with Cobra ---
    elif [[ "$project_type" == "cli" && "$use_cobra" == "yes" ]]; then
        cat > "main.go" <<EOF
package main

import (
	"${module_path}/cmd"
)

var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
	author  = "unknown"
)

func main() {
	cmd.Execute(version, commit, date, author)
}
EOF

        cat > "cmd/root.go" <<EOF
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"${module_path}/internal/app"
)

var (
	version string
	commit  string
	date    string
	author  string
)

var rootCmd = &cobra.Command{
	Use:   "${project_name}",
	Short: "${project_name} - a CLI application",
	RunE: func(cmd *cobra.Command, args []string) error {
		app.Run()
		return nil
	},
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Show version information",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Version: %s\nCommit: %s\nDate: %s\nAuthor: %s\n", version, commit, date, author)
	},
}

func Execute(v, c, d, a string) {
	version = v
	commit = c
	date = d
	author = a

	rootCmd.AddCommand(versionCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
	}
}
EOF

        cat > "internal/app/run.go" <<EOF
package app

import "fmt"

func Run() {
	fmt.Println("Hello from ${project_name}!")
}
EOF

    # --- Web API ---
    elif [[ "$project_type" == "web" ]]; then
        cat > "internal/config/config.go" <<'EOF'
package config

import "os"

type Config struct {
	Port        string
	DatabaseURL string
	Environment string
}

func Load() *Config {
	return &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: getEnv("DATABASE_URL", ""),
		Environment: getEnv("ENVIRONMENT", "development"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
EOF

        cat > "internal/repository/repository.go" <<'EOF'
package repository

import "fmt"

type Repository struct{}

func New() *Repository {
	return &Repository{}
}

func (r *Repository) FindUserByID(id string) (string, error) {
	return fmt.Sprintf("data:user:%s", id), nil
}
EOF

        cat > "internal/service/service.go" <<EOF
package service

import (
	"fmt"

	"${module_path}/internal/repository"
)

type Service struct {
	repo *repository.Repository
}

func New(repo *repository.Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetUser(id string) (string, error) {
	user, err := s.repo.FindUserByID(id)
	if err != nil {
		return "", fmt.Errorf("service: %w", err)
	}
	return user, nil
}
EOF

        if [[ "$framework" == "nethttp" || "$framework" == "chi" ]]; then
            cat > "internal/handler/handler.go" <<EOF
package handler

import (
	"encoding/json"
	"net/http"

	"${module_path}/internal/service"
)

type Handler struct {
	svc *service.Service
}

func New(svc *service.Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) Health(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
EOF
        elif [[ "$framework" == "gin" ]]; then
            cat > "internal/handler/handler.go" <<EOF
package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"${module_path}/internal/service"
)

type Handler struct {
	svc *service.Service
}

func New(svc *service.Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) Health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
EOF
        elif [[ "$framework" == "echo" ]]; then
            cat > "internal/handler/handler.go" <<EOF
package handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"${module_path}/internal/service"
)

type Handler struct {
	svc *service.Service
}

func New(svc *service.Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) Health(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{"status": "ok"})
}
EOF
        fi

        # Framework-specific main.go
        if [[ "$framework" == "nethttp" ]]; then
            cat > "main.go" <<EOF
package main

import (
	"net/http"

	"${module_path}/internal/config"
	"${module_path}/internal/handler"
	"${module_path}/internal/repository"
	"${module_path}/internal/service"
)

var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
	author  = "unknown"
)

func main() {
	cfg := config.Load()
	repo := repository.New()
	svc := service.New(repo)
	h := handler.New(svc)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/health", h.Health)

	http.ListenAndServe(":"+cfg.Port, mux)
}
EOF
        elif [[ "$framework" == "chi" ]]; then
            cat > "main.go" <<EOF
package main

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"${module_path}/internal/config"
	"${module_path}/internal/handler"
	"${module_path}/internal/repository"
	"${module_path}/internal/service"
)

var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
	author  = "unknown"
)

func main() {
	cfg := config.Load()
	repo := repository.New()
	svc := service.New(repo)
	h := handler.New(svc)

	r := chi.NewRouter()
	r.Get("/api/health", h.Health)

	http.ListenAndServe(":"+cfg.Port, r)
}
EOF
        elif [[ "$framework" == "gin" ]]; then
            cat > "main.go" <<EOF
package main

import (
	"github.com/gin-gonic/gin"
	"${module_path}/internal/config"
	"${module_path}/internal/handler"
	"${module_path}/internal/repository"
	"${module_path}/internal/service"
)

var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
	author  = "unknown"
)

func main() {
	cfg := config.Load()
	repo := repository.New()
	svc := service.New(repo)
	h := handler.New(svc)

	r := gin.Default()
	r.GET("/api/health", h.Health)

	r.Run(":" + cfg.Port)
}
EOF
        elif [[ "$framework" == "echo" ]]; then
            cat > "main.go" <<EOF
package main

import (
	"github.com/labstack/echo/v4"
	"${module_path}/internal/config"
	"${module_path}/internal/handler"
	"${module_path}/internal/repository"
	"${module_path}/internal/service"
)

var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
	author  = "unknown"
)

func main() {
	cfg := config.Load()
	repo := repository.New()
	svc := service.New(repo)
	h := handler.New(svc)

	e := echo.New()
	e.GET("/api/health", h.Health)

	e.Logger.Fatal(e.Start(":" + cfg.Port))
}
EOF
        fi

        # Migration files
        cat > "scripts/migrate.sh" <<'SCRIPTEOF'
#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="$(cd "$(dirname "$0")/.." && pwd)/migrations"

usage() {
    echo "Usage: $(basename "$0") <command>"
    echo ""
    echo "Commands:"
    echo "  up               Apply all pending migrations"
    echo "  down             Rollback the last batch"
    echo "  new <name>       Create a new migration pair"
}

case "${1:-}" in
    up)
        if command -v migrate >/dev/null 2>&1; then
            shift
            migrate -path "$MIGRATIONS_DIR" "$@"
        else
            echo "migrate CLI not found. Pending migrations in: $MIGRATIONS_DIR"
            ls "$MIGRATIONS_DIR"/*.up.sql 2>/dev/null || echo "  (none)"
        fi
        ;;
    down)
        if command -v migrate >/dev/null 2>&1; then
            shift
            migrate -path "$MIGRATIONS_DIR" down "$@"
        else
            echo "migrate CLI not found. Applied migrations in: $MIGRATIONS_DIR"
            ls "$MIGRATIONS_DIR"/*.down.sql 2>/dev/null || echo "  (none)"
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
		BEGIN;
		-- Your migration SQL here
		COMMIT;
		EOF
        cat > "$down_file" <<-EOF
		-- Rollback: ${name}
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
SCRIPTEOF

        chmod +x "scripts/migrate.sh"

        cat > "migrations/20240628000001_create_users.up.sql" <<'SQLEOF'
BEGIN;

CREATE TABLE users (
    id         BIGSERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMIT;
SQLEOF

        cat > "migrations/20240628000001_create_users.down.sql" <<'SQLEOF'
BEGIN;

DROP TABLE IF EXISTS users;

COMMIT;
SQLEOF

    fi

    # --- Post-scaffold ---
    command -v go >/dev/null 2>&1 || { echo "Go is not installed. Install it manually." >&2; exit 1; }

    go mod init "${module_path}"

    if [[ "$project_type" == "cli" && "$use_cobra" == "yes" ]]; then
        go get github.com/spf13/cobra
    elif [[ "$project_type" == "web" ]]; then
        case "$framework" in
            chi)   go get github.com/go-chi/chi/v5 ;;
            gin)   go get github.com/gin-gonic/gin ;;
            echo)  go get github.com/labstack/echo/v4 ;;
        esac
    fi

    go mod tidy
    git init

    if [[ -n "${original_project_name:+x}" || "$project_name" != "$(basename "$(pwd)")" ]]; then
        cd "$project_name" 2>/dev/null || true
    fi

    echo ""
    echo "Initialized Go project: $(pwd)"
    echo "  Type: ${project_type}"
    if [[ "$project_type" == "cli" ]]; then
        echo "  Cobra: ${use_cobra}"
    fi
    if [[ "$project_type" == "web" ]]; then
        echo "  Framework: ${framework}"
    fi
    echo ""
    echo "  make dev         — Start with live-reload (air)"
    echo "  make build       — Build with version info injected"
    echo "  make test        — Run tests"
    echo "  make run         — Run the application"
    echo "  make tidy        — Tidy dependencies"
    echo "  make lint        — Lint with golangci-lint"
    if [[ "$project_type" == "web" ]]; then
        echo "  make migrate     — Run pending migrations"
        echo "  make migrate-new — Create a new migration"
    fi
}
