#!/usr/bin/env bash

# Aliases
alias g="git"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbD="git branch -D"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gl="git log --graph --abbrev-commit --decorate --pretty=format:'%C(bold #eb0000)%h%C(reset) %C(auto)%d%C(reset) %C(#3478f0)%s'"
alias gld="git log --graph --pretty='%C(bold #eb0000)%H%C(reset)%C(auto)%d%C(reset)%n    %C(#3478f0)%s%n%C(#f0c428)[%ar, %ad]%n%C(bold #ff5faf)%an〈%ae〉%C(reset)%n'"
alias glds="git log --graph --pretty='%n%C(bold #eb0000)%H%C(reset)%C(auto)%d%C(reset)%n    %C(#3478f0)%s%n%C(#f0c428)[%ar, %ad]%n%C(bold #ff5faf)%an〈%ae〉%C(reset)' --stat"
alias glo="git log --graph --pretty='%C(bold #eb0000)%h%C(reset)%C(auto)%d%C(reset) — %C(#3478f0)%s%C(#f0c428) [%ar, %ad]%C(bold #ff5faf) %an〈%ae〉%C(reset)'"
alias glos="git log --graph --pretty='%n%C(bold #eb0000)%h%C(reset)%C(auto)%d%C(reset) — %C(#3478f0)%s%C(#f0c428) [%ar, %ad]%C(bold #ff5faf) %an〈%ae〉%C(reset)' --stat"
alias gm="git merge"
alias gpl="git pull"
alias gpsh="git push"
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
    [gpl]=__git_complete_refs # still figuring out which completion function is appropriate for pull
    [gpsh]=__git_complete_refs
    [grb]=_git_rebase
    [gst]=_git_stash
    [gs]=_git_status
    [gss]=_git_status
)

# load_git_completion loads git bash autocompletion script
function load_git_completion() {
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
