# Repository Guidelines

## Project Structure & Module Organization

`forgit` is a shell-based Git helper, so most changes land in a small set of files:

- `bin/git-forgit`: core command implementations and shared helper functions.
- `forgit.plugin.zsh`: main plugin entry point for Zsh and Bash. `forgit.plugin.sh` is a symlink to it.
- `conf.d/forgit.plugin.fish`: Fish integration.
- `completions/`: shell completion files for Zsh, Bash, and Fish.
- `tests/*.test.sh`: Bashunit coverage for helpers and command behavior.
- `README.md` and `CONTRIBUTING.md`: user-facing docs and contributor workflow notes.

When you add or rename a command, update the implementation, shell wrappers, completions, tests, and docs together.

## Build, Test, and Development Commands

There is no build step; validation is command-driven.

- `shellcheck forgit.plugin.sh bin/git-forgit`: lint the shared shell sources.
- `lib/bashunit .`: run the full test suite in `tests/`.
- `bash forgit.plugin.sh`: verify Bash compatibility.
- `zsh forgit.plugin.zsh`: verify Zsh compatibility.
- `fish conf.d/forgit.plugin.fish`: verify Fish compatibility.

CI runs these checks on macOS and Ubuntu. Keep local validation aligned with that workflow before opening a PR.

## Coding Style & Naming Conventions

Follow `.editorconfig`: UTF-8, LF endings, spaces for indentation, width 4, and no trailing whitespace. Match the existing shell style: prefer small helper functions, `local` variables inside functions, and descriptive private names such as `_forgit_extract_branch_name`. Keep command aliases and completion names consistent across shells.

## Testing Guidelines

Tests use Bashunit and live in `tests/*.test.sh`. Name new files after the behavior under test, such as `worktree.test.sh` or `checkout.test.sh`. Source `bin/git-forgit` in tests and exercise helpers directly when possible. Add or update tests for behavior changes, especially parsing, selection, and cross-shell integration.

## Commit & Pull Request Guidelines

Git history follows Conventional Commits: `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`, and occasional scoped forms like `style(docs): ...`. Write messages around the behavior change and its reason, not just the implementation detail.

Use the PR template. Before submitting, perform a self-review, update docs for user-visible changes, add tests when behavior changes, and report the shells and operating systems you verified.
