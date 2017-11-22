(( $+commands[diff-so-fancy] )) && fancy='|diff-so-fancy'
(( $+commands[emojify] )) && emojify='|emojify'
# git commit browser
unalias glo 2>/dev/null
glo() {
    git rev-parse --is-inside-work-tree 1>/dev/null
    [ $? -ne 0 ] && return 1
    # diff is fancy with diff-so-fancy!
    local cmd="<<< {} grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I% git show --color=always % $emojify $fancy"
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $@ $emojify" \
        | fzf -e +s --tiebreak=index \
                    --bind="enter:execute($cmd | less -R)" \
                    --preview="$cmd" \
                    --preview-window="right:60%"
}
unalias gd 2>/dev/null
gd() {
    local cmd="git diff --color=always -- {} $emojify $fancy"
    git ls-files --modified \
        | fzf -e -0 --bind="enter:execute($cmd | less -R)" \
                    --preview="$cmd" \
                    --preview-window="right:60%"
}
unalias ga 2>/dev/null
ga() {
    original=$(git config color.status)
    git config color.status always
    IFS=$'\n' local files=$(git status --short \
        | grep 31m | awk '{printf "[%10s]  ", $1; $1=""; print $0 }' | sort \
        | fzf -e -0 -m \
            --preview="echo {} | cut -d] -f2 | xargs git diff --color=always -- $emojify $fancy" \
            --preview-window="right:60%" \
        | cut -d] -f2 \
        | sed 's/.* -> //g') # for rename case
    git config color.status $original
    [[ -n $files ]] && echo $files | xargs -I{} git add {}
    git status
}
# git ignore
local giCache=~/.giCache
local giIndex=$giCache/.list
unalias gi 2>/dev/null
gi() {
    [ -f $giIndex ] || gi-update-index
    IFS=$'\n'
    [[ $# -gt 0 ]] && args="$@" || args="$(cat $giIndex |nl -nrn -w4 -s'  ' |fzf -m | awk '{print $2}')"
    gi-get $args
}
gi-update-index() {
    mkdir -p $giCache
    curl -sL https://www.gitignore.io/api/list | tr ',' '\n' > $giIndex
}
gi-get() {
    mkdir -p $giCache
    echo $@ | xargs -I{} bash -c "cat $giCache/{} 2>/dev/null || (curl -sL https://www.gitignore.io/api/{} | tee $giCache/{})"
}
gi-clean() {
    setopt localoptions rmstarsilent
    [[ -d $giCache ]] && rm -rf $giCache/*
}
