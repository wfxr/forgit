#!/usr/bin/env bash

 function set_up_before_script() {
    source bin/git-forgit

    # Ignore global git config files
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null

    cd "$(bashunit::temp_dir)" || return 1
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"

    touch "tracked file.txt"
    touch "modified file.txt"
    git add .
    git commit -m "init" --quiet

    echo modified > "modified file.txt"

    touch "staged file.txt"
    git add "staged file.txt"

    touch "untracked_file.txt"
    touch 'untracked_with_\backslash'
 }

 function test_forgit_worktree_changes_contains_modified() {
     local output

     output=$(_forgit_worktree_changes)

     assert_contains "modified file.txt" "$output"
 }

 function test_forgit_worktree_changes_contains_untracked() {
     local output

     output=$(_forgit_worktree_changes)

     assert_contains "untracked_file.txt" "$output"
 }

 function test_forgit_worktree_changes_excludes_staged() {
     local output

     output=$(_forgit_worktree_changes)
     assert_not_contains "staged file.txt" "$output"
 }


 function test_forgit_worktree_changes_excludes_tracked() {
     local output

     output=$(_forgit_worktree_changes)

     assert_not_contains "tracked file.txt" "$output"
 }

 function test_forgit_worktree_changes_supports_backslashes() {
     local output

     output=$(_forgit_worktree_changes)

     assert_contains 'untracked_with_\backslash' "$output"
 }
