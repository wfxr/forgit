#!/usr/bin/env bash

FORGIT_REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

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

    echo modified >"modified file.txt"

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

function test_forgit_build_status_entries_uses_cwd_relative_display_paths_within_subdirectories() {
    local output

    mkdir -p dir
    touch dir/file.txt
    cd dir || return 1

    output=$(_forgit_worktree_changes)

    assert_contains "file.txt" "$output"
}

function test_forgit_build_status_entries_prefixes_parent_paths_for_entries_outside_cwd() {
    local output

    mkdir -p dir other
    touch other/file.txt
    cd dir || return 1

    output=$(_forgit_worktree_changes)

    assert_contains "../other/file.txt" "$output"
}

function test_forgit_build_status_entries_keeps_repo_relative_paths_at_repo_root() {
    local output

    mkdir -p dir
    touch dir/file.txt

    output=$(_forgit_worktree_changes)

    assert_contains "dir/file.txt" "$output"
}

function test_forgit_build_status_entries_uses_cwd_relative_display_paths_for_sibling_entries() {
    local output

    mkdir -p dir1 dir2
    touch dir1/file.txt
    cd dir2 || return 1

    output=$(_forgit_worktree_changes)

    assert_contains "../dir1/file.txt" "$output"
}

function test_forgit_build_status_entries_uses_cwd_relative_display_paths_from_logical_symlink_paths() {
    local output sandbox

    sandbox=$(bashunit::temp_dir)
    mkdir -p "$sandbox/real/dir1" "$sandbox/real/dir2"
    (
        cd "$sandbox/real" || exit 1
        git init --quiet
        git config user.name "Test User"
        git config user.email "test@example.com"
    ) || return 1
    ln -s "$sandbox/real" "$sandbox/link"
    cd "$sandbox/link/dir2" || return 1
    touch ../dir1/file.txt

    output=$(_forgit_worktree_changes)

    assert_contains "../dir1/file.txt" "$output"
}

function test_forgit_worktree_changes_emits_absolute_payloads_for_subdir_entries() {
    local output rootdir

    mkdir dir
    touch 'dir/with_\backslash'
    cd dir || return 1

    output=$(_forgit_worktree_changes)
    rootdir=$(git rev-parse --show-toplevel)

    assert_contains $'with_\\backslash'"$_ffsep""$rootdir/dir/with_\\backslash" "$output"
}

function test_forgit_restore_untracked_color_colorizes_plain_untracked_lines() {
    local output

    output=$(printf '?? plain.txt\n' | _forgit_restore_untracked_color '<u>' '<r>')

    assert_same '<u>??<r> plain.txt' "$output"
}

function test_forgit_restore_untracked_color_leaves_colored_lines_unchanged() {
    local colored output

    colored=$'\033[33m??\033[m plain.txt'
    output=$(printf '%s\n' "$colored" | _forgit_restore_untracked_color '<u>' '<r>')

    assert_same "$colored" "$output"
}

function test_forgit_worktree_changes_preserves_special_characters_in_payload() {
    local output path rootdir

    path=$'tab\t space \\ name.txt'
    touch "$path"
    rootdir=$(git rev-parse --show-toplevel)

    output=$(_forgit_worktree_changes)

    assert_contains "${path}${_ffsep}${rootdir}/${path}" "$output"
}

function test_forgit_fzf_separator_does_not_use_literal_tabs() {
    local delimiter

    delimiter=$_ffsep

    assert_not_contains $'\t' "$delimiter"
}

function test_forgit_worktree_changes_works_in_zsh() {
    local output

    output=$(
        zsh -c '
             source "'"$FORGIT_REPO_ROOT"'/bin/git-forgit"
             cd "$(mktemp -d)" || exit 1
             git init --quiet
             touch "space name.txt" "back\\slash.txt" $'"'"'tab\tname.txt'"'"'
             _forgit_worktree_changes
         '
    )

    assert_contains 'space name.txt' "$output"
    assert_contains 'back\slash.txt' "$output"
    assert_contains 'tab' "$output"
}
