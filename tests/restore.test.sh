#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null
    cd "$(bashunit::temp_dir)" || return 1
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "initial" >README.md
    git add README.md
    git commit -q -m "Initial commit"
}

function test_restore_shows_message_when_no_modified_files() {
    output=$(_forgit_restore 2>&1)
    assert_general_error
    assert_same "Nothing to restore." "$output"
}

function test_restore_reverts_modified_file_to_committed_state() {
    echo "original content" >tracked.txt
    git add tracked.txt
    git commit -q -m "Add tracked file"
    echo "modified content" >tracked.txt
    _forgit_git_restore tracked.txt
    assert_same "original content" "$(cat tracked.txt)"
}

function test_restore_does_not_affect_untracked_files() {
    echo "untracked content" >untracked.txt
    _forgit_git_restore untracked.txt 2>/dev/null || true
    assert_file_exists untracked.txt
    assert_same "untracked content" "$(cat untracked.txt)"
}

function test_restore_only_reverts_unstaged_changes_when_file_has_staged_and_unstaged() {
    echo "committed" >mixed.txt
    git add mixed.txt
    git commit -q -m "Add mixed file"
    echo "staged change" >mixed.txt
    git add mixed.txt
    echo "unstaged change" >mixed.txt
    _forgit_git_restore mixed.txt
    assert_same "staged change" "$(cat mixed.txt)"
}

function test_restore_with_renamed_file() {
    echo "rename content" >before-rename.txt
    git add before-rename.txt
    git commit -q -m "Add file for rename test"
    git mv before-rename.txt after-rename.txt
    git commit -q -m "Rename file"
    echo "modified after rename" >after-rename.txt
    _forgit_git_restore after-rename.txt
    assert_same "rename content" "$(cat after-rename.txt)"
}

function test_restore_passes_through_arguments_when_non_flags_provided() {
    echo "original" >passthrough.txt
    git add passthrough.txt
    git commit -q -m "Add passthrough file"
    echo "modified" >passthrough.txt
    _forgit_restore passthrough.txt
    assert_same "original" "$(cat passthrough.txt)"
}
