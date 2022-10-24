#!/usr/bin/env bash
# MIT (c) Wenxuan Zhang

forgit::error() { printf "%b[Error]%b %s\n" '\e[0;31m' '\e[0m' "$@" >&2; return 1; }

# set installation path
if [[ -n "$ZSH_VERSION" ]]; then
    # shellcheck disable=2277,2296,2299
    0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
    # shellcheck disable=2277,2296,2298
    0="${${(M)0:#/*}:-$PWD/$0}"
    FORGIT_INSTALL_DIR="${0:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    FORGIT_INSTALL_DIR="$(dirname -- "${BASH_SOURCE[0]}")"
else
    forgit::error "Only zsh and bash are supported"
fi
export FORGIT_INSTALL_DIR

# register shell functions
forgit::log() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" log "$@"
}

forgit::diff() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" diff "$@"
}

forgit::add() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" add "$@"
}

forgit::reset::head() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" reset_head "$@"
}

forgit::stash::show() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" stash_show "$@"
}

forgit::clean() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" clean "$@"
}

forgit::cherry::pick() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" cherry_pick "$@"
}

forgit::cherry::pick::from::branch() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" cherry_pick_from_branch "$@"
}

forgit::rebase() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" rebase "$@"
}

forgit::fixup() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" fixup "$@"
}

forgit::checkout::file() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" checkout_file "$@"
}

forgit::checkout::branch() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" checkout_branch "$@"
}

forgit::checkout::tag() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" checkout_tag "$@"
}

forgit::checkout::commit() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" checkout_commit "$@"
}

forgit::branch::delete() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" branch_delete "$@"
}

forgit::revert::commit() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" revert_commit "$@"
}

forgit::blame() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" blame "$@"
}

forgit::ignore() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" ignore "$@"
}

forgit::ignore::update() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" ignore_update "$@"
}

forgit::ignore::get() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" ignore_get "$@"
}

forgit::ignore::list() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" ignore_list "$@"
}

forgit::ignore::clean() {
    "$FORGIT_INSTALL_DIR/bin/git-forgit" ignore_clean "$@"
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
    alias "${forgit_cherry_pick:-gcp}"='forgit::cherry::pick::from::branch'
    alias "${forgit_rebase:-grb}"='forgit::rebase'
    alias "${forgit_fixup:-gfu}"='forgit::fixup'
    alias "${forgit_blame:-gbl}"='forgit::blame'
fi
