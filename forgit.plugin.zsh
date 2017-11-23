wfxr::fzf() {
    fzf --border \
        --ansi \
        --cycle \
        --reverse \
        --height '80%' \
        --bind='alt-v:page-up' \
        --bind='ctrl-v:page-down' \
        --bind='alt-k:preview-up' \
        --bind='alt-j:preview-down' \
        --bind='alt-a:select-all' \
        --bind='ctrl-r:toggle-all' \
        --bind='ctrl-s:toggle-sort' \
        --bind='?:toggle-preview' \
        --bind='alt-w:toggle-preview-wrap' "$@"
}

(( $+commands[diff-so-fancy] )) && fancy='|diff-so-fancy'
(( $+commands[emojify] )) && emojify='|emojify'

unalias glo gd ga gi &>/dev/null

# git commit browser
glo() {
    git rev-parse --is-inside-work-tree &>/dev/null || return 1
    # diff is fancy with diff-so-fancy!
    local cmd="echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I% git show --color=always % $emojify $fancy"
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $@ $emojify" \
        |wfxr::fzf -e +s --tiebreak=index \
            --bind="enter:execute($cmd |less -R)" \
            --preview="$cmd" \
            --preview-window="right:60%"
}
# git diff brower
gd() {
    local cmd="git diff --color=always -- {} $emojify $fancy"
    git ls-files --modified \
        |wfxr::fzf -e -0 --bind="enter:execute($cmd |less -R)" \
            --preview="$cmd" \
            --preview-window="right:60%"
}
# git add selector
ga() {
    original=$(git config color.status)
    git config color.status always
    IFS=$'\n'
    local files=$(git status --short \
        |grep 31m |awk '{printf "[%10s]  ", $1; $1=""; print $0}' |sort \
        |wfxr::fzf -e -0 -m \
            --preview="echo {} |cut -d] -f2 |xargs git diff --color=always -- $emojify $fancy" \
            --preview-window="right:60%" \
        |cut -d] -f2 \
        |sed 's/.* -> //g') # for rename case
    [[ -n $files ]] && echo $files |xargs -I{} git add {}
    git status
    git config color.status $original
}

# git ignore generator
export giCache=~/.giCache
export giIndex=$giCache/.list
gi() {
    [ -f $giIndex ] || gi-update-index
    IFS=$'\n'
    [[ $# -gt 0 ]] && args="$@" || args="$(cat $giIndex |nl -nrn -w4 -s'  ' |fzf -m |awk '{print $2}')"
    gi-get $args
}
gi-update-index() {
    mkdir -p $giCache
    curl -sL https://www.gitignore.io/api/list |tr ',' '\n' > $giIndex
}
gi-get() {
    mkdir -p $giCache
    echo $@ |xargs -I{} bash -c "cat $giCache/{} 2>/dev/null || (curl -sL https://www.gitignore.io/api/{} |tee $giCache/{})"
}
gi-clean() {
    setopt localoptions rmstarsilent
    [[ -d $giCache ]] && rm -rf $giCache/*
}
