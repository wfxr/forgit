#!/bin/zsh
#
# forgit completions for zsh plugin
#
# When using forgit via the shell plugin, place completions/_git-forgit in your
# $fpath (e.g. /usr/share/zsh/site-functions) and source this file after
# forgit.plugin.zsh to enable tab completion for shell functions and aliases.

# Check if forgit plugin is loaded
if (( $+functions[forgit::add] )); then
	# We're reusing existing completion functions, so load those first
	# if not already loaded and check if completion function exists afterwards.
	(( $+functions[_git-add] )) || _git
	(( $+functions[_git-add] )) || return 1
	(( $+functions[_git-branches] )) || _git-forgit
	(( $+functions[_git-branches] )) || return 1
	# Completions for forgit plugin shell functions (also works for aliases)
	compdef _git-add forgit::add
	compdef _git-branches forgit::branch::delete
	compdef _git-branches forgit::checkout::branch
	compdef __git_recent_commits forgit::checkout::commit
	compdef _git-checkout-file forgit::checkout::file
	compdef __git_tags forgit::checkout::tag
	compdef _git-cherry-pick forgit::cherry::pick
	compdef _git-branches forgit::cherry::pick::from::branch
	compdef _git-clean forgit::clean
	compdef _git-forgit-diff forgit::diff
	compdef __git_branch_names forgit::fixup
	compdef _git-log forgit::log
	compdef _git-rebase forgit::rebase
	compdef _git-staged forgit::reset::head
	compdef __git_recent_commits forgit::revert::commit
	compdef _git-stash-show forgit::stash::show
fi
