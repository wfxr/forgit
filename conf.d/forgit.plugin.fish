# MIT (c) Chris Apple

set INSTALL_DIR (dirname (dirname (status -f)))
set -x FORGIT_INSTALL_DIR "$INSTALL_DIR/conf.d"
set -x FORGIT "$FORGIT_INSTALL_DIR/bin/git-forgit"
if [ ! -e "$FORGIT" ]
    set -x FORGIT_INSTALL_DIR "$INSTALL_DIR/vendor_conf.d"
    set -x FORGIT "$FORGIT_INSTALL_DIR/bin/git-forgit"
end

function forgit::warn
    printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$argv" >&2
end

# backwards compatibility:
# export all user-defined FORGIT variables to make them available in git-forgit
set unexported_vars 0
set | awk -F ' ' '{ print $1 }' | grep FORGIT_ | while read var
    if not set -x | grep -q "^$var\b"
        if test $unexported_vars = 0
            forgit::warn "Config options have to be exported in future versions of forgit."
            forgit::warn "Please update your config accordingly:"
        end
        forgit::warn "  set -x $var \"$$var\""
        set unexported_vars (math $unexported_vars + 1)
        set -x $var $$var
    end
end

function forgit::log -d "git commit viewer"
    "$FORGIT" log $argv
end

function forgit::diff -d "git diff viewer" --argument-names arg1 arg2
    "$FORGIT" diff $argv
end

function forgit::add -d "git add selector" --wraps "git add"
    "$FORGIT" add $argv
end

function forgit::reset::head -d "git reset HEAD (unstage) selector"
    "$FORGIT" reset_head $argv
end

function forgit::stash::show -d "git stash viewer"
    "$FORGIT" stash_show $argv
end

function forgit::stash::push -d "git stash push selector" ()
    "$FORGIT" stash_push $argv
end

function forgit::clean -d "git clean selector"
    "$FORGIT" clean $argv
end

function forgit::cherry::pick -d "git cherry-picking" --argument-names 'target' --wraps "git cherry-pick"
    "$FORGIT" cherry_pick $argv
end

function forgit::cherry::pick::from::branch -d "git cherry-picking with interactive branch selection" --wraps "git cherry-pick"
    "$FORGIT" cherry_pick_from_branch $argv
end

function forgit::rebase -d "git rebase"
    "$FORGIT" rebase $argv
end

function forgit::fixup -d "git fixup"
    "$FORGIT" fixup $argv
end

function forgit::checkout::file -d "git checkout-file selector" --argument-names 'file_name' --wraps "git checkout --"
    "$FORGIT" checkout_file $argv
end

function forgit::checkout::branch -d "git checkout branch selector" --argument-names 'input_branch_name' --wraps "git branch"
    "$FORGIT" checkout_branch $argv
end

function forgit::checkout::tag -d "git checkout tag selector" --argument-names 'tag_name' --wraps "git checkout"
    "$FORGIT" checkout_tag $argv
end

function forgit::checkout::commit -d "git checkout commit selector" --argument-names 'commit_id' --wraps "git checkout"
    "$FORGIT" checkout_commit $argv
end

function forgit::branch::delete -d "git branch deletion selector" --wraps "git branch --delete"
    "$FORGIT" branch_delete $argv
end

function forgit::revert::commit -d "git revert commit selector" --argument-names 'commit_hash' --wraps "git revert --"
    "$FORGIT" revert_commit $argv
end

function forgit::blame -d "git blame viewer"
    "$FORGIT" blame $argv
end

function forgit::ignore -d "git ignore generator"
    "$FORGIT" ignore $argv
end

function forgit::ignore::update
    "$FORGIT" ignore_update $argv
end

function forgit::ignore::get
    "$FORGIT" ignore_get $argv
end

function forgit::ignore::list
    "$FORGIT" ignore_list $argv
end

function forgit::ignore::clean
    "$FORGIT" ignore_clean $argv
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

    if test -n "$forgit_stash_push"
        alias $forgit_stash_push 'forgit::stash::push'
    else
        alias gsp 'forgit::stash::push'
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

    if test -n "$forgit_blame"
        alias $forgit_blame 'forgit::blame'
    else
        alias gbl 'forgit::blame'
    end

    if test -n "$forgit_checkout_tag"
        alias $forgit_checkout_tag 'forgit::checkout::tag'
    else
        alias gct 'forgit::checkout::tag'
    end

end
