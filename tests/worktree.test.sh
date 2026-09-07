#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit

    # Ignore global git config files
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null

    unset FORGIT_WORKTREE_ADD_DIR

    # Create a temporary git repository for testing
    MAIN_WORKTREE_ROOT="$(bashunit::temp_dir)/main"
    git init -q "$MAIN_WORKTREE_ROOT"
    cd "$MAIN_WORKTREE_ROOT" || return 1
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "initial" >README.md
    git add README.md
    git commit -q -m "Initial commit"
}

function test_worktree_add_dir_defaults_to_dot_wt_in_main_worktree_root() {
    assert_same "$MAIN_WORKTREE_ROOT/.wt" "$(_forgit_worktree_add_dir)"
}

function test_worktree_add_dir_resolves_a_relative_path_against_main_worktree_root() {
    assert_same "$MAIN_WORKTREE_ROOT/.worktrees" \
        "$(FORGIT_WORKTREE_ADD_DIR=.worktrees _forgit_worktree_add_dir)"
}

function test_worktree_add_dir_resolves_a_nested_relative_path() {
    assert_same "$MAIN_WORKTREE_ROOT/build/wt" \
        "$(FORGIT_WORKTREE_ADD_DIR=build/wt _forgit_worktree_add_dir)"
}

function test_worktree_add_dir_uses_an_absolute_path_as_is() {
    assert_same "/somewhere/else" \
        "$(FORGIT_WORKTREE_ADD_DIR=/somewhere/else _forgit_worktree_add_dir)"
}

function test_worktree_add_dir_resolves_a_relative_path_from_a_linked_worktree() {
    local linked_worktree="$MAIN_WORKTREE_ROOT/.worktrees/linked"
    git worktree add -q -b linked "$linked_worktree" >/dev/null 2>&1
    cd "$linked_worktree" || return 1

    assert_same "$MAIN_WORKTREE_ROOT/.worktrees" \
        "$(FORGIT_WORKTREE_ADD_DIR=.worktrees _forgit_worktree_add_dir)"
}
