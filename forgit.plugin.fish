#!/usr/local/bin/fish
# MIT (c) Wenxuan Zhang

function forgit::warn
    printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$argv" >&2;
end

function forgit::info 
    printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$argv" >&2;
end

function forgit::inside_work_tree 
    git rev-parse --is-inside-work-tree >/dev/null; 
end

# https://github.com/so-fancy/diff-so-fancy
hash diff-so-fancy >/dev/null 2>&1 && set forgit_fancy '|diff-so-fancy'
# https://github.com/wfxr/emoji-cli
hash emojify >/dev/null 2>&1 && set forgit_emojify '|emojify'


# git commit viewer
function forgit::log 
    forgit::inside_work_tree || return 1
    set cmd "echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % $argv $forgit_fancy"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index --preview=\"$cmd\"
        --bind=\"enter:execute($cmd |LESS='-R' less)\"
        --bind=\"ctrl-y:execute-silent(echo {} |grep -Eo '[a-f0-9]+' | head -1 | tr -d '\n' | pbcopy)\"
        $FORGIT_LOG_FZF_OPTS
    "
    #TODO: removed option for another pbcopy above
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $argv $forgit_emojify" |
        env FZF_DEFAULT_OPTS "$opts" fzf
end

## git diff viewer
function forgit::diff
    forgit::inside_work_tree || return 1
    if not count $argv > /dev/null
        if git rev-parse "$1" > /dev/null 2>&1
            #set commit "$1" && set files ("${@:2}")
            set commit "$1" && set files "$2"
        else
            set files "$argv"
        end
    end

    set cmd "git diff --color=always $commit -- {} $forgit_fancy"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        +m -0 --preview=\"$cmd\" --bind=\"enter:execute($cmd |env LESS='-R' less)\"
        $FORGIT_DIFF_FZF_OPTS
    "
    set cmd "echo" && hash realpath > /dev/null 2>&1 && set cmd "realpath --relative-to=."
    #eval "git diff --name-only $commit -- ${files[*]}| xargs -I% $cmd '$(git rev-parse --show-toplevel)/%'"|
    set git_rev_parse (git rev-parse --show-toplevel)
    eval "git diff --name-only $commit -- $files*| xargs -I% $cmd '$git_rev_parse/%'"|
        env FZF_DEFAULT_OPTS="$opts" fzf
end

# git add selector
function forgit::add 
    forgit::inside_work_tree || return 1
    set changed (git config --get-color color.status.changed red)
    set unmerged (git config --get-color color.status.unmerged red)
    set untracked (git config --get-color color.status.untracked red)

    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -0 -m --nth 2..,..
        --preview=\"git diff --color=always -- {-1} $forgit_fancy\"
        $FORGIT_ADD_FZF_OPTS
    "
    set files (git -c color.status=always -c status.relativePaths=true status --short |
        grep -F -e "$changed" -e "$unmerged" -e "$untracked" |
        awk '{printf "[%10s]  ", $1; $1=""; print $0}' |
        env FZF_DEFAULT_OPTS="$opts" fzf | cut -d] -f2 |
        sed 's/.* -> //') # for rename case

    if test -n $files
        echo "$files" |xargs -I{} git add {} && git status --short && return
    end
    echo 'Nothing to add.'
end

## git reset HEAD (unstage) selector
function forgit::reset::head
    forgit::inside_work_tree || return 1
    set cmd "git diff --cached --color=always -- {} $forgit_fancy"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
        $FORGIT_RESET_HEAD_FZF_OPTS
    "
    set files "(git diff --cached --name-only --relative | env FZF_DEFAULT_OPTS="$opts" fzf)"
    if test -n $files
        echo "$files" |xargs -I{} git reset -q HEAD {} && git status --short && return
    end
    echo 'Nothing to unstage.'
end

# git checkout-restore selector
function forgit::restore
    forgit::inside_work_tree || return 1

    set cmd "git diff --color=always -- {} $forgit_fancy"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
        $FORGIT_CHECKOUT_FZF_OPTS
    "
    set git_rev_parse (git rev-parse --show-toplevel)
    set files (git ls-files --modified "$git_rev_parse" | env FZF_DEFAULT_OPTS="$opts" fzf)
    if test -n $files
        echo "$files" |xargs -I{} git checkout {} && git status --short && return
    end
    echo 'Nothing to restore.'
end

## git stash viewer
#forgit::stash::show() {
#    forgit::inside_work_tree || return 1
#    set cmd "git stash show \$(echo {}| cut -d: -f1) --color=always --ext-diff $forgit_fancy"
#    set opts"
#        $FORGIT_FZF_DEFAULT_OPTS
#        +s +m -0 --tiebreak=index --preview=\"$cmd\" --bind=\"enter:execute($cmd |LESS='-R' less)\"
#        $FORGIT_STASH_FZF_OPTS
#    "
#    git stash list | env FZF_DEFAULT_OPTS="$opts" fzf
#}
#
## git clean selector
#forgit::clean() {
#    forgit::inside_work_tree || return 1
#    set opts"
#        $FORGIT_FZF_DEFAULT_OPTS
#        -m -0
#        $FORGIT_CLEAN_FZF_OPTS
#    "
#    # Note: Postfix '/' in directory path should be removed. Otherwise the directory itself will not be removed.
#    set files $(git clean -xdfn "$argv"| awk '{print $3}'| env FZF_DEFAULT_OPTS="$opts" fzf |sed 's#/$##')
#    [[ -n "$files" ]] && echo "$files" |xargs -I% git clean -xdf % && return
#    echo 'Nothing to clean.'
#}
#
## git ignore generator
#export FORGIT_GI_REPO_REMOTE=${FORGIT_GI_REPO_REMOTE:-https://github.com/dvcs/gitignore}
#export FORGIT_GI_REPO_LOCAL=${FORGIT_GI_REPO_LOCAL:-~/.forgit/gi/repos/dvcs/gitignore}
#export FORGIT_GI_TEMPLATES=${FORGIT_GI_TEMPLATES:-$FORGIT_GI_REPO_LOCAL/templates}
#
#forgit::ignore() {
#    [ -d "$FORGIT_GI_REPO_LOCAL" ] || forgit::ignore::update
#    # https://github.com/sharkdp/bat.git
#    hash bat > /dev/null 2>&1 && cat='bat -l gitignore --color=always' || cat="cat"
#    set cmd "$cat $FORGIT_GI_TEMPLATES/{2}{,.gitignore} 2>/dev/null"
#    set opts"
#        $FORGIT_FZF_DEFAULT_OPTS
#        -m --preview=\"$cmd\" --preview-window='right:70%'
#        $FORGIT_IGNORE_FZF_OPTS
#    "
#    # shellcheck disable=SC2206,2207
#    IFS=$'\n' args=($argv) && [[ $# -eq 0 ]] && args=($(forgit::ignore::list | nl -nrn -w4 -s'  ' |
#        env FZF_DEFAULT_OPTS="$opts" fzf  |awk '{print $2}'))
#    [ ${#args[@]} -eq 0 ] && return 1
#    # shellcheck disable=SC2068
#    if hash bat > /dev/null 2>&1; then
#        forgit::ignore::get ${args[@]} | bat -l gitignore
#    else
#        forgit::ignore::get ${args[@]}
#    fi
#}
#forgit::ignore::update() {
#    if [[ -d "$FORGIT_GI_REPO_LOCAL" ]]; then
#        forgit::info 'Updating gitignore repo...'
#        (cd "$FORGIT_GI_REPO_LOCAL" && git pull --no-rebase --ff) || return 1
#    else
#        forgit::info 'Initializing gitignore repo...'
#        git clone --depth=1 "$FORGIT_GI_REPO_REMOTE" "$FORGIT_GI_REPO_LOCAL"
#    fi
#}
#forgit::ignore::get() {
#    for item in "$argv"; do
#        if filename=$(find -L "$FORGIT_GI_TEMPLATES" -type f \( -iname "${item}.gitignore" -o -iname "${item}" \) -print -quit); then
#            [[ -z "$filename" ]] && forgit::warn "No gitignore template found for '$item'." && continue
#            header="${filename##*/}" && header="${header%.gitignore}"
#            echo "### $header" && cat "$filename" && echo
#        fi
#    done
#}
#forgit::ignore::list() {
#    find "$FORGIT_GI_TEMPLATES" -print |sed -e 's#.gitignore$##' -e 's#.*/##' | sort -fu
#}
#forgit::ignore::clean() {
#    setopt localoptions rmstarsilent
#    [[ -d "$FORGIT_GI_REPO_LOCAL" ]] && rm -rf "$FORGIT_GI_REPO_LOCAL"
#}
#
#FORGIT_FZF_DEFAULT_OPTS="
#$FZF_DEFAULT_OPTS
#--ansi
#--height='80%'
#--bind='alt-k:preview-up,alt-p:preview-up'
#--bind='alt-j:preview-down,alt-n:preview-down'
#--bind='ctrl-r:toggle-all'
#--bind='ctrl-s:toggle-sort'
#--bind='?:toggle-preview'
#--bind='alt-w:toggle-preview-wrap'
#--preview-window='right:60%'
#$FORGIT_FZF_DEFAULT_OPTS
#"
#
## register aliases
## shellcheck disable=SC2139
#if test -z "$FORGIT_NO_ALIASES" 
#    alias "${forgit_add:-ga}"='forgit::add'
#    alias "${forgit_reset_head:-grh}"='forgit::reset::head'
#    alias "${forgit_log:-glo}"='forgit::log'
#    alias "${forgit_diff:-gd}"='forgit::diff'
#    alias "${forgit_ignore:-gi}"='forgit::ignore'
#    alias "${forgit_restore:-gcf}"='forgit::restore'
#    alias "${forgit_clean:-gclean}"='forgit::clean'
#    alias "${forgit_stash_show:-gss}"='forgit::stash::show'
#end
