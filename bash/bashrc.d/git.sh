#!/usr/bin/env bash

# Aliases
alias g="git"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbD="git branch -D"
alias gco="git checkout"
alias gcb="git checkout -b"
# Parse \e[38;2;R;G;Bm → #RRGGBB
_color_hex() {
    local raw="${1//\\[/}"
    raw="${raw//\\]/}"
    local re='[0-9]+;([0-9]+);([0-9]+);([0-9]+);([0-9]+)'
    if [[ $raw =~ $re ]]; then
        printf '#%02x%02x%02x' "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
    fi
}

gl() {
    local hash_c="$(_color_hex "$COLOR_ACCENT_FG")"
    local subj_c="$(_color_hex "$COLOR_USER_FG")"
    git log --graph --abbrev-commit --decorate --color=always \
        --pretty=format:"%C(bold ${hash_c})%h%C(reset) %C(auto)%d%C(reset) %C(${subj_c})%s"
}

gld() {
    local hash_c="$(_color_hex "$COLOR_ACCENT_FG")"
    local subj_c="$(_color_hex "$COLOR_USER_FG")"
    local date_c="$(_color_hex "$COLOR_DIR_FG")"
    local auth_c="$(_color_hex "$COLOR_GIT_FG")"
    git log --graph --color=always \
        --pretty=format:"%C(bold ${hash_c})%H%C(reset)%C(auto)%d%C(reset)%n    %C(${subj_c})%s%n%C(${date_c})[%ar, %ad]%n%C(bold ${auth_c})%an〈%ae〉%C(reset)%n"
}

glds() {
    local hash_c="$(_color_hex "$COLOR_ACCENT_FG")"
    local subj_c="$(_color_hex "$COLOR_USER_FG")"
    local date_c="$(_color_hex "$COLOR_DIR_FG")"
    local auth_c="$(_color_hex "$COLOR_GIT_FG")"
    git log --graph --color=always \
        --pretty=format:"%n%C(bold ${hash_c})%H%C(reset)%C(auto)%d%C(reset)%n    %C(${subj_c})%s%n%C(${date_c})[%ar, %ad]%n%C(bold ${auth_c})%an〈%ae〉%C(reset)" \
        --stat
}

glo() {
    local hash_c="$(_color_hex "$COLOR_ACCENT_FG")"
    local subj_c="$(_color_hex "$COLOR_USER_FG")"
    local date_c="$(_color_hex "$COLOR_DIR_FG")"
    local auth_c="$(_color_hex "$COLOR_GIT_FG")"
    git log --graph --color=always \
        --pretty=format:"%C(bold ${hash_c})%h%C(reset)%C(auto)%d%C(reset) — %C(${subj_c})%s%C(${date_c}) [%ar, %ad]%C(bold ${auth_c}) %an〈%ae〉%C(reset)"
}

glos() {
    local hash_c="$(_color_hex "$COLOR_ACCENT_FG")"
    local subj_c="$(_color_hex "$COLOR_USER_FG")"
    local date_c="$(_color_hex "$COLOR_DIR_FG")"
    local auth_c="$(_color_hex "$COLOR_GIT_FG")"
    git log --graph --color=always \
        --pretty=format:"%n%C(bold ${hash_c})%h%C(reset)%C(auto)%d%C(reset) — %C(${subj_c})%s%C(${date_c}) [%ar, %ad]%C(bold ${auth_c}) %an〈%ae〉%C(reset)" \
        --stat
}
alias gm="git merge"
alias gpl="git pull origin"
alias gpsh="git push origin"
alias gpush="git push -u origin"
alias grb="git rebase"
alias gst="git stash"
alias gs="git status"
alias gss="git status -s"

# Map each alias to the correct git completion function
declare -A git_aliases=(
    [g]=__git_main
    [gb]=_git_branch
    [gba]=_git_branch
    [gbd]=_git_branch
    [gbD]=_git_branch
    [gco]=_git_checkout
    [gcb]=_git_checkout
    [gl]=_git_log
    [gld]=_git_log
    [glds]=_git_log
    [glo]=_git_log
    [glos]=_git_log
    [gm]=_git_merge
    [gpl]=__git_complete_refs # TODO: figuring out which completion function is appropriate for pull
    [gpsh]=__git_complete_refs
    [gpush]=__git_complete_refs
    [grb]=_git_rebase
    [gst]=_git_stash
    [gs]=_git_status
    [gss]=_git_status
)

# load_git_completion loads git bash autocompletion script
load_git_completion() {
    type __git_complete &>/dev/null && return

    # Common Linux path
    if [[ -f /usr/share/bash-completion/completions/git ]]; then
        source /usr/share/bash-completion/completions/git
        return
    fi

    # macOS / Homebrew fallback
    local git_completion
    git_completion="$(git --exec-path 2>/dev/null)/git-completion.bash"
    [[ -f "$git_completion" ]] && source "$git_completion"
}

# Dynamically calls bash autocompletion when on-demand
for alias in "${!git_aliases[@]}"; do
    # Create wrapper functions dynamically
    eval "
    function _${alias}_lazy_load() {
        # Lazy-load git completion if needed
        load_git_completion || return

        # Wire alias to completion
        __git_complete $alias ${git_aliases[$alias]}
    }
    "

    # Register the wrapper function using `complete`
    complete -F "_${alias}_lazy_load" "$alias"
done
