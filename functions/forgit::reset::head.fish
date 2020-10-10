## git reset HEAD (unstage) selector
function forgit::reset::head -d "git reset HEAD (unstage) selector"
    forgit::inside_work_tree || return 1
    set cmd "git diff --cached --color=always -- {} | $forgit_diff_pager"
    set opts "
        $FORGIT_FZF_DEFAULT_OPTS
        -m -0
        $FORGIT_RESET_HEAD_FZF_OPTS
    "
    set files (git diff --cached --name-only --relative | env FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd")
    if test -n "$files"
        for file in $files
            echo $file | tr '\n' '\0' |xargs -I{} -0 git reset -q HEAD {}
        end
        git status --short
        return
    end
    echo 'Nothing to unstage.'
end
