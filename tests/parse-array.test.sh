#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit
}

# Asserts that _forgit_parse_array splits the given input string into exactly
# the expected elements.
#
# Usage: assert_parsed_array <input> [expected_element...]
#   <input>             the raw string passed to _forgit_parse_array
#   [expected_element]  zero or more elements the input should split into,
#                       typically passed by expanding an array: "${expected[@]}"
function assert_parsed_array() {
    local -r input="$1"
    shift
    local -r expected=("$@")
    local -a actual=()
    _forgit_parse_array actual "$input"

    assert_same "${#expected[@]}" "${#actual[@]}"

    local i
    for i in "${!expected[@]}"; do
        assert_same "${expected[i]}" "${actual[i]}"
    done
}

function test_forgit_parse_array_splits_space_separated_values() {
    local -r input="--foo --bar"
    local -r expected=("--foo" "--bar")
    assert_parsed_array "$input" "${expected[@]}"
}

function test_forgit_parse_array_keeps_single_value() {
    local -r input="--force"
    local -r expected=("--force")
    assert_parsed_array "$input" "${expected[@]}"
}

function test_forgit_parse_array_empty_string_yields_no_elements() {
    local -r input=""
    local -r expected=()
    assert_parsed_array "$input" "${expected[@]}"
}

function test_forgit_parse_array_ignores_surrounding_newlines() {
    local -r input="
    --force
"
    local -r expected=("--force")
    assert_parsed_array "$input" "${expected[@]}"
}

function test_forgit_parse_array_splits_values_across_indented_lines() {
    local -r input="
    --foo
    --bar
"
    local -r expected=("--foo" "--bar")
    assert_parsed_array "$input" "${expected[@]}"
}

function test_forgit_parse_array_splits_on_tabs() {
    local -r input=$'\t--foo\t\t--bar\t'
    local -r expected=("--foo" "--bar")
    assert_parsed_array "$input" "${expected[@]}"
}

function test_forgit_parse_array_whitespace_only_yields_no_elements() {
    local -r input="
    "
    local -r expected=()
    assert_parsed_array "$input" "${expected[@]}"
}
