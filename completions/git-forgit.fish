#
# forgit completions for fish plugin
#
# Place this file inside your <fish_config_dir>/completions/ directory.
# It's usually located at ~/.config/fish/completions/. The file is lazily
# sourced when git-forgit command or forgit subcommand of git is invoked.

function __fish_forgit_needs_subcommand
    for subcmd in add blame branch_delete checkout_branch checkout_commit checkout_file checkout_tag \
        cherry_pick cherry_pick_from_branch clean diff fixup ignore log reflog rebase reset_head \
        revert_commit reword squash stash_show stash_push worktree_select worktree_lock \
        worktree_remove worktree_unlock
        if contains -- $subcmd (commandline -opc)
            return 1
        end
    end
    return 0
end

# Load helper functions in git completion file
not functions -q __fish_git && source $__fish_data_dir/completions/git.fish

# No file completion by default
complete -c git-forgit -x

complete -c git-forgit -n __fish_forgit_needs_subcommand -a add -d 'git add selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a blame -d 'git blame viewer'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a branch_delete -d 'git branch deletion selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a checkout_branch -d 'git checkout branch selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a checkout_commit -d 'git checkout commit selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a checkout_file -d 'git checkout-file selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a checkout_tag -d 'git checkout tag selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a cherry_pick -d 'git cherry-picking'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a cherry_pick_from_branch -d 'git cherry-picking with interactive branch selection'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a clean -d 'git clean selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a diff -d 'git diff viewer'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a fixup -d 'git fixup'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a ignore -d 'git ignore generator'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a log -d 'git commit viewer'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a reflog -d 'git reflog viewer'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a rebase -d 'git rebase'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a reset_head -d 'git reset HEAD (unstage) selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a revert_commit -d 'git revert commit selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a reword -d 'git fixup=reword'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a show -d 'git show viewer'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a squash -d 'git squash'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a stash_show -d 'git stash viewer'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a stash_push -d 'git stash push selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a worktree_select -d 'git worktree selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a worktree_lock -d 'git worktree lock selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a worktree_remove -d 'git worktree remove selector'
complete -c git-forgit -n __fish_forgit_needs_subcommand -a worktree_unlock -d 'git worktree unlock selector'

complete -c git-forgit -n '__fish_seen_subcommand_from add' -a "(complete -C 'git add ')"
complete -c git-forgit -n '__fish_seen_subcommand_from branch_delete' -a "(__fish_git_local_branches)"
complete -c git-forgit -n '__fish_seen_subcommand_from checkout_branch' -a "(complete -C 'git switch ')"
complete -c git-forgit -n '__fish_seen_subcommand_from checkout_commit' -a "(__fish_git_commits)"
complete -c git-forgit -n '__fish_seen_subcommand_from checkout_file' -a "(__fish_git_files modified)"
complete -c git-forgit -n '__fish_seen_subcommand_from checkout_tag' -a "(__fish_git_tags)" -d Tag
complete -c git-forgit -n '__fish_seen_subcommand_from cherry_pick' -a "(complete -C 'git cherry-pick ')"
complete -c git-forgit -n '__fish_seen_subcommand_from clean' -a "(__fish_git_files untracked ignored)"
complete -c git-forgit -n '__fish_seen_subcommand_from diff' -a "(complete -C 'git diff ')"
complete -c git-forgit -n '__fish_seen_subcommand_from fixup' -a "(complete -C 'git log ')"
complete -c git-forgit -n '__fish_seen_subcommand_from log' -a "(complete -C 'git log ')"
complete -c git-forgit -n '__fish_seen_subcommand_from reflog' -a "(complete -C 'git reflog ')"
complete -c git-forgit -n '__fish_seen_subcommand_from rebase' -a "(complete -C 'git rebase ')"
complete -c git-forgit -n '__fish_seen_subcommand_from reset_head' -a "(__fish_git_files all-staged)"
complete -c git-forgit -n '__fish_seen_subcommand_from revert_commit' -a "(__fish_git_commits)"
complete -c git-forgit -n '__fish_seen_subcommand_from reword' -a "(complete -C 'git log ')"
complete -c git-forgit -n '__fish_seen_subcommand_from show' -a "(complete -C 'git show ')"
complete -c git-forgit -n '__fish_seen_subcommand_from squash' -a "(complete -C 'git log ')"
complete -c git-forgit -n '__fish_seen_subcommand_from stash_show' -a "(__fish_git_complete_stashes)"
complete -c git-forgit -n '__fish_seen_subcommand_from stash_push' -a "(__fish_git_files modified deleted modified-staged-deleted)"
complete -c git-forgit -n '__fish_seen_subcommand_from worktree_select' -a "(__fish_git_complete_worktrees)"
complete -c git-forgit -n '__fish_seen_subcommand_from worktree_lock' -a "(complete -C 'git worktree lock ')"
complete -c git-forgit -n '__fish_seen_subcommand_from worktree_remove' -a "(complete -C 'git worktree remove ')"
complete -c git-forgit -n '__fish_seen_subcommand_from worktree_unlock' -a "(complete -C 'git worktree unlock ')"
