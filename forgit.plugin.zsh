#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang
forgit::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
forgit::info() { printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }
forgit::inside_work_tree() { git rev-parse --is-inside-work-tree >/dev/null; }

# https://github.com/wfxr/emoji-cli
hash emojify &>/dev/null && forgit_emojify='|emojify'

forgit_pager=${FORGIT_PAGER:-$(git config core.pager || echo 'cat')}
forgit_show_pager=${FORGIT_SHOW_PAGER:-$(git config pager.show || echo "$forgit_pager")}
forgit_diff_pager=${FORGIT_DIFF_PAGER:-$(git config pager.diff || echo "$forgit_pager")}
forgit_ignore_pager=${FORGIT_IGNORE_PAGER:-$(hash bat &>/dev/null && echo 'bat -l gitignore --color=always' || echo 'cat')}

# git commit viewer
forgit::log() {
    forgit::inside_work_tree || return 1
    local cmd opts graph files
    files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
    cmd="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % -- $files | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --bind=\"enter:execute($cmd | LESS='-r' less)\"
        --bind=\"ctrl-y:execute-silent(echo {} |grep -Eo '[a-f0-9]+' | head -1 | tr -d '[:space:]' |${FORGIT_COPY_CMD:-pbcopy})\"
        $FORGIT_LOG_FZF_OPTS
    "
    graph=--graph
    [[ $FORGIT_LOG_GRAPH_ENABLE == false ]] && graph=
    eval "git log $graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset' $* $forgit_emojify" |
        FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd"
}

# git diff viewer
forgit::diff() {
    forgit::inside_work_tree || return 1
    local cmd files opts commit repo
    [[ $# -ne 0 ]] && {
        if git rev-parse "$1" -- &>/dev/null ; then
            commit="$1" && files=("${@:2}")
        else
            files=("$@")
        fi
    }
    repo="$(git rev-parse --show-toplevel)"
    cmd="echo {} |sed 's/.*]  //' |xargs -I% git diff --color=always $commit -- '$repo/%' | $forgit_diff_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +m -0 --bind=\"enter:execute($cmd |LESS='-r' less)\"
        $FORGIT_DIFF_FZF_OPTS
    "
    eval "git diff --name-status $commit -- ${files[*]} | sed -E 's/^(.)[[:space:]]+(.*)$/[\1]  \2/'" |
        FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd"
}

# git add selector
forgit::add() {
    forgit::inside_work_tree || return 1
    # Add files if passed as arguments
    [[ $# -ne 0 ]] && git add "$@" && git status -su && return

    local changed unmerged untracked files opts preview extract
    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)
    # NOTE: paths listed by 'git status -su' mixed with quoted and unquoted style
    # remove indicators | remove original path for rename case | remove surrounding quotes
    extract="
        sed 's/^.*]  //' |
        sed 's/.* -> //' |
        sed -e 's/^\\\"//' -e 's/\\\"\$//'"
    preview="
        file=\$(echo {} | $extract)
        if (git status -s -- \$file | grep '^??') &>/dev/null; then  # diff with /dev/null for untracked files
            git diff --color=always --no-index -- /dev/null \$file | $forgit_diff_pager | sed '2 s/added:/untracked:/'
        else
            git diff --color=always -- \$file | $forgit_diff_pager
        fi"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -0 -m --nth 2..,..
        $FORGIT_ADD_FZF_OPTS
    "
    files=$(git -c color.status=always -c status.relativePaths=true status -su |
        grep -F -e "$changed" -e "$unmerged" -e "$untracked" |
        sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)$/[\1]  \2/' |
        FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" |
        sh -c "$extract")
    [[ -n "$files" ]] && echo "$files"| tr '\n' '\0' |xargs -0 -I% git add % && git status -su && return
    echo 'Nothing to add.'
}

# git reset HEAD (unstage) selector
forgit::reset::head() {
    forgit::inside_work_tree || return 1
    local cmd files opts
    cmd="git diff --cached --color=always -- {} | $forgit_diff_pager "
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
        $FORGIT_RESET_HEAD_FZF_OPTS
    "
    files="$(git diff --cached --name-only --relative | FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd")"
    [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git reset -q HEAD % && git status --short && return
    echo 'Nothing to unstage.'
}

# git checkout-restore selector
forgit::checkout::file() {
    forgit::inside_work_tree || return 1
    local cmd files opts
    cmd="git diff --color=always -- {} | $forgit_diff_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
        $FORGIT_CHECKOUT_FILE_FZF_OPTS
    "
    files="$(git ls-files --modified "$(git rev-parse --show-toplevel)"| FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd")"
    [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git checkout % && git status --short && return
    echo 'Nothing to restore.'
}

# git stash viewer
forgit::stash::show() {
    forgit::inside_work_tree || return 1
    local cmd opts
    cmd="echo {} |cut -d: -f1 |xargs -I% git stash show --color=always --ext-diff % |$forgit_diff_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m -0 --tiebreak=index --bind=\"enter:execute($cmd | LESS='-r' less)\"
        $FORGIT_STASH_FZF_OPTS
    "
    git stash list | FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd"
}

# git clean selector
forgit::clean() {
    forgit::inside_work_tree || return 1
    local files opts
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
        $FORGIT_CLEAN_FZF_OPTS
    "
    # Note: Postfix '/' in directory path should be removed. Otherwise the directory itself will not be removed.
    files=$(git clean -xdffn "$@"| sed 's/^Would remove //' | FZF_DEFAULT_OPTS="$opts" fzf |sed 's#/$##')
    [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git clean -xdff '%' && git status --short && return
    echo 'Nothing to clean.'
}

forgit::cherry::pick() {
    local base target preview opts
    base=$(git branch --show-current)
    [[ -z $1 ]] && echo "Please specify target branch" && return 1
    target="$1"
    preview="echo {1} | xargs -I% git show --color=always % | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
    "
    git cherry "$base" "$target" --abbrev -v | cut -d ' ' -f2- |
        FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" | cut -d' ' -f1 |
        xargs -I% git cherry-pick %
}

forgit::rebase() {
    forgit::inside_work_tree || return 1
    local cmd preview opts graph files commit
    graph=--graph
    [[ $FORGIT_LOG_GRAPH_ENABLE == false ]] && graph=
    cmd="git log $graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset' $* $forgit_emojify"
    files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
    preview="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % -- $files | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --bind=\"ctrl-y:execute-silent(echo {} |grep -Eo '[a-f0-9]+' | head -1 | tr -d '[:space:]' |${FORGIT_COPY_CMD:-pbcopy})\"
        $FORGIT_REBASE_FZF_OPTS
    "
    commit=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" |
        grep -Eo '[a-f0-9]+' | head -1)
    [[ -n "$commit" ]] && git rebase -i "$commit"
}

forgit::checkout::branch() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && { git checkout -b "$*"; return $?; }
    local cmd preview opts
    cmd="git branch --color=always --verbose --all --format=\"%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%(refname:short)%(end)\" $forgit_emojify | sed '/^$/d'"
    preview="git log {} --graph --pretty=format:'%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset' --color=always --abbrev-commit --date=relative"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index --ansi
        $FORGIT_CHECKOUT_BRANCH_FZF_OPTS
        "
    eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" | xargs -I% git checkout %
}

# git ignore generator
export FORGIT_GI_REPO_REMOTE=${FORGIT_GI_REPO_REMOTE:-https://github.com/dvcs/gitignore}
export FORGIT_GI_REPO_LOCAL="${FORGIT_GI_REPO_LOCAL:-${XDG_CACHE_HOME:-$HOME/.cache}/forgit/gi/repos/dvcs/gitignore}"
export FORGIT_GI_TEMPLATES=${FORGIT_GI_TEMPLATES:-$FORGIT_GI_REPO_LOCAL/templates}

forgit::ignore() {
    [ -d "$FORGIT_GI_REPO_LOCAL" ] || forgit::ignore::update
    local IFS cmd args opts
    cmd="$forgit_ignore_pager $FORGIT_GI_TEMPLATES/{2}{,.gitignore} 2>/dev/null"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -m --preview-window='right:70%'
        $FORGIT_IGNORE_FZF_OPTS
    "
    # shellcheck disable=SC2206,2207
    IFS=$'\n' args=($@) && [[ $# -eq 0 ]] && args=($(forgit::ignore::list | nl -nrn -w4 -s'  ' |
        FZF_DEFAULT_OPTS="$opts" fzf --preview="eval $cmd" | awk '{print $2}'))
    [ ${#args[@]} -eq 0 ] && return 1
    # shellcheck disable=SC2068
    forgit::ignore::get ${args[@]}
}
forgit::ignore::update() {
    if [[ -d "$FORGIT_GI_REPO_LOCAL" ]]; then
        forgit::info 'Updating gitignore repo...'
        (cd "$FORGIT_GI_REPO_LOCAL" && git pull --no-rebase --ff) || return 1
    else
        forgit::info 'Initializing gitignore repo...'
        git clone --depth=1 "$FORGIT_GI_REPO_REMOTE" "$FORGIT_GI_REPO_LOCAL"
    fi
}
forgit::ignore::get() {
    local item filename header
    for item in "$@"; do
        if filename=$(find -L "$FORGIT_GI_TEMPLATES" -type f \( -iname "${item}.gitignore" -o -iname "${item}" \) -print -quit); then
            [[ -z "$filename" ]] && forgit::warn "No gitignore template found for '$item'." && continue
            header="${filename##*/}" && header="${header%.gitignore}"
            echo "### $header" && cat "$filename" && echo
        fi
    done
}
forgit::ignore::list() {
    find "$FORGIT_GI_TEMPLATES" -print |sed -e 's#.gitignore$##' -e 's#.*/##' | sort -fu
}
forgit::ignore::clean() {
    setopt localoptions rmstarsilent
    [[ -d "$FORGIT_GI_REPO_LOCAL" ]] && rm -rf "$FORGIT_GI_REPO_LOCAL"
}

FORGIT_FZF_DEFAULT_OPTS="
$FZF_DEFAULT_OPTS
--ansi
--height='80%'
--bind='alt-k:preview-up,alt-p:preview-up'
--bind='alt-j:preview-down,alt-n:preview-down'
--bind='ctrl-r:toggle-all'
--bind='ctrl-s:toggle-sort'
--bind='?:toggle-preview'
--bind='alt-w:toggle-preview-wrap'
--preview-window='right:60%'
+1
$FORGIT_FZF_DEFAULT_OPTS
"

# register aliases
# shellcheck disable=SC2139
if [[ -z "$FORGIT_NO_ALIASES" ]]; then
    alias "${forgit_add:-ga}"='forgit::add'
    alias "${forgit_reset_head:-grh}"='forgit::reset::head'
    alias "${forgit_log:-glo}"='forgit::log'
    alias "${forgit_diff:-gd}"='forgit::diff'
    alias "${forgit_ignore:-gi}"='forgit::ignore'
    alias "${forgit_checkout_file:-gcf}"='forgit::checkout::file'
    alias "${forgit_checkout_branch:-gcb}"='forgit::checkout::branch'
    alias "${forgit_clean:-gclean}"='forgit::clean'
    alias "${forgit_stash_show:-gss}"='forgit::stash::show'
    alias "${forgit_cherry_pick:-gcp}"='forgit::cherry::pick'
    alias "${forgit_rebase:-grb}"='forgit::rebase'
fi
