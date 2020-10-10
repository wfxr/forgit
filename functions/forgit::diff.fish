## git diff viewer
function forgit::diff -d "git diff viewer"
    forgit::inside_work_tree || return 1
    if count $argv > /dev/null
        if git rev-parse "$1" > /dev/null 2>&1
            #set commit "$1" && set files ("${@:2}")
            set commit "$1" && set files "$2"
        else
            set files "$argv"
        end
    end

    set repo (git rev-parse --show-toplevel)
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        +m -0 --bind=\"enter:execute($cmd |env LESS='-R' less)\"
        $FORGIT_DIFF_FZF_OPTS
    "

    set cmd "echo {} |sed 's/.*]  //' | xargs -I% git diff --color=always $commit -- '$repo/%' | $forgit_diff_pager"

    eval "git diff --name-only $commit -- $files*| sed -E 's/^(.)[[:space:]]+(.*)\$/[\1]  \2/'" | env FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd"
end
