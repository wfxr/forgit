#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang
forgit::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
forgit::info() { printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }
forgit::inside_work_tree() { git rev-parse --is-inside-work-tree >/dev/null; }
# tac is not available on OSX, tail -r is not available on Linux, so we use either of them
forgit::reverse_lines() { tac 2> /dev/null || tail -r; }

forgit::previous_commit() {
    # "SHA~" is invalid when the commit is the first commit, but we can use "--root" instead
    if [[ "$(git rev-parse "$1")" == "$(git rev-list --max-parents=0 HEAD)" ]]; then
        echo "--root"
    else
        echo "$1~"
    fi
}

# optional render emoji characters (https://github.com/wfxr/emoji-cli)
hash emojify &>/dev/null && forgit_emojify='|emojify'

# extract the first git sha occurring in the input and strip trailing newline
forgit_extract_sha="grep -Eo '[a-f0-9]+' | head -1 | tr -d '[:space:]'"

forgit_pager=${FORGIT_PAGER:-$(git config core.pager || echo 'cat')}
forgit_show_pager=${FORGIT_SHOW_PAGER:-$(git config pager.show || echo "$forgit_pager")}
forgit_diff_pager=${FORGIT_DIFF_PAGER:-$(git config pager.diff || echo "$forgit_pager")}
forgit_ignore_pager=${FORGIT_IGNORE_PAGER:-$(hash bat &>/dev/null && echo 'bat -l gitignore --color=always' || echo 'cat')}
forgit_blame_pager=${FORGIT_BLAME_PAGER:-$(git config pager.blame || echo "$forgit_pager")}
forgit_enter_pager=${FORGIT_ENTER_PAGER:-"LESS='-r' less"}

forgit_log_format=${FORGIT_LOG_FORMAT:-%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset}
forgit_log_preview_options="--graph --pretty=format:'$forgit_log_format' --color=always --abbrev-commit --date=relative"
forgit_fullscreen_context=${FORGIT_FULLSCREEN_CONTEXT:-10}
forgit_preview_context=${FORGIT_PREVIEW_CONTEXT:-3}

# git commit viewer
forgit::log() {
    forgit::inside_work_tree || return 1
    local opts graph files log_format preview_cmd enter_cmd
    files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
    preview_cmd="echo {} | $forgit_extract_sha | xargs -I% git show --color=always -U$forgit_preview_context % -- $files | $forgit_show_pager"
    enter_cmd="echo {} | $forgit_extract_sha | xargs -I% git show --color=always -U$forgit_fullscreen_context % -- $files | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --bind=\"enter:execute($enter_cmd | $forgit_enter_pager)\"
        --bind=\"ctrl-y:execute-silent(echo {} | $forgit_extract_sha | ${FORGIT_COPY_CMD:-pbcopy})\"
        --preview=\"$preview_cmd\"
        $FORGIT_LOG_FZF_OPTS
    "
    graph=--graph
    [[ $FORGIT_LOG_GRAPH_ENABLE == false ]] && graph=
    log_format=${FORGIT_GLO_FORMAT:-$forgit_log_format}
    eval "git log $graph --color=always --format='$log_format' $* $forgit_emojify" |
        FZF_DEFAULT_OPTS="$opts" fzf
}

# git diff viewer
forgit::diff() {
    forgit::inside_work_tree || return 1
    local files opts commits repo get_files preview_cmd enter_cmd
    [[ $# -ne 0 ]] && {
        if git rev-parse "$1" -- &>/dev/null ; then
            if [[ $# -gt 1 ]] && git rev-parse "$2" -- &>/dev/null; then
                commits="$1 $2" && files=("${@:3}")
            else
                commits="$1" && files=("${@:2}")
            fi
        else
            files=("$@")
        fi
    }
    repo="$(git rev-parse --show-toplevel)"
    get_files="cd '$repo' && echo {} | sed 's/.*] *//' | sed 's/  ->  / /'"
    # Git stashes are named "stash@{x}", which contains the fzf placeholder "{x}".
    # In order to support passing stashes as arguments to forgit::diff, we have to
    # prevent fzf from interpreting this substring by escaping the opening bracket.
    # The string is evaluated a few subsequent times, so we need multiple escapes.
    escaped_commits=${commits//\{/\\\\\{}
    preview_cmd="$get_files | xargs -I% git diff --color=always -U$forgit_preview_context $escaped_commits -- % | $forgit_diff_pager"
    enter_cmd="$get_files | xargs -I% git diff --color=always -U$forgit_fullscreen_context $escaped_commits -- % | $forgit_diff_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +m -0 --bind=\"enter:execute($enter_cmd | $forgit_enter_pager)\"
        --preview=\"$preview_cmd\"
        $FORGIT_DIFF_FZF_OPTS
        --prompt=\"$commits > \"
    "
    eval "git diff --name-status $commits -- ${files[*]} | sed -E 's/^([[:alnum:]]+)[[:space:]]+(.*)$/[\1]\t\2/'" |
        sed 's/\t/  ->  /2' | expand -t 8 |
        FZF_DEFAULT_OPTS="$opts" fzf
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
        --preview=\"$preview\"
        $FORGIT_ADD_FZF_OPTS
    "
    files=$(git -c color.status=always -c status.relativePaths=true status -su |
        grep -F -e "$changed" -e "$unmerged" -e "$untracked" |
        sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)$/[\1]  \2/' |
        FZF_DEFAULT_OPTS="$opts" fzf |
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
        --preview=\"$cmd\"
        $FORGIT_RESET_HEAD_FZF_OPTS
    "
    files="$(git diff --cached --name-only --relative | FZF_DEFAULT_OPTS="$opts" fzf)"
    [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git reset -q HEAD % && git status --short && return
    echo 'Nothing to unstage.'
}

# git stash viewer
forgit::stash::show() {
    forgit::inside_work_tree || return 1
    local cmd opts
    cmd="echo {} |cut -d: -f1 |xargs -I% git stash show --color=always --ext-diff % |$forgit_diff_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m -0 --tiebreak=index --bind=\"enter:execute($cmd | $forgit_enter_pager)\"
        --preview=\"$cmd\"
        $FORGIT_STASH_FZF_OPTS
    "
    git stash list | FZF_DEFAULT_OPTS="$opts" fzf
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
    local base target preview opts fzf_selection fzf_exitval
    base=$(git branch --show-current)
    [[ -z $1 ]] && echo "Please specify target branch" && return 1
    target="$1"
    preview="echo {} | $forgit_extract_sha | xargs -I% git show --color=always % | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        --preview=\"$preview\"
        -m -0 --tiebreak=index
        $FORGIT_CHERRY_PICK_FZF_OPTS
    "
    fzf_selection=$(git cherry "$base" "$target" --abbrev -v | forgit::reverse_lines |
        FZF_DEFAULT_OPTS="$opts" fzf)
    fzf_exitval=$?
    [[ $fzf_exitval != 0 ]] && return $fzf_exitval

    commits=()
    while IFS="" read -r line
    do
        commits+=("$line")
    done < <(echo "$fzf_selection" | forgit::reverse_lines | cut -d' ' -f2)

    git cherry-pick "${commits[@]}"
}

forgit::cherry::pick::from::branch() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && { git checkout -b "$@"; return $?; }
    local cmd preview opts branch exitval
    cmd="git branch --color=always --all | LC_ALL=C sort -k1.1,1.1 -rs"
    preview="git log {1} $forgit_log_preview_options"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index --header-lines=1
        --preview=\"$preview\"
        $FORGIT_CHERRY_PICK_FROM_BRANCH_FZF_OPTS
        "
    # loop until either the branch selector is closed or a commit to be cherry
    # picked has been selected from within a branch
    while true
    do
        branch="$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf | awk '{print $1}')"
        [[ -z "$branch" ]] && return 1

        forgit::cherry::pick "$branch"

        exitval=$?
        [[ $exitval != 130 ]] && return $exitval
    done
}

forgit::rebase() {
    forgit::inside_work_tree || return 1
    local cmd preview opts graph files target_commit prev_commit
    graph=--graph
    [[ $FORGIT_LOG_GRAPH_ENABLE == false ]] && graph=
    cmd="git log $graph --color=always --format='$forgit_log_format' $* $forgit_emojify"
    files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
    preview="echo {} | $forgit_extract_sha | xargs -I% git show --color=always % -- $files | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --bind=\"ctrl-y:execute-silent(echo {} | $forgit_extract_sha | ${FORGIT_COPY_CMD:-pbcopy})\"
        --preview=\"$preview\"
        $FORGIT_REBASE_FZF_OPTS
    "
    target_commit=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf | eval "$forgit_extract_sha")
    if [[ -n "$target_commit" ]]; then
        prev_commit=$(forgit::previous_commit "$target_commit")

        git rebase -i "$prev_commit"
    fi
}

forgit::fixup() {
    forgit::inside_work_tree || return 1
    git diff --cached --quiet && echo 'Nothing to fixup: there are no staged changes.' && return 1
    local cmd preview opts graph files target_commit prev_commit
    graph=--graph
    [[ $FORGIT_LOG_GRAPH_ENABLE == false ]] && graph=
    cmd="git log $graph --color=always --format='$forgit_log_format' $* $forgit_emojify"
    files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*")
    preview="echo {} | $forgit_extract_sha | xargs -I% git show --color=always % -- $files | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --bind=\"ctrl-y:execute-silent(echo {} | $forgit_extract_sha | ${FORGIT_COPY_CMD:-pbcopy})\"
        --preview=\"$preview\"
        $FORGIT_FIXUP_FZF_OPTS
    "
    target_commit=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf | eval "$forgit_extract_sha")
    if [[ -n "$target_commit" ]] && git commit --fixup "$target_commit"; then
        prev_commit=$(forgit::previous_commit "$target_commit")
        # rebase will fail if there are unstaged changes so --autostash is needed to temporarily stash them
        # GIT_SEQUENCE_EDITOR=: is needed to skip the editor
        GIT_SEQUENCE_EDITOR=: git rebase --autostash -i --autosquash "$prev_commit"
    fi

}

# git checkout-file selector
forgit::checkout::file() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && { git checkout -- "$@"; return $?; }
    local cmd files opts
    cmd="git diff --color=always -- {} | $forgit_diff_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
        --preview=\"$cmd\"
        $FORGIT_CHECKOUT_FILE_FZF_OPTS
    "
    files="$(git ls-files --modified "$(git rev-parse --show-toplevel)"| FZF_DEFAULT_OPTS="$opts" fzf)"
    [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git checkout %
}

# git checkout-branch selector
forgit::checkout::branch() {
    forgit::inside_work_tree || return 1
    # if called with arguments, check if branch exists, else create a new one
    if [[ $# -ne 0 ]]; then
        if git show-branch "$@" &>/dev/null; then
            git switch "$@"
        else
            git switch -c "$@"
        fi
        checkout_status=$?
        git status --short
        return $checkout_status
    fi

    local cmd preview opts branch
    cmd="git branch --color=always --all | LC_ALL=C sort -k1.1,1.1 -rs"
    preview="git log {1} $forgit_log_preview_options"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index --header-lines=1
        --preview=\"$preview\"
        $FORGIT_CHECKOUT_BRANCH_FZF_OPTS
        "
    branch="$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf | awk '{print $1}')"
    [[ -z "$branch" ]] && return 1

    # track the remote branch if possible
    if [[ "$branch" == "remotes/origin/"* ]]; then
        if git branch | grep -qw "${branch#remotes/origin/}"; then
            # hack to force creating a new branch which tracks the remote if a local branch already exists
            git checkout -b "track/${branch#remotes/origin/}" --track "$branch"
        elif ! git checkout --track "$branch" 2>/dev/null; then
            git checkout "$branch"
        fi
    else
        git checkout "$branch"
    fi
}

# git checkout-tag selector
forgit::checkout::tag() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && { git checkout "$@"; return $?; }
    local cmd opts preview
    cmd="git tag -l --sort=-v:refname"
    preview="git log {1} $forgit_log_preview_options"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --preview=\"$preview\"
        $FORGIT_CHECKOUT_TAG_FZF_OPTS
    "
    tag="$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf)"
    [[ -z "$tag" ]] && return 1
    git checkout "$tag"
}

# git checkout-commit selector
forgit::checkout::commit() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && { git checkout "$@"; return $?; }
    local cmd opts graph
    cmd="echo {} | $forgit_extract_sha |xargs -I% git show --color=always % | $forgit_show_pager"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index
        --bind=\"ctrl-y:execute-silent(echo {} | $forgit_extract_sha | ${FORGIT_COPY_CMD:-pbcopy})\"
        --preview=\"$cmd\"
        $FORGIT_COMMIT_FZF_OPTS
    "
    graph=--graph
    [[ $FORGIT_LOG_GRAPH_ENABLE == false ]] && graph=
    eval "git log $graph --color=always --format='$forgit_log_format' $forgit_emojify" |
        FZF_DEFAULT_OPTS="$opts" fzf | eval "$forgit_extract_sha" | xargs -I% git checkout % --
}

forgit::branch::delete() {
    forgit::inside_work_tree || return 1
    local preview opts cmd branches
    preview="git log {1} $forgit_log_preview_options"

    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s --multi --tiebreak=index --header-lines=1
        --preview=\"$preview\"
        $FORGIT_BRANCH_DELETE_FZF_OPTS
    "

    cmd="git branch --color=always | LC_ALL=C sort -k1.1,1.1 -rs"
    branches=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" fzf | awk '{print $1}')
    echo -n "$branches" | tr '\n' '\0' | xargs -I{} -0 git branch -D {}
}

# git revert-commit selector
forgit::revert::commit() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && { git revert "$@"; return $?; }
    local cmd opts files preview commits IFS
    cmd="git log --graph --color=always --format='$forgit_log_format' $* $forgit_emojify"
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        +s --tiebreak=index
        $FORGIT_REVERT_COMMIT_OPTS
    "
    files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
    preview="echo {} | $forgit_extract_sha | xargs -I% git show --color=always % -- $files | $forgit_show_pager"
    # shellcheck disable=2207
    IFS=$'\n' commits=($(eval "$cmd" |
        FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" -m |
        sed 's/^[^a-f^0-9]*\([a-f0-9]*\).*/\1/'))
    [ ${#commits[@]} -eq 0 ] && return 1
    for commit in "${commits[@]}"; do
        git revert "$commit"
    done
}

# git blame viewer
forgit::blame() {
    forgit::inside_work_tree || return 1
    [[ $# -ne 0 ]] && git blame "$@" && return 0
    local opts flags preview file
    opts="
        $FORGIT_FZF_DEFAULT_OPTS
        $FORGIT_BLAME_FZF_OPTS
    "
    flags=$(git rev-parse --flags "$@")
    preview="
        if (git ls-files {} --error-unmatch) &>/dev/null; then
            git blame {} --date=short $flags | $forgit_blame_pager
        else
            echo File not tracked
        fi
    "
    file=$(FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview")
    [[ -z "$file" ]] && return 1
    eval git blame "$file" "$flags"
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
        --preview=\"eval $cmd\"
        $FORGIT_IGNORE_FZF_OPTS
    "
    # shellcheck disable=SC2206,2207
    IFS=$'\n' args=($@) && [[ $# -eq 0 ]] && args=($(forgit::ignore::list | nl -nrn -w4 -s'  ' |
        FZF_DEFAULT_OPTS="$opts" fzf | awk '{print $2}'))
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
    alias "${forgit_checkout_commit:-gco}"='forgit::checkout::commit'
    alias "${forgit_branch_delete:-gbd}"='forgit::branch::delete'
    alias "${forgit_revert_commit:-grc}"='forgit::revert::commit'
    alias "${forgit_checkout_tag:-gct}"='forgit::checkout::tag'
    alias "${forgit_clean:-gclean}"='forgit::clean'
    alias "${forgit_stash_show:-gss}"='forgit::stash::show'
    alias "${forgit_cherry_pick:-gcp}"='forgit::cherry::pick::from::branch'
    alias "${forgit_rebase:-grb}"='forgit::rebase'
    alias "${forgit_fixup:-gfu}"='forgit::fixup'
    alias "${forgit_blame:-gbl}"='forgit::blame'
fi

# set installation path (for use by `bin/git-forgit`)
if [[ -n "$ZSH_VERSION" ]]; then
    FORGIT_INSTALL_DIR="$( dirname -- "$0")"
elif [[ -n "$BASH_VERSION" ]]; then
    FORGIT_INSTALL_DIR="$(dirname -- "${BASH_SOURCE[0]}")"
else
    forgit::warn "Only zsh and bash are fully supported"
fi
if [[ -n "$FORGIT_INSTALL_DIR" ]]; then
    export FORGIT_INSTALL_DIR
fi
