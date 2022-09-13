# forgit completions for bash

# When using forgit as a subcommand of git, put this file in one of the
# following places and it will be loaded automatically on tab completion of
# 'git forgit' or any configured git aliases of it:
#
#   /usr/share/bash-completion/completions
#   ~/.local/share/bash-completion/completions
#
# When using forgit via the shell plugin, source this file explicitly after
# forgit.plugin.zsh to enable tab completion for shell functions and aliases.

_git_branch_delete()
{
	__gitcomp_nl "$(__git_heads)"
}

_git_checkout_branch()
{
	__gitcomp_nl "$(__git branch -a --format '%(refname:short)')"
}

_git_checkout_file()
{
	__gitcomp_nl "$(__git ls-files --modified)"
}

_git_checkout_tag()
{
	__gitcomp_nl "$(__git_tags)"
}

_git_stash_show()
{
	__gitcomp_nl "$(__git stash list | sed -n -e 's/:.*//p')"
}

# Completion for git-forgit
# This includes git aliases, e.g. "alias.cb=forgit checkout_branch" will
# correctly complete available branches on "git cb".
_git_forgit()
{
	local subcommand cword cur prev cmds

	subcommand="${COMP_WORDS[1]}"
	if [[ "$subcommand" != "forgit" ]]
	then
		# Forgit is obviously called via a git alias. Get the original
		# aliased subcommand and proceed as if it was the previous word.
		prev=$(git config --get "alias.$subcommand" | cut -d' ' -f 2)
		cword=$((${COMP_CWORD} + 1))
	else
		cword=${COMP_CWORD}
		prev=${COMP_WORDS[COMP_CWORD-1]}
	fi

	cur=${COMP_WORDS[COMP_CWORD]}

	cmds="
		add
		blame
		branch_delete
		checkout_branch
		checkout_commit
		checkout_file
		checkout_tag
		cherry_pick
		cherry_pick_from_branch
		clean
		diff
		fixup
		ignore
		log
		rebase
		reset_head
		revert_commit
		stash_show
		stash_push
	"

	case ${cword} in
		2)
			COMPREPLY=($(compgen -W "${cmds}" -- ${cur}))
			;;
		3)
			case ${prev} in
				add) _git_add ;;
				branch_delete) _git_branch_delete ;;
				checkout_branch) _git_checkout_branch ;;
				checkout_commit) _git_checkout ;;
				checkout_file) _git_checkout_file ;;
				checkout_tag) _git_checkout_tag ;;
				cherry_pick) _git_cherry_pick ;;
				cherry_pick_from_branch) _git_checkout_branch ;;
				clean) _git_clean ;;
				diff) _git_diff ;;
				fixup) _git_branch ;;
				log) _git_log ;;
				rebase) _git_rebase ;;
				reset_head) _git_reset ;;
				revert_commit) _git_revert ;;
				stash_show) _git_stash_show ;;
			esac
			;;
		*)
			COMPREPLY=()
			;;
	esac
}

# Check if forgit plugin is loaded
if [[ $(type -t forgit::add) == function ]]
then
	# We're reusing existing git completion functions, so load those first
	# and check if completion function exists afterwards.
	_completion_loader git
	[[ $(type -t __git_complete) == function ]] || return 1

	# Completion for forgit plugin shell functions
	__git_complete forgit::add _git_add
	__git_complete forgit::branch::delete _git_branch_delete
	__git_complete forgit::checkout::branch _git_checkout_branch
	__git_complete forgit::checkout::commit _git_checkout
	__git_complete forgit::checkout::file _git_checkout_file
	__git_complete forgit::checkout::tag _git_checkout_tag
	__git_complete forgit::cherry::pick _git_cherry_pick
	__git_complete forgit::cherry::pick::from::branch _git_checkout_branch
	__git_complete forgit::clean _git_clean
	__git_complete forgit::diff _git_diff
	__git_complete forgit::fixup _git_branch
	__git_complete forgit::log _git_log
	__git_complete forgit::rebase _git_rebase
	__git_complete forgit::reset::head _git_reset
	__git_complete forgit::revert::commit _git_revert
	__git_complete forgit::stash::show _git_stash_show

	# Completion for forgit plugin shell aliases
	if [[ -z "$FORGIT_NO_ALIASES" ]]; then
		__git_complete "${forgit_add}" _git_add
		__git_complete "${forgit_branch_delete}" _git_branch_delete
		__git_complete "${forgit_checkout_branch}" _git_checkout_branch
		__git_complete "${forgit_checkout_commit}" _git_checkout
		__git_complete "${forgit_checkout_file}" _git_checkout_file
		__git_complete "${forgit_checkout_tag}" _git_checkout_tag
		__git_complete "${forgit_cherry_pick}" _git_checkout_branch
		__git_complete "${forgit_clean}" _git_clean
		__git_complete "${forgit_diff}" _git_diff
		__git_complete "${forgit_fixup}" _git_branch
		__git_complete "${forgit_log}" _git_log
		__git_complete "${forgit_rebase}" _git_rebase
		__git_complete "${forgit_reset_head}" _git_reset
		__git_complete "${forgit_revert_commit}" _git_revert
		__git_complete "${forgit_stash_show}" _git_stash_show
	fi
fi
