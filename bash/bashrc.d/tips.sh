#!/usr/bin/env bash

# Each tip: category|one-liner
_DOTFILES_TIPS=(
    "git|Theme-colored git log — try \`prompt_theme sakura\` then \`gl\`"
    "git|See full commit details with \`gld\` or oneline with author via \`glo\`"
    "git|Quick status with \`gs\` (verbose) or \`gss\` (compact)"
    "git|Checkout branches with \`gco <branch>\` or create new with \`gcb <name>\`"
    "git|List branches with \`gb\`, all branches with \`gba\`"
    "git|Pull with \`gpl <remote>\`, push with \`gpsh <remote>\` or \`gpush\` with -u"
    "git|Merge with \`gm\`, rebase with \`grb\`"
    "prompt|Switch themes with \`prompt_theme <name>\` — 16 themes available"
    "prompt|List all themes with color swatches: \`prompt_theme\` (no args)"
    "prompt|Toggle error beep with \`toggle_error_sound\`"
    "prompt|Command execution timer shows duration in your prompt"
    "scaffold|Scaffold a C project: \`init_c myproject\`"
    "scaffold|Scaffold a Go CLI: \`init_go myapp\` — choose plain or Cobra"
    "scaffold|Scaffold a Go Web API: \`init_go myapp\` — choose Chi, Gin, or Echo"
    "audio|Batch convert audio to OGG: \`compress_audio_to_ogg *.mp3\`"
    "migrate|Create a DB migration: \`migrate-new add_users_table\`"
    "migrate|Run migrations: \`migrate-up\`, rollback: \`migrate-down\`"
    "ssh|SSH agent auto-starts and loads your GitHub key on every shell"
    "go|GOPRIVATE auto-sets when you work in ~/coding/work/"
    "opencode|Ask questions about your codebase with the \`ask\` agent"
    "opencode|Brainstorm ideas with the \`brainstorm\` agent"
    "opencode|Request code review with \`@review\` in your prompts"
)

dotfiles-tips() {
    if [[ "${1:-}" == "--motd" ]]; then
        _dotfiles_tip_random
    else
        _dotfiles_print_all
    fi
}

_dotfiles_tip_random() {
    local idx=$(( RANDOM % ${#_DOTFILES_TIPS[@]} ))
    local tip="${_DOTFILES_TIPS[$idx]}"
    local desc="${tip#*|}"
    echo ""
    echo "${desc}"
}

_dotfiles_print_all() {
    local cats=(
        "git:git"
        "prompt:prompt"
        "scaffold:scaffolding"
        "audio:audio"
        "migrate:migrations"
        "ssh:ssh"
        "go:go"
        "opencode:opencode"
    )

    echo ""
    for entry in "${cats[@]}"; do
        local key="${entry%%:*}"
        local label="${entry#*:}"
        printf "  \033[1m%s\033[0m\n" "$label"
        for tip in "${_DOTFILES_TIPS[@]}"; do
            if [[ "${tip%%|*}" == "$key" ]]; then
                local desc="${tip#*|}"
                printf "    %s\n" "$desc"
            fi
        done
        echo ""
    done
}
