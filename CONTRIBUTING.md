Contributing to forgit
======================

Thanks for your interest in contributing to `forgit`.

This document covers the repository-specific workflow for reporting issues and opening pull requests.
For installation, usage, commands, and configuration, see [README.md](README.md).

Before You Start
----------------

Before opening an issue or pull request, please make sure that you:

- read through [README.md](README.md)
- use the latest released version of `forgit`
- search existing issues and pull requests for duplicates

Repository Map
--------------

These are the main places you will usually need to touch:

- [`bin/git-forgit`](bin/git-forgit): core command implementations
- [`forgit.plugin.zsh`](forgit.plugin.zsh): shared shell plugin for zsh and bash
- [`conf.d/forgit.plugin.fish`](conf.d/forgit.plugin.fish): fish plugin integration
- [`completions/`](completions): tab completions for zsh, bash, and fish
- [`tests/`](tests): [bashunit](https://bashunit.typeddevs.com/) test suite

Making Changes
--------------

When changing or adding behavior, prefer to follow existing command patterns already used in the repository.

If you add a new command or rename an existing one, update all affected layers together:

- the core implementation in `bin/git-forgit`
- shell wrappers, aliases, or abbreviations in [`forgit.plugin.zsh`](forgit.plugin.zsh) and [`forgit.plugin.fish`](conf.d/forgit.plugin.fish)
- completions for zsh, bash, and fish
- user-facing documentation in [README.md](README.md)

Please keep changes focused. Small pull requests are easier to review and usually get merged faster.

When possible, keep core logic testable by sourcing `bin/git-forgit` directly and calling helper functions from unit tests.

Development Dependencies
------------------------

To run the same checks as CI, make sure these tools are available locally:

- `bash`, `zsh`, and `fish`
- `shellcheck`
- `curl`
- `bashunit` as `lib/bashunit`
- `shfmt`
- `rumdl`
- `actionlint`

If `lib/bashunit` is not available yet, install it once with:

```sh
curl -s https://bashunit.typeddevs.com/install.sh | bash -s 0.31.0
```

Local Validation
----------------

Before opening a pull request, run the checks that match the current CI workflow:

```sh
shellcheck forgit.plugin.sh bin/git-forgit
lib/bashunit .
bash forgit.plugin.sh
zsh forgit.plugin.zsh
fish conf.d/forgit.plugin.fish
shfmt --write .
rumdl check .
actionlint
```

In your pull request, report which shells and operating systems you tested.

Commit Messages
---------------

This repository uses [Conventional Commits](https://www.conventionalcommits.org), and pull requests are checked accordingly in CI.

Common examples include:

- `feat`: new features
- `fix`: bug fixes
- `docs`: documentation changes
- `style`: formatting-only changes
- `refactor`: code changes that neither fix a bug nor add a feature
- `test`: test additions or updates
- `chore`: maintenance work
- `perf`: performance improvements
- `ci`: CI or automation changes

Scopes can optionally clarify which part of the project changed (e.g., `fix(diff)`); keep them short and relevant.

Use commit messages to explain:

- what changed
- why the change is needed

Do not focus the commit message on implementation mechanics unless that detail is important to understand the change.

Good examples:

```text
fix: keep worktree add rooted at the main worktree

Adding from a linked worktree created nested .wt directories in the current
worktree. Keep new worktrees rooted at the main worktree so the default target
location stays consistent.
```

```text
docs: add contributor workflow guide

Document the repository-specific review, testing, and completion update
expectations so new contributors do not have to infer them from old issues.
```

Pull Requests
-------------

Before submitting a pull request, make sure that you:

- perform a self-review
- add comments where the code is hard to understand
- add or update unit tests when behavior changes
- update documentation when the change is user-visible
- summarize the pull request in terms of what changed and why

Please use the pull request description to give reviewers the context they need.
A short explanation of the approach is useful, but the main focus should be the behavior change and its motivation.

Maintainers
-----------

- [@wfxr](https://github.com/wfxr)
- [@cjappl](https://github.com/cjappl)
- [@carlfriedrich](https://github.com/carlfriedrich)
- [@sandr01d](https://github.com/sandr01d)
