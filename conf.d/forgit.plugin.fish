# MIT (c) Chris Apple

set -g FORGIT_INSTALL_DIR (dirname (dirname (status -f)))

function forgit::log -d "git commit viewer"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" log "$argv"
end

function forgit::diff -d "git diff viewer" --argument-names arg1 arg2
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" diff "$argv"
end

function forgit::add -d "git add selector" --wraps "git add"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" add "$argv"
end

function forgit::reset::head -d "git reset HEAD (unstage) selector"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" reset_head "$argv"
end

function forgit::stash::show -d "git stash viewer"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" stash_show "$argv"
end

function forgit::clean -d "git clean selector"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" clean "$argv"
end

function forgit::cherry::pick -d "git cherry-picking" --argument-names 'target' --wraps "git cherry-pick"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" cherry_pick "$argv"
end

function forgit::cherry::pick::from::branch -d "git cherry-picking with interactive branch selection"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" cherry_pick_from_branch "$argv"
end

function forgit::rebase -d "git rebase"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" rebase "$argv"
end

function forgit::fixup -d "git fixup"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" fixup "$argv"
end

function forgit::checkout::file -d "git checkout-file selector" --argument-names 'file_name' --wraps "git checkout --"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" checkout_file "$argv"
end

function forgit::checkout::branch -d "git checkout branch selector" --argument-names 'input_branch_name' --wraps "git branch"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" checkout_branch "$argv"
end

function forgit::checkout::tag -d "git checkout tag selector" --argument-names 'tag_name' --wraps "git checkout"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" checkout_tag "$argv"
end

function forgit::checkout::commit -d "git checkout commit selector" --argument-names 'commit_id' --wraps "git checkout"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" checkout_commit "$argv"
end

function forgit::branch::delete -d "git checkout branch deleter" --wraps "git branch --delete"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" branch_delete "$argv"
end

function forgit::revert::commit --argument-names 'commit_hash' --wraps "git revert --"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" revert_commit "$argv"
end

function forgit::blame
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" blame "$argv"
end

function forgit::ignore -d "git ignore generator"
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" ignore "$argv"
end

function forgit::ignore::update
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" ignore_update "$argv"
end

function forgit::ignore::get
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" ignore_get "$argv"
end

function forgit::ignore::list
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" ignore_list "$argv"
end

function forgit::ignore::clean
    "$FORGIT_INSTALL_DIR/conf.d/bin/git-forgit" ignore_clean "$argv"
end

# register aliases
if test -z "$FORGIT_NO_ALIASES"
    if test -n "$forgit_add"
        alias $forgit_add 'forgit::add'
    else
        alias ga 'forgit::add'
    end

    if test -n "$forgit_reset_head"
        alias $forgit_reset_head 'forgit::reset::head'
    else
        alias grh 'forgit::reset::head'
    end

    if test -n "$forgit_log"
        alias $forgit_log 'forgit::log'
    else
        alias glo 'forgit::log'
    end

    if test -n "$forgit_diff"
        alias $forgit_diff 'forgit::diff'
    else
        alias gd 'forgit::diff'
    end

    if test -n "$forgit_ignore"
        alias $forgit_ignore 'forgit::ignore'
    else
        alias gi 'forgit::ignore'
    end

    if test -n "$forgit_checkout_file"
        alias $forgit_checkout_file 'forgit::checkout::file'
    else
        alias gcf 'forgit::checkout::file'
    end

    if test -n "$forgit_checkout_branch"
        alias $forgit_checkout_branch 'forgit::checkout::branch'
    else
        alias gcb 'forgit::checkout::branch'
    end

    if test -n "$forgit_branch_delete"
        alias $forgit_branch_delete 'forgit::branch::delete'
    else
        alias gbd 'forgit::branch::delete'
    end


    if test -n "$forgit_clean"
        alias $forgit_clean 'forgit::clean'
    else
        alias gclean 'forgit::clean'
    end

    if test -n "$forgit_stash_show"
        alias $forgit_stash_show 'forgit::stash::show'
    else
        alias gss 'forgit::stash::show'
    end

    if test -n "$forgit_cherry_pick"
        alias $forgit_cherry_pick 'forgit::cherry::pick::from::branch'
    else
        alias gcp 'forgit::cherry::pick::from::branch'
    end

    if test -n "$forgit_rebase"
        alias $forgit_rebase 'forgit::rebase'
    else
        alias grb 'forgit::rebase'
    end

    if test -n "$forgit_fixup"
        alias $forgit_fixup 'forgit::fixup'
    else
        alias gfu 'forgit::fixup'
    end

    if test -n "$forgit_checkout_commit"
        alias $forgit_checkout_commit 'forgit::checkout::commit'
    else
        alias gco 'forgit::checkout::commit'
    end

    if test -n "$forgit_revert_commit"
        alias $forgit_revert_commit 'forgit::revert::commit'
    else
        alias grc 'forgit::revert::commit'
    end

end
