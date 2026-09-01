#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit

    # Ignore global git config files
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null

    # Create a temporary git repository for testing
    cd "$(bashunit::temp_dir)" || return 1
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git commit -q --allow-empty -m "initial commit"
    git branch existing-branch
}

function test_switch_branch_creates_branch_when_it_does_not_exist() {
    _forgit_switch_branch auto-created-branch &>/dev/null
    assert_exit_code "0"
    assert_same "auto-created-branch" "$(git branch --show-current)"
}

function test_switch_branch_does_not_create_branch_when_auto_create_is_disabled() {
    FORGIT_SWITCH_AUTO_CREATE_BRANCH=false
    _forgit_switch_branch not-created-branch &>/dev/null
    assert_exit_code "128"
    assert_not_contains "not-created-branch" "$(git branch --list --format='%(refname:short)')"
}

function test_switch_branch_switches_to_existing_branch() {
    FORGIT_SWITCH_AUTO_CREATE_BRANCH=false
    _forgit_switch_branch existing-branch &>/dev/null
    assert_exit_code "0"
    assert_same "existing-branch" "$(git branch --show-current)"
}

function test_switch_branch_switches_to_existing_branch_when_auto_create_is_disabled() {
    FORGIT_SWITCH_AUTO_CREATE_BRANCH=false
    _forgit_switch_branch existing-branch &>/dev/null
    assert_exit_code "0"
    assert_same "existing-branch" "$(git branch --show-current)"
}

function test_switch_branch_creates_branch_when_requested_when_auto_create_is_disabled() {
    FORGIT_SWITCH_AUTO_CREATE_BRANCH=false
    _forgit_switch_branch -c explicitly-created-branch &>/dev/null
    assert_exit_code "0"
    assert_same "explicitly-created-branch" "$(git branch --show-current)"
}
