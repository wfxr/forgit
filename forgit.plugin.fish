#!/usr/local/bin/fish
# MIT (c) Chris Apple 

function forgit::warn
    printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$argv" >&2;
end

function forgit::info 
    printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$argv" >&2;
end

function forgit::inside_work_tree 
    git rev-parse --is-inside-work-tree >/dev/null; 
end

set core_pager (git config core.pager)

if test -n $core_pager
    set forgit_pager "$core_pager"
else if type -q diff-so-fancy >/dev/null 2>&1
    set forgit_pager "diff-so-fancy | less --tabs 4 -RFX"
else 
    set forgit_pager "cat"
end

# https://github.com/wfxr/emoji-cli
type -q emojify >/dev/null 2>&1 && set forgit_emojify '|emojify'

# git commit viewer
function forgit::log 
    forgit::inside_work_tree || return 1
    set cmd "echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % $argv | $forgit_pager"
    echo $cmd

    if test -n "$FORGIT_COPY_CMD"
        set copy_cmd $FORGIT_COPY_CMD
    else 
        set copy_cmd pbcopy 
    end

    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m --tiebreak=index --preview=\"$cmd\"
        --bind=\"enter:execute($cmd |env LESS='-R' less)\"
        --bind=\"ctrl-y:execute-silent(echo {} |grep -Eo '[a-f0-9]+' | head -1 | tr -d '\n' | $copy_cmd)\"
        $FORGIT_LOG_FZF_OPTS
    "
    eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $argv $forgit_emojify" |
        env FZF_DEFAULT_OPTS="$opts" fzf
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

    set repo "(git rev-parse --show-toplevel)"
    set target "\(echo {} | sed 's/.*]  //')"
    set cmd "git diff --color=always $commit -- $repo/$target | $forgit_pager"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        +m -0 --preview=\"$cmd\" --bind=\"enter:execute($cmd |env LESS='-R' less)\"
        $FORGIT_DIFF_FZF_OPTS
    "
    set cmd "echo" && type -q realpath > /dev/null 2>&1 && set cmd "realpath --relative-to=."
    set git_rev_parse (git rev-parse --show-toplevel)
    eval "git diff --name-only $commit -- $files*| sed 's/^\(.\)[[:space:]]\+\(.*\)\$/[\1]  \2/'" |

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
        --preview=\"git diff --color=always -- {-1} | $forgit_pager\"
        $FORGIT_ADD_FZF_OPTS
    "
    set files (git -c color.status=always -c status.relativePaths=true status --short |
        grep -F -e "$changed" -e "$unmerged" -e "$untracked" |
        sed 's/^\(..[^[:space:]]*\)[[:space:]]\+\(.*\)\$/[\1]  \2/' |   # deal with white spaces internal to fname
        env FZF_DEFAULT_OPTS="$opts" fzf | 
        sed -e 's/^[[:space:]]*//' | # remove leading whitespace
        cut -d " " -f 2- |  # cut the line after the M or ??, this leaves just the filename
        sed 's/.* -> //') # for rename case

    if test -n "$files"
        for file in $files
            echo $file | tr '\n' '\0' | xargs -I{} -0 git add {} && git status --short && return
        end
        return
    end
    echo 'Nothing to add.'
end

## git reset HEAD (unstage) selector
function forgit::reset::head
    forgit::inside_work_tree || return 1
    set cmd "git diff --cached --color=always -- {} | $forgit_pager"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
        $FORGIT_RESET_HEAD_FZF_OPTS
    "
    set files (git diff --cached --name-only --relative | env FZF_DEFAULT_OPTS="$opts" fzf)
    if test -n "$files"
        for file in $files
            echo $file | tr '\n' '\0' |xargs -I{} -0 git reset -q HEAD {} && git status --short && return
        end
    end
    echo 'Nothing to unstage.'
end

# git checkout-restore selector
function forgit::restore
    forgit::inside_work_tree || return 1

    set cmd "git diff --color=always -- {} | $forgit_pager"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
        $FORGIT_CHECKOUT_FZF_OPTS
    "
    set git_rev_parse (git rev-parse --show-toplevel)
    set files (git ls-files --modified "$git_rev_parse" | env FZF_DEFAULT_OPTS="$opts" fzf)
    if test -n "$files"
        for file in $files
            echo $file | tr '\n' '\0' |xargs -I{} -0 git checkout {} && git status --short && return
        end
    end
    echo 'Nothing to restore.'
end

# git stash viewer
function forgit::stash::show
    forgit::inside_work_tree || return 1
    set cmd "git stash show \(echo {}| cut -d: -f1) --color=always --ext-diff | $forgit_pager"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        +s +m -0 --tiebreak=index --preview=\"$cmd\" --bind=\"enter:execute($cmd |env LESS='-R' less)\"
        $FORGIT_STASH_FZF_OPTS
    "
    git stash list | env FZF_DEFAULT_OPTS="$opts" fzf
end

# git clean selector
function forgit::clean
    forgit::inside_work_tree || return 1

    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
        $FORGIT_CLEAN_FZF_OPTS
    "

    set files (git clean -xdfn $argv| awk '{print $3}'| env FZF_DEFAULT_OPTS="$opts" fzf |sed 's#/$##')

    if test -n "$files"
        for file in $files
            echo $file | tr '\n' '\0'|xargs -0 -I{} git clean -xdf {} && return
        end
    end
    echo 'Nothing to clean.'
end

# git ignore generator
if test -z "$FORGIT_GI_REPO_REMOTE"
    set -x FORGIT_GI_REPO_REMOTE https://github.com/dvcs/gitignore
end

if test -z "$FORGIT_GI_REPO_LOCAL"
    set -x FORGIT_GI_REPO_LOCAL ~/.forgit/gi/repos/dvcs/gitignore
end

if test -z "$FORGIT_GI_TEMPLATES"
    set -x FORGIT_GI_TEMPLATES $FORGIT_GI_REPO_LOCAL/templates
end

function forgit::ignore
    if test -d "$FORGIT_GI_REPO_LOCAL"
        forgit::ignore::update
    end

    # https://github.com/sharkdp/bat.git
    type -q bat > /dev/null 2>&1 && set cat 'bat -l gitignore --color=always' || set cat "cat"
    set cmd "$cat $FORGIT_GI_TEMPLATES/{2}{,.gitignore} 2>/dev/null"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m --preview=\"$cmd\" --preview-window='right:70%'
        $FORGIT_IGNORE_FZF_OPTS
    "
    set IFS '\n'

    set args $argv 
    if not count $argv > /dev/null
        set args (forgit::ignore::list | nl -nrn -w4 -s'  ' |
        env FZF_DEFAULT_OPTS="$opts" fzf  |awk '{print $2}')
    end

     if not count $args > /dev/null
         return 1
     end

    if type -q bat > /dev/null 2>&1
        forgit::ignore::get $args | bat -l gitignore
    else
        forgit::ignore::get $args
    end 
end

function forgit::ignore::update
    if test -d "$FORGIT_GI_REPO_LOCAL"
        forgit::info 'Updating gitignore repo...'
        set pull_result (git -C "$FORGIT_GI_REPO_LOCAL" pull --no-rebase --ff) 
        test -n "$pull_result" || return 1
    else
        forgit::info 'Initializing gitignore repo...'
        git clone --depth=1 "$FORGIT_GI_REPO_REMOTE" "$FORGIT_GI_REPO_LOCAL"
    end
end

function forgit::ignore::get
    for item in $argv
        set filename (find -L "$FORGIT_GI_TEMPLATES" -type f \( -iname "$item.gitignore" -o -iname "$item}" \) -print -quit)
        if test -n "$filename"
            set header $filename && set header (echo $filename | sed 's/.*\.//')
            echo "### $header" && cat "$filename" && echo
        else 
            forgit::warn "No gitignore template found for '$item'." && continue
        end 
    end
end

function forgit::ignore::list
    find "$FORGIT_GI_TEMPLATES" -print |sed -e 's#.gitignore$##' -e 's#.*/##' | sort -fu
end

function forgit::ignore::clean
    setopt localoptions rmstarsilent
    [[ -d "$FORGIT_GI_REPO_LOCAL" ]] && rm -rf "$FORGIT_GI_REPO_LOCAL"
end

set FORGIT_FZF_DEFAULT_OPTS "
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
$FORGIT_FZF_DEFAULT_OPTS
"

# register aliases
if test -z "$FORGIT_NO_ALIASES" 
    if test -n "$forgit_add"
        alias $forgit_add 'forgit::add'
    else
        alias ga 'forgit::add'
    end

    if test -n "$forgit_reset_head"
        alias $forgit_reset_head 'forgit::reset::head'
    else
        alias grh 'forgit::reset::head'
    end

    if test -n "$forgit_log"
        alias $forgit_log 'forgit::log'
    else
        alias glo 'forgit::log'
    end

    if test -n "$forgit_diff"
        alias $forgit_diff 'forgit::diff'
    else
        alias gd 'forgit::diff'
    end

    if test -n "$forgit_ignore"
        alias $forgit_ignore 'forgit::ignore'
    else
        alias gi 'forgit::ignore'
    end

    if test -n "$forgit_restore"
        alias $forgit_restore 'forgit::restore'
    else
        alias gcf 'forgit::restore'
    end

    if test -n "$forgit_clean"
        alias $forgit_clean 'forgit::clean'
    else
        alias gclean 'forgit::clean'
    end

    if test -n "$forgit_stash_show"
        alias $forgit_stash_show 'forgit::stash::show'
    else
        alias gss 'forgit::stash::show'
    end
end
