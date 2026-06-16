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

    touch untracked.txt modified.txt staged.txt
    git add modified.txt
    git commit -q -m "modified"
    echo modified >>modified.txt
    git add staged.txt
}

function test_list_staged_files_only_lists_staged() {
    output=$(_forgit_list_staged_files)

    assert_same "$output" "staged.txt"
}

function test_list_staged_files_shows_relative_paths() {
    mkdir subdirectory
    cd subdirectory || return 1

    output=$(_forgit_list_staged_files)
    assert_same "$output" "../staged.txt"
}
