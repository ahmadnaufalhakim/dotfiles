# Global preferences for Ahmad Naufal Hakim (@ahmadnaufalhakim)

These rules apply to every opencode session on this machine.

## About me

- **Name:** Ahmad Naufal Hakim
- **Email:** ahmadnaufalhakim@gmail.com
- **GitHub/Git:** ahmadnaufalhakim
- **Editor:** VSCode
- **Shell:** bash on Linux
- **Git editor:** nano
- **Device:** personal Linux machine (single user: hakim)

## Coding preferences

### Git commits
- Prefix commits with conventional types: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Example: `feat(auth): add user authentication endpoints`, `fix(feature-name): fix query when getting list`

### Code style
- **Functional style** — prefer pure functions, avoid classes
- **Bash** — make sure to enclose any variable names with curly brackets
- **Go-style error handling** — explicit error checking, early returns
- **TypeScript/JavaScript** — ES modules (import/export), not CommonJS (require/module.exports)
- **C/C++** — use `-Wall -Wextra -Wpedantic` flags, C11 standard
- **File naming** — use screaming/uppercase names for key config files (e.g., `Makefile`, `AGENTS.md`, `Dockerfile`)
- No unnecessary comments in code

### Testing
- Write tests
- Do NOT ask me before every test — run them as you go after significant incremental changes to a function/feature
- Only ask me about testing if there is ambiguity in how to test something, or if tests would require significant setup

### Languages I work with (confidence level)
- **Go** — primary, very comfortable
- **TypeScript / JavaScript** — very comfortable, prefer ES modules
- **Python** — comfortable
- **C / C++** — comfortable, use C11
- **Rust** — interested in learning

## Development environment

### Dotfiles management
- Dotfiles live at `~/dotfiles/` and are managed via the `install.sh` script
- The repo is at `~/dotfiles/` which is a git repo pushed to GitHub
- Config files are loaded via source/include hooks (not symlinks, except for opencode)

### Go
- `GOPATH` at `$HOME/go`, `GOPATH/bin` on PATH
- `GOPRIVATE` auto-sets when inside `~/coding/work/` (via `set_goprivate`)

### Git config
- **Personal:** name `ahmadnaufalhakim`, email `ahmadnaufalhakim@gmail.com`
- **Work** (when in `~/coding/work/`): name `Ahmad Naufal Hakim`, SSH URL rewriting
- Push default: `current`
- Autocrlf: `input`

### SSH
- Auto-starts `ssh-agent`, saves env to `~/.ssh/.agent.env`
- Auto-adds `~/.ssh/github_ed25519` key if not already loaded

### Task runners
- Use `make` for project scripts
- For Node.js projects, use `npm` scripts

### Project / coding directories
- Work projects: `~/coding/work/`
- Personal projects: `~/coding/` (other subdirectories)

## Workflow instructions

- When suggesting commands, prefer bash-compatible syntax
- Use `sudo apt` for package management (Ubuntu/Debian)
- When in doubt about my intent, check the dotfiles repo at `~/dotfiles/` for conventions
- When writing shell scripts, use `#!/usr/bin/env bash`
- When adding new shell functionality, create a new file in `bash/bashrc.d/` in the dotfiles repo
- When a task involves modifying dotfiles, run `install.sh` afterwards to ensure hooks are in sync
