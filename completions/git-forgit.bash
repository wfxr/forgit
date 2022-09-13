# forgit completions for bash

# When using forgit as a subcommand of git, put this file in one of the
# following places and it will be loaded automatically on tab completion of
# 'git forgit' or any configured git aliases of it:
#
#   /usr/share/bash-completion/completions
#   ~/.local/share/bash-completion/completions

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
