# MIT (c) Chris Apple

set forgit_pager "$FORGIT_PAGER"
set forgit_show_pager "$FORGIT_SHOW_PAGER"
set forgit_diff_pager "$FORGIT_DIFF_PAGER"
set forgit_ignore_pager "$FORGIT_IGNORE_PAGER"

test -z "$forgit_pager"; and set forgit_pager (git config core.pager || echo 'cat')
test -z "$forgit_show_pager"; and set forgit_show_pager (git config pager.show || echo "$forgit_pager")
test -z "$forgit_diff_pager"; and set forgit_diff_pager (git config pager.diff || echo "$forgit_pager")
test -z "$forgit_ignore_pager"; and set forgit_ignore_pager (type -q bat >/dev/null 2>&1 && echo 'bat -l gitignore --color=always' || echo 'cat')

# https://github.com/wfxr/emoji-cli
type -q emojify >/dev/null 2>&1 && set forgit_emojify '|emojify'

# git ignore generator
if test -z "$FORGIT_GI_REPO_REMOTE"
    set -x FORGIT_GI_REPO_REMOTE https://github.com/dvcs/gitignore
end

if test -z "$FORGIT_GI_REPO_LOCAL"
    if test "XDG_CACHE_HOME"
        set -x FORGIT_GI_REPO_LOCAL $XDG_CACHE_HOME/forgit/gi/repos/dvcs/gitignore
    else
        set -x FORGIT_GI_REPO_LOCAL $HOME/.cache/forgit/gi/repos/dvcs/gitignore
    end
end

if test -z "$FORGIT_GI_TEMPLATES"
    set -x FORGIT_GI_TEMPLATES $FORGIT_GI_REPO_LOCAL/templates
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
+1
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
        alias $forgit_restore 'forgit::checkout_file'
    else
        alias gcf 'forgit::checkout_file'
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

    if test -n "$forgit_cherry_pick"
        alias $forgit_cherry_pick 'forgit::cherry::pick'
    else
        alias gcp 'forgit::cherry::pick'
    end
end
