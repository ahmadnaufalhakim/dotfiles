#!/usr/bin/env bash

__GIT_CACHE_PWD=""
__GIT_CACHE_BRANCH=""
__GIT_CACHE_ROOT=""
__GIT_CACHE_GITDIR=""
__GIT_CACHE_DIRTY=""
__GIT_CACHE_INDEX_MTIME=""
__GIT_CACHE_STAGED_COUNT=""
__GIT_CACHE_MODIFIED_COUNT=""

prompt_segment_branch() {
    local text
    SEGMENT_WIDTH=0

    local branch branch_icon=""
    branch="$(git_branch)"
    if (( ${#BRANCH_ICONS[@]} > 0 )); then
        local branch_idx=$(( RANDOM % ${#BRANCH_ICONS[@]} ))
        branch_icon=${BRANCH_ICONS[$branch_idx]}
    fi

    if [[ -n "${branch}" ]]; then
        text=" ${branch_icon} ${branch} "
        SEGMENT_TEXT="${BG_BC}${FG_NJ}${RIGHT_SEPARATOR}"
        SEGMENT_TEXT+="${BG_BC}${FG_BLACK}${text}"
        SEGMENT_TEXT+="${BG_DEFAULT}${FG_BC}${RIGHT_SEPARATOR}${RESET}"
        SEGMENT_WIDTH=$(( ${#text} + 1 ))
    else
        SEGMENT_TEXT="${BG_DEFAULT}${FG_NJ}${RIGHT_SEPARATOR}${RESET}"
    fi
}

# git_branch prints current git branch
git_branch() {
    if [[ "$PWD" != "$__GIT_CACHE_PWD" ]]; then
        __GIT_CACHE_PWD="$PWD"
        __GIT_CACHE_BRANCH=""

        # Use cached repo root if still inside the same repo
        if [[ -z "$__GIT_CACHE_ROOT" || "$PWD" != "$__GIT_CACHE_ROOT"* ]]; then
            local dir="$PWD"
            __GIT_CACHE_ROOT=""
            __GIT_CACHE_GITDIR=""

            # Walk upwards to find .git directory or worktree file
            while [[ -n "$dir" && "$dir" != "/" ]]; do
                if [[ -d "$dir/.git" ]]; then
                    __GIT_CACHE_ROOT="$dir"
                    break
                elif [[ -f "$dir/.git" ]]; then
                    # Worktree: read gitdir from file
                    local worktree_gitdir
                    read -r worktree_gitdir < "$dir/.git"
                    worktree_gitdir=${worktree_gitdir#gitdir: }
                    __GIT_CACHE_ROOT="$dir"
                    __GIT_CACHE_GITDIR="$worktree_gitdir"
                    break
                fi

                dir=${dir%/*} # walk upward
                [[ -z "$dir" ]] && dir="/"
            done
        fi

        # Determine actual git metadata directory
        local gitdir="${__GIT_CACHE_GITDIR:-$__GIT_CACHE_ROOT/.git}"

        # Exit if no repo found
        [[ -r "$gitdir/HEAD" ]] || return

        # Read HEAD and extract branch name or short commit hash
        local head
        read -r head < "$gitdir/HEAD"

        [[ "$head" == ref:\ * ]] \
            && __GIT_CACHE_BRANCH=${head#ref: refs/heads/} \
            || __GIT_CACHE_BRANCH=${head:0:7} # detached HEAD: short commit hash
    fi

    # Dirty checking
    local index="$gitdir/index"

    if [[ -f "$index" ]]; then
        local index_mtime
        index_mtime=$(stat -Lc %Y "$index" 2>/dev/null)

        if [[ "$index_mtime" != "$__GIT_CACHE_INDEX_MTIME" ]]; then
            __GIT_CACHE_INDEX_MTIME="$index_mtime"

            local staged=0 modified=0

            # Count staged files
            while read -r; do
                (( staged++ ))
            done < <(git diff --cached --name-only 2>/dev/null)

            # Count modified files
            while read -r; do
                (( modified++ ))
            done < <(git diff --name-only 2>/dev/null)

            __GIT_CACHE_STAGED_COUNT="$staged"
            __GIT_CACHE_MODIFIED_COUNT="$modified"

            if (( staged > 0 || modified > 0 )); then
                __GIT_CACHE_DIRTY="*"
            else
                __GIT_CACHE_DIRTY=""
            fi

            (( staged > 0 )) && staged=" +${__GIT_CACHE_STAGED_COUNT}" || staged=""
            (( modified > 0 )) && modified=" ~${__GIT_CACHE_MODIFIED_COUNT}" || modified=""
        fi
    fi


    # Ahead / behind
    local ahead="" behind=""

    counts=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)

    if [[ -n "$counts" ]]; then
        read -r ahead behind <<< "$counts"

        (( ahead > 0 )) && ahead=" ↑$ahead" || ahead=""
        (( behind > 0 )) && behind=" ↓$behind" || behind=""
    fi

    printf "%s%s%s%s%s%s" \
    "$__GIT_CACHE_BRANCH" \
    "$__GIT_CACHE_DIRTY" \
    "$staged" \
    "$modified" \
    "$ahead" \
    "$behind"
}
