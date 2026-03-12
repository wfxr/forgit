#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit

    # ignore global git config files
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null

    # create a new git repository in a temp directory
    cd "$(bashunit::temp_dir)" || return 1
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    # create an initial commit so we have a valid repo
    touch file.txt
    touch file1.txt
    git add .
    git commit -qm "Initial commit"
}

function test_forgit_git_show() {
    local output
    output=$(_forgit_git_show HEAD 2>&1)
    assert_same "[A]     file.txt
[A]     file1.txt" "$output"
}

function test_forgit_git_show_filter() {
    local output
    output=$(_forgit_git_show HEAD -- file.txt 2>&1)
    assert_same "[A]     file.txt" "$output"
}
