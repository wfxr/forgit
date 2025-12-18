#!/usr/bin/env bash

function set_up_before_script() {
    local submod submod1
    source bin/git-forgit

    # Ignore global git config files
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null

    # create repositories for submodule usage
    submod=$(create_submodule)
    submod1=$(create_submodule)

    # create a new git repository in a temp directory
    create_repo

    # create submodules to test against
    git -c protocol.file.allow=always submodule add "$submod" submodule
    git -c protocol.file.allow=always submodule add "$submod1" 'submodule with spaces'

    # create regular directories
    mkdir regular-directory
    mkdir 'directory with spaces'
}

function create_submodule() {
    create_repo
    touch file
    git add file
    git commit -q -m "initial commit"
}

function create_repo() {
    cd "$(bashunit::temp_dir)" || return 1
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    pwd
}

# @data_provider provider_is_submodule
function test_forgit_is_submodule() {
    _forgit_is_submodule "$1"
    assert_exit_code "0"
}

function provider_is_submodule() {
    bashunit::data_set submodule
    bashunit::data_set 'submodule with spaces'
}

# @data_provider provider_is_no_submodule
function test_forgit_is_no_submodule() {
    _forgit_is_submodule "$1"
    assert_exit_code "1"
}

function provider_is_no_submodule() {
    bashunit::data_set regular-directory
    bashunit::data_set 'directory with spaces'
    bashunit::data_set unknown
}
