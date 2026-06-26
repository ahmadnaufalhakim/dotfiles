# dotfiles

This is Ahmad Naufal Hakim's (@ahmadnaufalhakim) personal Linux dotfiles repository.

## Repo structure

```
.
├── AGENTS.md              # This file — project-level rules for this repo
├── install.sh             # Bootstrap installer (run once on a new system)
├── deps.txt               # Required packages
├── .gitignore
├── LICENSE                # MIT
├── README.md
├── bash/
│   ├── loader.sh          # Sourced by .bashrc — loads all bash/bashrc.d/*.sh
│   └── bashrc.d/
│       ├── core.sh        # cd aliases, apt aliases
│       ├── git.sh         # Git aliases (g, gb, gco, gl, gs, etc.) + lazy completion
│       ├── go.sh          # Go PATH + GOPRIVATE auto-switch
│       ├── media.sh       # compress_audio_to_ogg
│       ├── ssh.sh         # Auto-start ssh-agent, add github key
│       ├── c.sh           # init_c — scaffold minimal C project
│       └── prompt/        # Modular PS1 system
│           ├── engine.sh  # build_prompt via PROMPT_COMMAND
│           ├── color.sh   # ANSI color definitions
│           ├── timer.sh   # Command execution timer (DEBUG trap)
│           ├── error.sh   # Error sound effect on non-zero exit
│           └── segments/  # Prompt segments (status, user, dir, git, duration, date, barrier)
├── profile/
│   ├── loader.sh          # Sourced by .profile — loads all profile/profile.d/*.sh
│   └── profile.d/
│       └── xdg.sh         # XDG_*_HOME env vars
└── config/
    ├── .env               # Environment variables (not tracked)
    ├── .env.example
    ├── git/
    │   ├── main           # Personal git config (name, email, editor, push.default)
    │   └── work           # Work git config (different name, SSH URL rewriting)
    ├── neofetch/
    │   └── config.conf
    └── opencode/
        └── AGENTS.md      # Source for global opencode rules (symlinked to ~/.config/opencode/AGENTS.md)
```

## Installation

Run `install.sh` — it adds three hooks:

| Hook | File | Sources |
|------|------|---------|
| `.bashrc` | `~/.bashrc` | `bash/loader.sh` → `bash/bashrc.d/*.sh` |
| `.profile` | `~/.profile` | `profile/loader.sh` → `profile/profile.d/*.sh` |
| `.gitconfig` | `~/.gitconfig` | `[include] path = config/git/main` |
| opencode AGENTS.md | `~/.config/opencode/AGENTS.md` | Symlink → `config/opencode/AGENTS.md` |

## Key conventions when editing this repo

- **All bash modules go in `bash/bashrc.d/*.sh`** — they are sourced alphabetically by `bash/loader.sh`.
- **All profile modules go in `profile/profile.d/*.sh`** — same pattern.
- **Config files** go in `config/<name>/` and are referenced by absolute path (no symlinks, except for opencode).
- **Prompt segments** go in `bash/bashrc.d/prompt/segments/` and must be registered via `prompt_add_left` or `prompt_add_right`.
- **Keep it modular** — each `.sh` file should have a single responsibility.
- **All shell scripts use `#!/usr/bin/env bash`** shebang.
- **Use `set_goprivate`** idiom for context-aware env vars (see `go.sh`).
- **Aliases** should be simple wrappers; complex logic goes in functions.
- **Error sounds** live in `$HOME/music/effects/error/*.ogg` — controlled by `toggle_error_sound`.
