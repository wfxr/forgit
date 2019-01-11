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

forgit::color_to_grep_code() {
    case "$1" in
        black)
            echo -E '\[30m'
            ;;
        red)
            echo -E '\[31m'
            ;;
        green)
            echo -E '\[32m'
            ;;
        yellow)
            echo -E '\[33m'
            ;;
        blue)
            echo -E '\[34m'
            ;;
        magenta)
            echo -E '\[35m'
            ;;
        cyan)
            echo -E '\[36m'
            ;;
        white)
            echo -E '\[97m'
            ;;
    esac
}


# diff is fancy with diff-so-fancy!
(( $+commands[diff-so-fancy] )) && forgit_fancy='|diff-so-fancy'
(( $+commands[emojify]       )) && forgit_emojify='|emojify'

forgit::inside_work_tree() {
    git rev-parse --is-inside-work-tree >/dev/null
}

# git commit viewer
forgit::log() {
    forgit::inside_work_tree || return 1
    local cmd="echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I% git show --color=always % $@ $forgit_emojify $forgit_fancy"
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $@ $forgit_emojify" |
        forgit::fzf +s +m --tiebreak=index \
            --bind="enter:execute($cmd |LESS='-R' less)" \
            --bind="ctrl-y:execute-silent(echo {} |grep -o '[a-f0-9]\{7\}' |${FORGIT_COPY_CMD:-pbcopy})" \
            --preview="$cmd"
}

# git diff viewer
forgit::diff() {
    forgit::inside_work_tree || return 1
    local cmd="git diff --color=always -- {} $forgit_emojify $forgit_fancy"
    [[ $# -eq 0 ]] && local files=$(git rev-parse --show-toplevel) || local files="$@"
    git ls-files --modified "$files"|
        forgit::fzf +m -0 \
            --bind="enter:execute($cmd |LESS='-R' less)" \
            --preview="$cmd"
}

# git add selector
forgit::add() {
    forgit::inside_work_tree || return 1
    local added=${$(git config color.status.untracked):-red}
    added=$(forgit::color_to_grep_code "$added")
    local changed=${$(git config color.status.changed):-red}
    changed=$(forgit::color_to_grep_code "$changed")
    local unmerged=${$(git config color.status.unmerged):-red}
    unmerged=$(forgit::color_to_grep_code "$unmerged")
    local files=$(git -c color.status=always status --short |
        grep -e "$added" -e "$changed" -e "$unmerged" |
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
    local cmd="git diff --color=always -- {} $forgit_emojify $forgit_fancy"
    local files=$(git ls-files --modified $(git rev-parse --show-toplevel)|
        forgit::fzf -m -0 --preview="$cmd")
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
    # Note: Postfix '/' in directory path should be removed. Otherwise the directory itself will not be removed.
    local files=$(git clean -xdfn "$@"| awk '{print $3}'| forgit::fzf -m -0 |sed 's#/$##')
    [[ -n "$files" ]] && echo "$files" |xargs -I{} git clean -xdf {}
    echo 'Nothing to clean.'
}

# git ignore generator
export FORGIT_GI_CACHE=~/.gicache
export FORGIT_GI_INDEX=$FORGIT_GI_CACHE/.index
forgit:ignore() {
    [ -f $FORGIT_GI_INDEX ] || forgit::ignore::update
    local preview="echo {} |awk '{print \$2}' |xargs -I% bash -c 'cat $FORGIT_GI_CACHE/% 2>/dev/null || (curl -sL https://www.gitignore.io/api/% |tee $FORGIT_GI_CACHE/%)'"
    IFS=$'\n'
    [[ $# -gt 0 ]] && args=($@) || args=($(cat $FORGIT_GI_INDEX |nl -nrn -w4 -s'  ' |forgit::fzf -m --preview="$preview" --preview-window="right:70%" |awk '{print $2}'))
    test -z "$args" && return 1
    local options=(
    '(1) Output to stdout'
    '(2) Append to .gitignore'
    '(3) Overwrite .gitignore')
    opt=$(printf '%s\n' "${options[@]}" |forgit::fzf +m |awk '{print $1}')
    case "$opt" in
        '(1)' )
            forgit::ignore::get ${args[@]}
            ;;
        '(2)' )
            forgit::ignore::get ${args[@]} >> .gitignore
            ;;
        '(3)' )
            forgit::ignore::get ${args[@]} > .gitignore
            ;;
    esac
}
forgit::ignore::update() {
    mkdir -p $FORGIT_GI_CACHE
    curl -sL https://www.gitignore.io/api/list |tr ',' '\n' > $FORGIT_GI_INDEX
}
forgit::ignore::get() {
    mkdir -p $FORGIT_GI_CACHE
    for item in "$@"; do
        cat "$FORGIT_GI_CACHE/$item" 2>/dev/null || (curl -sL "https://www.gitignore.io/api/$item" |tee "$FORGIT_GI_CACHE/$item")
    done
}
forgit::ignore::clean() {
    setopt localoptions rmstarsilent
    [[ -d $FORGIT_GI_CACHE ]] && rm -rf $FORGIT_GI_CACHE/*
}

# add aliases
if [[ -z "$FORGIT_NO_ALIASES" ]]; then
    alias ${forgit_add:-ga}='forgit::add'
    alias ${forgit_log:-glo}='forgit::log'
    alias ${forgit_diff:-gd}='forgit::diff'
    alias ${forgit_ignore:-gi}='forgit:ignore'
    alias ${forgit_restore:-gcf}='forgit::restore'
    alias ${forgit_clean:-gclean}='forgit::clean'
    alias ${forgit_stash_show:-gss}='forgit::stash::show'
fi
