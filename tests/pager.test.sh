#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
}

function less() {
    printf 'LESS=%s\n' "$LESS"
    printf 'ARGS=%s\n' "$*"
}

function test_enter_pager_preserves_less_and_disables_automatic_exit() {
    local actual

    actual=$(LESS="-F -E -X -S -N" _forgit_pager enter)

    assert_contains "LESS=-F -E -X -S -N" "$actual"
    assert_contains "ARGS=-R -+F -+E" "$actual"
}
