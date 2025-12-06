#!/usr/bin/env bash

function test_exit_when_fzf_is_not_installed() {
    # Error code 127 = "command not found"
    bashunit::mock fzf "return 127"

    output=$(bin/git-forgit)

    assert_general_error
    assert_contains "fzf is not installed" "$output"
}

# @data_provider fzf_versions_below_required_version
function test_exit_when_fzf_version_is_below_required_version() {
    bashunit::mock "fzf" "echo '$1'"

    output=$(bin/git-forgit)

    assert_general_error
    assert_contains "fzf version 0.49.0 or higher is required" "$output"
}

function fzf_versions_below_required_version() {
    echo "0.0.2"
    echo "0.5.0"
    echo "0.30.0"
    echo "0.48.9"
}

# @data_provider fzf_versions_satisfying_required_version
function test_pass_when_fzf_version_satisfies_required_version() {
    bashunit::mock "fzf" "echo '$1'"

    output=$(bin/git-forgit)

    assert_general_error
    assert_contains "missing command" "$output"
}

function fzf_versions_satisfying_required_version() {
    echo "0.49.0"
    echo "0.49.1"
    echo "0.80.0"
    echo "1.1.0"
}
