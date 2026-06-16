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
}

function test_restore_shows_message_when_no_modified_files() {
    output=$(_forgit_restore 2>&1)
    assert_general_error
    assert_same "Nothing to restore." "$output"
}

function test_parse_restore_args() {
    IFS=$'\t' read -r staged worktree preview_arg < <(_forgit_parse_restore_flags --staged)

    assert_same "$staged" true
    assert_same "$worktree" false
    assert_same "$preview_arg" --staged

    IFS=$'\t' read -r staged worktree preview_arg < <(_forgit_parse_restore_flags --worktree)
    assert_same "$staged" false
    assert_same "$worktree" true
    assert_same "$preview_arg" ''

    IFS=$'\t' read -r staged worktree preview_arg < <(_forgit_parse_restore_flags --worktree --staged)
    assert_same "$staged" true
    assert_same "$worktree" true
    assert_same "$preview_arg" HEAD

    IFS=$'\t' read -r staged worktree preview_arg < <(_forgit_parse_restore_flags -W -S)
    assert_same "$staged" true
    assert_same "$worktree" true
    assert_same "$preview_arg" HEAD

    # other flags do not change the outcome
    IFS=$'\t' read -r staged worktree preview_arg < <(_forgit_parse_restore_flags -W -S -U --unknown-flag)
    assert_same "$staged" true
    assert_same "$worktree" true
    assert_same "$preview_arg" HEAD
}
