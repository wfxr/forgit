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
    # Create an initial commit so we have a valid repo
    echo "initial" > README.md
    git add README.md
    git commit -q -m "Initial commit"
}

function test_checkout_file_shows_message_when_no_modified_files() {
    output=$(_forgit_checkout_file 2>&1)
    assert_general_error

    assert_same "Nothing to checkout." "$output"
}

function test_checkout_tag_shows_message_when_no_tags() {
    output=$(_forgit_checkout_tag 2>&1)
    assert_general_error

    assert_same "Nothing to checkout: there are no tags." "$output"
}
