# git cherry-picking
function forgit::cherry::pick
    forgit::inside_work_tree || return 1
    set base (git branch --show-current)
    if not count $argv > /dev/null
        echo "Please specify target branch"
        return 1
    end
    set target $argv[1]
    set preview "echo {1} | xargs -I% git show --color=always % | $forgit_show_pager"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
    "
    echo $base
    echo $target
    git cherry "$base" "$target" --abbrev -v | cut -d ' ' -f2- |
        env FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" | cut -d' ' -f1 |
        xargs -I% git cherry-pick %
end
