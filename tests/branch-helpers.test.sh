#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
}

# --- _forgit_extract_branch_name ---

# @data_provider provider_extract_branch_name
function test_forgit_extract_branch_name() {
    local -r input="$1"
    local -r expected="$2"
    local actual
    actual=$(echo "$input" | _forgit_extract_branch_name)
    assert_same "$expected" "$actual"
}

function provider_extract_branch_name() {
    bashunit::data_set "  main" "main"
    bashunit::data_set "* main" "main"
    bashunit::data_set "+ feature" "feature"
    bashunit::data_set "  remotes/origin/HEAD -> origin/main" "remotes/origin/HEAD"
    bashunit::data_set "  remotes/origin/feature/foo" "remotes/origin/feature/foo"
}

# --- _forgit_strip_ansi ---

# @data_provider provider_strip_ansi
function test_forgit_strip_ansi() {
    local -r input="$1"
    local -r expected="$2"
    local actual
    actual=$(printf '%b' "$input" | _forgit_strip_ansi)
    assert_same "$expected" "$actual"
}

function provider_strip_ansi() {
    bashunit::data_set '\e[32mfoo\e[0m' "foo"
    bashunit::data_set '\e[1;31mbar\e[0m' "bar"
    bashunit::data_set 'no-ansi' "no-ansi"
}

# --- _forgit_extract_worktree_path ---

# @data_provider provider_extract_worktree_path
function test_forgit_extract_worktree_path() {
    local -r input="$1"
    local -r expected="$2"
    local actual
    actual=$(echo "$input" | _forgit_extract_worktree_path)
    assert_same "$expected" "$actual"
}

function provider_extract_worktree_path() {
    bashunit::data_set '[* ] /tmp/foo (main) 3 hours ago' "/tmp/foo"
    bashunit::data_set '[  ] /tmp/bar (feature) 1 day ago' "/tmp/bar"
}
