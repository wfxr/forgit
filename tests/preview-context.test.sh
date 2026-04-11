#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
    FORGIT="bin/git-forgit"

    # Ignore global git config files
    export GIT_CONFIG_SYSTEM=/dev/null
    export GIT_CONFIG_GLOBAL=/dev/null

    cd "$(bashunit::temp_dir)" || return 1
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    touch tracked.txt
    git add tracked.txt
    git commit -m "init" --quiet
}

function test_forgit_pager_uses_preview_pager_only_in_explicit_preview_context() {
    local without_marker with_marker

    without_marker=$(
        FORGIT_DIFF_PAGER="printf diff" \
            FORGIT_PREVIEW_PAGER="printf preview" \
            FZF_PREVIEW_COLUMNS=80 \
            _forgit_pager diff
    )
    with_marker=$(
        FORGIT_DIFF_PAGER="printf diff" \
            FORGIT_PREVIEW_PAGER="printf preview" \
            FORGIT_IN_PREVIEW=1 \
            _forgit_pager diff
    )

    assert_same "diff" "$without_marker"
    assert_same "preview" "$with_marker"
}

function _forgit_capture_preview_flag() {
    printf '%s' "${FORGIT_IN_PREVIEW:-unset}"
}

function test_forgit_preview_wrapper_marks_preview_context() {
    local actual

    actual=$(_forgit_preview capture_preview_flag 2>/dev/null || true)

    assert_same "1" "$actual"
}

function test_forgit_diff_preview_command_uses_preview_wrapper() {
    bashunit::mock "fzf" 'printf "%s" "$FZF_DEFAULT_OPTS"'

    local output
    output=$(_forgit_diff)

    assert_contains "--preview=\"$FORGIT preview diff_view {}" "$output"
}

function test_forgit_show_preview_command_uses_preview_wrapper() {
    bashunit::mock "fzf" 'printf "%s" "$FZF_DEFAULT_OPTS"'

    local output
    output=$(_forgit_show HEAD)

    assert_contains "--preview=\"$FORGIT preview show_preview {}" "$output"
}
