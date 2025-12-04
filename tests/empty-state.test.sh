#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
}

function set_up() {
    # Create a temporary git repository for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR" || exit 1
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    # Create an initial commit so we have a valid repo
    echo "initial" > README.md
    git add README.md
    git commit -q -m "Initial commit"
}

function tear_down() {
    cd - > /dev/null || exit 1
    rm -rf "$TEST_DIR"
}

function test_checkout_file_shows_message_when_no_modified_files() {
    output=$(_forgit_checkout_file 2>&1)
    exit_code=$?

    assert_same "Nothing to checkout." "$output"
    assert_same "1" "$exit_code"
}

function test_checkout_tag_shows_message_when_no_tags() {
    output=$(_forgit_checkout_tag 2>&1)
    exit_code=$?

    assert_same "Nothing to checkout: there are no tags." "$output"
    assert_same "1" "$exit_code"
}
