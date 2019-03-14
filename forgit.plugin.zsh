# MIT (c) Wenxuan Zhang

forgit::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
forgit::info() { printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }
forgit::inside_work_tree() { git rev-parse --is-inside-work-tree >/dev/null; }

# https://github.com/so-fancy/diff-so-fancy
hash diff-so-fancy &>/dev/null && forgit_fancy='|diff-so-fancy'
# https://github.com/wfxr/emoji-cli
hash emojify &>/dev/null && forgit_emojify='|emojify'

# git commit viewer
forgit::log() {
    forgit::inside_work_tree || return 1
    local cmd="echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I% git show --color=always % $* $forgit_emojify $forgit_fancy"
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $* $forgit_emojify" |
        forgit::fzf +s +m --tiebreak=index \
            --bind="enter:execute($cmd |LESS='-R' less)" \
            --bind="ctrl-y:execute-silent(echo {} |grep -o '[a-f0-9]\{7\}' |${FORGIT_COPY_CMD:-pbcopy})" \
            --preview="$cmd"
}

# git diff viewer
forgit::diff() {
    forgit::inside_work_tree || return 1
    local cmd files
    cmd="git diff --color=always -- {} $forgit_emojify $forgit_fancy"
    files="$*"
    [[ $# -eq 0 ]] && files=$(git rev-parse --show-toplevel)
    git ls-files --modified "$files"|
        forgit::fzf +m -0 \
            --bind="enter:execute($cmd |LESS='-R' less)" \
            --preview="$cmd"
}

# git add selector
forgit::add() {
    forgit::inside_work_tree || return 1
    local changed unmerged untracked files
    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)
    files=$(git -c color.status=always status --short |
        grep -F -e "$changed" -e "$unmerged" -e "$untracked"|
        awk '{printf "[%10s]  ", $1; $1=""; print $0}' |
        forgit::fzf -0 -m --nth 2..,.. \
            --preview="git diff --color=always -- {-1} $forgit_emojify $forgit_fancy" |
        cut -d] -f2 |
        sed 's/.* -> //') # for rename case
    [[ -n "$files" ]] && echo "$files" |xargs -I{} git add {} && git status --short && return
    echo 'Nothing to add.'
}

# git checkout-restore selector
forgit::restore() {
    forgit::inside_work_tree || return 1
    local cmd files
    cmd="git diff --color=always -- {} $forgit_emojify $forgit_fancy"
    files="$(git ls-files --modified "$(git rev-parse --show-toplevel)"|
        forgit::fzf -m -0 --preview="$cmd")"
    [[ -n "$files" ]] && echo "$files" |xargs -I{} git checkout {} && git status --short && return
    echo 'Nothing to restore.'
}

# git stash viewer
forgit::stash::show() {
    forgit::inside_work_tree || return 1
    local cmd="git stash show \$(echo {}| cut -d: -f1) --color=always --ext-diff $forgit_fancy"
    git stash list |
        forgit::fzf +s +m -0 --tiebreak=index \
        --bind="enter:execute($cmd |LESS='-R' less)" \
        --preview="$cmd"
}

# git clean selector
forgit::clean() {
    forgit::inside_work_tree || return 1
    local files
    # Note: Postfix '/' in directory path should be removed. Otherwise the directory itself will not be removed.
    files=$(git clean -xdfn "$@"| awk '{print $3}'| forgit::fzf -m -0 |sed 's#/$##')
    [[ -n "$files" ]] && echo "$files" |xargs -I{} git clean -xdf {}
    echo 'Nothing to clean.'
}

# git ignore generator
export FORGIT_GI_REPO_REMOTE=${FORGIT_GI_REPO_REMOTE:-https://github.com/dvcs/gitignore}
export FORGIT_GI_REPO_LOCAL=${FORGIT_GI_REPO_LOCAL:-~/.forgit/gi/repos/dvcs/gitignore}
export FORGIT_GI_TEMPLATES=${FORGIT_GI_TEMPLATES:-$FORGIT_GI_REPO_LOCAL/templates}

forgit::ignore() {
    [ -d "$FORGIT_GI_REPO_LOCAL" ] || forgit::ignore::update
    local IFS cmd args cat
    # https://github.com/sharkdp/bat.git
    hash bat &>/dev/null && cat='bat -l gitignore --color=always' || cat="cat"
    cmd="$cat $FORGIT_GI_TEMPLATES/{2}{,.gitignore} 2>/dev/null"
    # shellcheck disable=SC2206,2207
    IFS=$'\n' args=($@) && [[ $# -eq 0 ]] && args=($(forgit::ignore::list | nl -nrn -w4 -s'  ' |
        forgit::fzf -m --preview="$cmd" --preview-window="right:70%" | awk '{print $2}'))
    [ ${#args[@]} -eq 0 ] && return 1
    # shellcheck disable=SC2068
    if hash bat &>/dev/null; then
        forgit::ignore::get ${args[@]} | bat -l gitignore
    else
        forgit::ignore::get ${args[@]}
    fi
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

forgit::fzf() {
    FZF_DEFAULT_OPTS="
        $FZF_DEFAULT_OPTS
        --ansi
        --height '80%'
        --bind='alt-k:preview-up,alt-p:preview-up'
        --bind='alt-j:preview-down,alt-n:preview-down'
        --bind='ctrl-r:toggle-all'
        --bind='ctrl-s:toggle-sort'
        --bind='?:toggle-preview'
        --preview-window='right:60%'
        --bind='alt-w:toggle-preview-wrap'
        $FORGIT_FZF_DEFAULT_OPTS
    " fzf "$@"
}

# register aliases
# shellcheck disable=SC2139
if [[ -z "$FORGIT_NO_ALIASES" ]]; then
    alias "${forgit_add:-ga}"='forgit::add'
    alias "${forgit_log:-glo}"='forgit::log'
    alias "${forgit_diff:-gd}"='forgit::diff'
    alias "${forgit_ignore:-gi}"='forgit::ignore'
    alias "${forgit_restore:-gcf}"='forgit::restore'
    alias "${forgit_clean:-gclean}"='forgit::clean'
    alias "${forgit_stash_show:-gss}"='forgit::stash::show'
fi
