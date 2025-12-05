#!/usr/bin/env bash

function set_up() {
    source bin/git-forgit
}

function test_forgit_worktree_filter_excludes_plus_lines_by_default() {
    local input="+ worktree-branch
* main-branch
  other-branch"
    
    # Default behavior (true)
    local actual
    actual=$(echo "$input" | _forgit_worktree_filter)
    local expected="* main-branch
  other-branch"

    assert_same "$expected" "$actual"
}

function test_forgit_worktree_filter_excludes_plus_lines_when_explicitly_enabled() {
    export FORGIT_CHECKOUT_BRANCH_EXCLUDE_WORKTREES="true"
    local input="+ worktree-branch
* main-branch"
    
    local actual
    actual=$(echo "$input" | _forgit_worktree_filter)
    local expected="* main-branch"

    assert_same "$expected" "$actual"
    unset FORGIT_CHECKOUT_BRANCH_EXCLUDE_WORKTREES
}

function test_forgit_worktree_filter_includes_plus_lines_when_disabled() {
    export FORGIT_CHECKOUT_BRANCH_EXCLUDE_WORKTREES="false"
    local input="+ worktree-branch
* main-branch"
    
    local actual
    actual=$(echo "$input" | _forgit_worktree_filter)
    local expected="+ worktree-branch
* main-branch"

    assert_same "$expected" "$actual"
    unset FORGIT_CHECKOUT_BRANCH_EXCLUDE_WORKTREES
}
