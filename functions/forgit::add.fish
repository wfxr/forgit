# git add selector
function forgit::add -d "git add selector"
    forgit::inside_work_tree || return 1
    # Add files if passed as arguments
    count $argv >/dev/null && git add "$argv" && git status --short && return

    set changed (git config --get-color color.status.changed red)
    set unmerged (git config --get-color color.status.unmerged red)
    set untracked (git config --get-color color.status.untracked red)

    set extract_file "
        sed 's/^[[:space:]]*//' |           # remove leading whitespace
        cut -d ' ' -f 2- |                  # cut the line after the M or ??, this leaves just the filename
        sed 's/.* -> //' |                  # for rename case
        sed -e 's/^\\\"//' -e 's/\\\"\$//'  # removes surrounding quotes
    "
    set preview "
        set file (echo {} | $extract_file)
        # exit
        if test (git status -s -- \$file | grep '^??') # diff with /dev/null for untracked files
            git diff --color=always --no-index -- /dev/null \$file | $forgit_diff_pager | sed '2 s/added:/untracked:/'
        else
            git diff --color=always -- \$file | $forgit_diff_pager
        end
        "
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -0 -m --nth 2..,..
        $FORGIT_ADD_FZF_OPTS
    "
    set files (git -c color.status=always -c status.relativePaths=true status -su |
        grep -F -e "$changed" -e "$unmerged" -e "$untracked" |
        sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)\$/[\1]  \2/' |   # deal with white spaces internal to fname
        env FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" |
        sh -c "$extract_file") # for rename case

    if test -n "$files"
        for file in $files
            echo $file | tr '\n' '\0' | xargs -I{} -0 git add {}
        end
        git status --short
        return
    end
    echo 'Nothing to add.'
end
