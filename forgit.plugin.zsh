#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang

forgit::error() { printf "%b[Error]%b %s\n" '\e[0;31m' '\e[0m' "$@" >&2; return 1; }
forgit::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }

# determine installation path
if [[ -n "$ZSH_VERSION" ]]; then
    # shellcheck disable=2277,2296,2299
    0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
    # shellcheck disable=2277,2296,2298
    0="${${(M)0:#/*}:-$PWD/$0}"
    INSTALL_DIR="${0:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    INSTALL_DIR="$(dirname -- "${BASH_SOURCE[0]}")"
else
    forgit::error "Only zsh and bash are supported"
fi
FORGIT="$INSTALL_DIR/bin/git-forgit"

# backwards compatibility:
# export all user-defined FORGIT variables to make them available in git-forgit
unexported_vars=0
# Set posix mode in bash to only get variables, see #256.
[[ -n "$BASH_VERSION" ]] && set -o posix
set | awk -F '=' '{ print $1 }' | grep FORGIT_ | while read -r var; do
    if ! export | grep -q "\(^$var=\|^export $var=\)"; then
        if [[ $unexported_vars == 0 ]]; then
            forgit::warn "Config options have to be exported in future versions of forgit."
            forgit::warn "Please update your config accordingly:"
        fi
        forgit::warn "  export $var"
        unexported_vars=$((unexported_vars + 1))
        # shellcheck disable=SC2163
        export "$var"
    fi
done
[[ -n "$BASH_VERSION" ]] && set +o posix

# register shell functions
forgit::log() {
    "$FORGIT" log "$@"
}

forgit::diff() {
    "$FORGIT" diff "$@"
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

# register aliases
# shellcheck disable=SC2139
if [[ -z "$FORGIT_NO_ALIASES" ]]; then
    alias "${forgit_add:-ga}"='forgit::add'
    alias "${forgit_reset_head:-grh}"='forgit::reset::head'
    alias "${forgit_log:-glo}"='forgit::log'
    alias "${forgit_diff:-gd}"='forgit::diff'
    alias "${forgit_ignore:-gi}"='forgit::ignore'
    alias "${forgit_checkout_file:-gcf}"='forgit::checkout::file'
    alias "${forgit_checkout_branch:-gcb}"='forgit::checkout::branch'
    alias "${forgit_checkout_commit:-gco}"='forgit::checkout::commit'
    alias "${forgit_branch_delete:-gbd}"='forgit::branch::delete'
    alias "${forgit_revert_commit:-grc}"='forgit::revert::commit'
    alias "${forgit_checkout_tag:-gct}"='forgit::checkout::tag'
    alias "${forgit_clean:-gclean}"='forgit::clean'
    alias "${forgit_stash_show:-gss}"='forgit::stash::show'
    alias "${forgit_stash_push:-gsp}"='forgit::stash::push'
    alias "${forgit_cherry_pick:-gcp}"='forgit::cherry::pick::from::branch'
    alias "${forgit_rebase:-grb}"='forgit::rebase'
    alias "${forgit_fixup:-gfu}"='forgit::fixup'
    alias "${forgit_blame:-gbl}"='forgit::blame'
fi
