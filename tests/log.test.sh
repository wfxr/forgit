#!/usr/bin/env bash

function set_up_before_script() {
    # disable log graph to remove the asterisk from the output
    export FORGIT_LOG_GRAPH_ENABLE='false'

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
    git commit --allow-empty -qm "Initial commit"
}

function test_forgit_git_log() {
    local output
    # set log format to '%s' so we don't have to match the commit hash
    output=$(_forgit_git_log '%s' 2>&1 | sed 's/^[0-9a-f] //')
    assert_same "Initial commit" "$output"
}
