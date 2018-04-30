forgit::fzf() {
    fzf --border \
        --ansi \
        --cycle \
        --reverse \
        --height '80%' \
        --bind='alt-v:page-up' \
        --bind='ctrl-v:page-down' \
        --bind='alt-k:preview-up,alt-p:preview-up' \
        --bind='alt-j:preview-down,alt-n:preview-down' \
        --bind='alt-a:select-all' \
        --bind='ctrl-r:toggle-all' \
        --bind='ctrl-s:toggle-sort' \
        --bind='?:toggle-preview' \
        --preview-window="right:60%" \
        --bind='alt-w:toggle-preview-wrap' "$@"
}

# diff is fancy with diff-so-fancy!
(( $+commands[diff-so-fancy] )) && forgit_fancy='|diff-so-fancy'
(( $+commands[emojify]       )) && forgit_emojify='|emojify'

forgit::inside_work_tree() {
    git rev-parse --is-inside-work-tree >/dev/null
}

# git commit browser
forgit::log() {
    forgit::inside_work_tree || return 1
    local cmd="echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I% git show --color=always % $forgit_emojify $forgit_fancy"
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $@ $forgit_emojify" |
        forgit::fzf -e +s --tiebreak=index \
            --bind="enter:execute($cmd |LESS='-R' less)" \
            --preview="$cmd"
}

# git diff brower
forgit::diff() {
    forgit::inside_work_tree || return 1
    local cmd="git diff --color=always -- {} $forgit_emojify $forgit_fancy"
    git ls-files --modified $(git rev-parse --show-toplevel)|
        forgit::fzf -e -0 \
            --bind="enter:execute($cmd |LESS='-R' less)" \
            --preview="$cmd"
}

# git add selector
forgit::add() {
    forgit::inside_work_tree || return 1
    # '31m' matches red color to filter out added files which is all green
    local files=$(git -c color.status=always status --short |
        grep 31m |
        awk '{printf "[%10s]  ", $1; $1=""; print $0}' |
        forgit::fzf -e -0 -m --nth 2..,.. \
            --preview="git diff --color=always -- {-1} $forgit_emojify $forgit_fancy" |
        cut -d] -f2 |
        sed 's/.* -> //') # for rename case
    [[ -n $files ]] && echo $files |xargs -I{} git add {} && git status
}

# git ignore generator
export FORGIT_GI_CACHE=~/.gicache
export FORGIT_GI_INDEX=$FORGIT_GI_CACHE/.index
forgit:ignore() {
    [ -f $FORGIT_GI_INDEX ] || forgit::ignore::update
    local preview="echo {} |awk '{print \$2}' |xargs -I% bash -c 'cat $FORGIT_GI_CACHE/% 2>/dev/null || (curl -sL https://www.gitignore.io/api/% |tee $FORGIT_GI_CACHE/%)'"
    IFS=$'\n'
    [[ $# -gt 0 ]] && args=($@) || args=($(cat $FORGIT_GI_INDEX |nl -nrn -w4 -s'  ' |fzf -m --preview="$preview" --preview-window="right:70%" |awk '{print $2}'))
    test -z "$args" && return 1
    local options=(
    '(1) Output to stdout'
    '(2) Append to .gitignore'
    '(3) Overwrite .gitignore')
    opt=$(printf '%s\n' "${options[@]}" |fzf |awk '{print $1}')
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
    echo $@ |xargs -I{} bash -c "cat $FORGIT_GI_CACHE/{} 2>/dev/null || (curl -sL https://www.gitignore.io/api/{} |tee $FORGIT_GI_CACHE/{})"
}
forgit::ignore::clean() {
    setopt localoptions rmstarsilent
    [[ -d $FORGIT_GI_CACHE ]] && rm -rf $FORGIT_GI_CACHE/*
}

# add aliases
alias ${forgit_log:-ga}='forgit::add'
alias ${forgit_log:-glo}='forgit::log'
alias ${forgit_diff:-gd}='forgit::diff'
alias ${forgit_ignore:-gi}='forgit:ignore'
