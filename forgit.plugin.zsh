#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang

# all commands are prefixed with command and all built-ins with builtin.
# These shell built-ins prevent the wrong commands getting executed in case a
# user added a shell alias with the same name.

forgit::error() { command printf "%b[Error]%b %s\n" '\e[0;31m' '\e[0m' "$@" >&2; builtin return 1; }
forgit::warn() { command printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }

# determine installation path
if [[ -n "$ZSH_VERSION" ]]; then
    # shellcheck disable=2277,2296,2299
    0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
    # shellcheck disable=2277,2296,2298
    0="${${(M)0:#/*}:-$PWD/$0}"
    FORGIT_INSTALL_DIR="${0:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    FORGIT_INSTALL_DIR="$(command dirname -- "${BASH_SOURCE[0]}")"
else
    forgit::error "Only zsh and bash are supported"
fi

builtin export FORGIT_INSTALL_DIR
FORGIT="$FORGIT_INSTALL_DIR/bin/git-forgit"

# backwards compatibility:
# export all user-defined FORGIT variables to make them available in git-forgit
unexported_vars=0
# Set posix mode in bash to only get variables, see #256.
[[ -n "$BASH_VERSION" ]] && builtin set -o posix
builtin set | command awk -F '=' '{ print $1 }' | command grep FORGIT_ | while builtin read -r var; do
    if ! builtin export | command grep -q "\(^$var=\|^export $var=\)"; then        if [[ $unexported_vars == 0 ]]; then
            forgit::warn "Config options have to be exported in future versions of forgit."
            forgit::warn "Please update your config accordingly:"
        fi
        forgit::warn "  export $var"
        unexported_vars=$((unexported_vars + 1))
        # shellcheck disable=SC2163
        builtin export "$var"
    fi
done
builtin unset unexported_vars
[[ -n "$BASH_VERSION" ]] && builtin set +o posix

# register shell functions
forgit::log() {
    "$FORGIT" log "$@"
}

forgit::reflog() {
    "$FORGIT" reflog "$@"
}

forgit::diff() {
    "$FORGIT" diff "$@"
}

forgit::show() {
    "$FORGIT" show "$@"
}

forgit::add() {
    "$FORGIT" add "$@"
}

forgit::reset::head() {
    "$FORGIT" reset_head "$@"
}

forgit::stash::show() {
    "$FORGIT" stash_show "$@"
}

forgit::stash::push() {
    "$FORGIT" stash_push "$@"
}

forgit::clean() {
    "$FORGIT" clean "$@"
}

forgit::cherry::pick() {
    "$FORGIT" cherry_pick "$@"
}

forgit::cherry::pick::from::branch() {
    "$FORGIT" cherry_pick_from_branch "$@"
}

forgit::rebase() {
    "$FORGIT" rebase "$@"
}

forgit::fixup() {
    "$FORGIT" fixup "$@"
}

forgit::squash() {
    "$FORGIT" squash "$@"
}

forgit::reword() {
    "$FORGIT" reword "$@"
}

forgit::checkout::file() {
    "$FORGIT" checkout_file "$@"
}

forgit::checkout::branch() {
    "$FORGIT" checkout_branch "$@"
}

forgit::checkout::tag() {
    "$FORGIT" checkout_tag "$@"
}

forgit::checkout::commit() {
    "$FORGIT" checkout_commit "$@"
}

forgit::branch::delete() {
    "$FORGIT" branch_delete "$@"
}

forgit::revert::commit() {
    "$FORGIT" revert_commit "$@"
}

forgit::blame() {
    "$FORGIT" blame "$@"
}

forgit::ignore() {
    "$FORGIT" ignore "$@"
}

forgit::ignore::update() {
    "$FORGIT" ignore_update "$@"
}

forgit::ignore::get() {
    "$FORGIT" ignore_get "$@"
}

forgit::ignore::list() {
    "$FORGIT" ignore_list "$@"
}

forgit::ignore::clean() {
    "$FORGIT" ignore_clean "$@"
}

forgit::attributes() {
    "$FORGIT" attributes "$@"
}

# register aliases
# shellcheck disable=SC2139
if [[ -z "$FORGIT_NO_ALIASES" ]]; then

    builtin export forgit_add="${forgit_add:-ga}"
    builtin export forgit_reset_head="${forgit_reset_head:-grh}"
    builtin export forgit_log="${forgit_log:-glo}"
    builtin export forgit_reflog="${forgit_reflog:-grl}"
    builtin export forgit_diff="${forgit_diff:-gd}"
    builtin export forgit_show="${forgit_show:-gso}"
    builtin export forgit_ignore="${forgit_ignore:-gi}"
    builtin export forgit_attributes="${forgit_attributes:-gat}"
    builtin export forgit_checkout_file="${forgit_checkout_file:-gcf}"
    builtin export forgit_checkout_branch="${forgit_checkout_branch:-gcb}"
    builtin export forgit_checkout_commit="${forgit_checkout_commit:-gco}"
    builtin export forgit_checkout_tag="${forgit_checkout_tag:-gct}"
    builtin export forgit_branch_delete="${forgit_branch_delete:-gbd}"
    builtin export forgit_revert_commit="${forgit_revert_commit:-grc}"
    builtin export forgit_clean="${forgit_clean:-gclean}"
    builtin export forgit_stash_show="${forgit_stash_show:-gss}"
    builtin export forgit_stash_push="${forgit_stash_push:-gsp}"
    builtin export forgit_cherry_pick="${forgit_cherry_pick:-gcp}"
    builtin export forgit_rebase="${forgit_rebase:-grb}"
    builtin export forgit_fixup="${forgit_fixup:-gfu}"
    builtin export forgit_squash="${forgit_squash:-gsq}"
    builtin export forgit_reword="${forgit_reword:-grw}"
    builtin export forgit_blame="${forgit_blame:-gbl}"

    builtin alias "${forgit_add}"='forgit::add'
    builtin alias "${forgit_reset_head}"='forgit::reset::head'
    builtin alias "${forgit_log}"='forgit::log'
    builtin alias "${forgit_reflog}"='forgit::reflog'
    builtin alias "${forgit_diff}"='forgit::diff'
    builtin alias "${forgit_show}"='forgit::show'
    builtin alias "${forgit_ignore}"='forgit::ignore'
    builtin alias "${forgit_attributes}"='forgit::attributes'
    builtin alias "${forgit_checkout_file}"='forgit::checkout::file'
    builtin alias "${forgit_checkout_branch}"='forgit::checkout::branch'
    builtin alias "${forgit_checkout_commit}"='forgit::checkout::commit'
    builtin alias "${forgit_checkout_tag}"='forgit::checkout::tag'
    builtin alias "${forgit_branch_delete}"='forgit::branch::delete'
    builtin alias "${forgit_revert_commit}"='forgit::revert::commit'
    builtin alias "${forgit_clean}"='forgit::clean'
    builtin alias "${forgit_stash_show}"='forgit::stash::show'
    builtin alias "${forgit_stash_push}"='forgit::stash::push'
    builtin alias "${forgit_cherry_pick}"='forgit::cherry::pick::from::branch'
    builtin alias "${forgit_rebase}"='forgit::rebase'
    builtin alias "${forgit_fixup}"='forgit::fixup'
    builtin alias "${forgit_squash}"='forgit::squash'
    builtin alias "${forgit_reword}"='forgit::reword'
    builtin alias "${forgit_blame}"='forgit::blame'

fi
