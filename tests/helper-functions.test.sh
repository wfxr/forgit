#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
}

# @data_provider provider_diff_lines
function test_forgit_get_files_from_diff_line() {
    local -r input="$1"
    shift
    local -r expected=("$@")
    local -a actual=()
    local i

    while IFS= read -r line; do
        actual+=( "$line" )
    done < <( echo -n "$input" | _forgit_get_files_from_diff_line | xargs -0 -n 1 echo )

    # Compare array sizes
    assert_same "${#expected[@]}" "${#actual[@]}"

    # Compare array elements
    for i in "${!expected[@]}"; do
        assert_same "${expected[i]}" "${actual[i]}"
    done
}

function provider_diff_lines() {
    bashunit::data_set "[A]     newfile" "newfile"
    bashunit::data_set "[D]     oldfile with spaces" "oldfile with spaces"
    bashunit::data_set "[R100]  file  ->  another file" "file" "another file"
    bashunit::data_set "[M]     \"file with\ttab.txt\"" "\"file with\ttab.txt\""
}
