# MIT (c) Chris Apple

set -l install_dir (dirname (status dirname))
set -x FORGIT_INSTALL_DIR "$install_dir/conf.d"
set -x FORGIT "$FORGIT_INSTALL_DIR/bin/git-forgit"
if not test -e "$FORGIT"
    set -x FORGIT_INSTALL_DIR "$install_dir/vendor_conf.d"
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

# alias `git-forgit` to the full-path of the command
alias git-forgit "$FORGIT"

# register abbreviations
if test -z "$FORGIT_NO_ALIASES"
    abbr -a -- (string collect $forgit_add; or string collect "ga") git-forgit add
    abbr -a -- (string collect $forgit_reset_head; or string collect "grh") git-forgit reset_head
    abbr -a -- (string collect $forgit_log; or string collect "glo") git-forgit log
    abbr -a -- (string collect $forgit_reflog; or string collect "grl") git-forgit reflog
    abbr -a -- (string collect $forgit_diff; or string collect "gd") git-forgit diff
    abbr -a -- (string collect $forgit_ignore; or string collect "gi") git-forgit ignore
    abbr -a -- (string collect $forgit_checkout_file; or string collect "gcf") git-forgit checkout_file
    abbr -a -- (string collect $forgit_checkout_branch; or string collect "gcb") git-forgit checkout_branch
    abbr -a -- (string collect $forgit_branch_delete; or string collect "gbd") git-forgit branch_delete
    abbr -a -- (string collect $forgit_clean; or string collect "gclean") git-forgit clean
    abbr -a -- (string collect $forgit_stash_show; or string collect "gss") git-forgit stash_show
    abbr -a -- (string collect $forgit_stash_push; or string collect "gsp") git-forgit stash_push
    abbr -a -- (string collect $forgit_cherry_pick; or string collect "gcp") git-forgit cherry_pick_from_branch
    abbr -a -- (string collect $forgit_rebase; or string collect "grb") git-forgit rebase
    abbr -a -- (string collect $forgit_fixup; or string collect "gfu") git-forgit fixup
    abbr -a -- (string collect $forgit_checkout_commit; or string collect "gco") git-forgit checkout_commit
    abbr -a -- (string collect $forgit_revert_commit; or string collect "grc") git-forgit revert_commit
    abbr -a -- (string collect $forgit_blame; or string collect "gbl") git-forgit blame
    abbr -a -- (string collect $forgit_checkout_tag; or string collect "gct") git-forgit checkout_tag
end
