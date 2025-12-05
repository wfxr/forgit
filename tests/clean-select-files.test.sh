#!/usr/bin/env bash

function set_up_before_script() {
    source bin/git-forgit

    # create a new git repository in a temp directory
    cd "$(temp_dir)" || return 1
    git init --quiet

    # create files to test against
    touch file.txt
    touch file_with\\backslashes\\.txt
    touch "file with spaces.txt"
    touch "file_with\ttab.txt"
}

# @data_provider provider_clean_select_files
function test_forgit_clean_select_files_preview() {
    mock "fzf" "sed -n ${1}p"

    local file
    file=$(_forgit_clean_select_files)

    assert_file_exists "$file"
}

 function provider_clean_select_files() {
     data_set 1
     data_set 2
     data_set 3
     data_set 4
 }
