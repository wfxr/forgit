#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang

# https://github.com/wfxr/emoji-cli
hash emojify &>/dev/null && forgit_emojify='|emojify'

forgit_pager=${FORGIT_PAGER:-$(git config core.pager || echo 'cat')}
forgit_show_pager=${FORGIT_SHOW_PAGER:-$(git config pager.show || echo "$forgit_pager")}
forgit_diff_pager=${FORGIT_DIFF_PAGER:-$(git config pager.diff || echo "$forgit_pager")}

# git ignore generator
export FORGIT_GI_REPO_REMOTE=${FORGIT_GI_REPO_REMOTE:-https://github.com/dvcs/gitignore}
export FORGIT_GI_REPO_LOCAL=${FORGIT_GI_REPO_LOCAL:-~/.forgit/gi/repos/dvcs/gitignore}
export FORGIT_GI_TEMPLATES=${FORGIT_GI_TEMPLATES:-$FORGIT_GI_REPO_LOCAL/templates}

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
    alias "${forgit_restore:-gcf}"='forgit::restore'
    alias "${forgit_clean:-gclean}"='forgit::clean'
    alias "${forgit_stash_show:-gss}"='forgit::stash::show'
    alias "${forgit_cherry_pick:-gcp}"='forgit::cherry::pick'
fi

0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

fpath+="${0:h}/autoload"
autoload -Uz "${0:h}/autoload/"*(.:t)
