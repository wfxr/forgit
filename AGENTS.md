# Repository Guidelines

## Project Structure & Module Organization

- `bin/git-forgit`: main implementation (Bash) for `git forgit <subcommand>`.
- `forgit.plugin.zsh` (`forgit.plugin.sh` symlink): Bash/Zsh plugin that registers `forgit::*` functions and user-facing aliases (e.g. `ga`, `glo`).
- `conf.d/forgit.plugin.fish`: Fish integration.
- `completions/`: shell completion scripts (`_git-forgit`, `git-forgit.bash`, `git-forgit.fish`).
- `tests/`: bashunit tests (`*.test.sh`).
- `.github/`: CI workflow and PR template.

## Build, Test, and Development Commands

There is no build step; changes ship as shell scripts. Runtime expects `fzf >= 0.49.0`.

Run the same checks CI runs (from repo root):

```sh
shellcheck forgit.plugin.sh bin/git-forgit

# Install bashunit to ./lib/bashunit (matches .github/workflows/ci.yaml)
curl -s https://bashunit.typeddevs.com/install.sh | bash -s beta
lib/bashunit .

# Smoke-test supported shells
bash forgit.plugin.sh
zsh  forgit.plugin.zsh
fish conf.d/forgit.plugin.fish
```

Optional: `pre-commit run -a` (note: the `update-license` hook refreshes `LICENSE` via `curl`).

## Coding Style & Naming Conventions

- Follow `.editorconfig`: LF, trim trailing whitespace, 4-space indents.
- Keep scripts ShellCheck-clean; in `forgit.plugin.zsh` prefer explicit `command`/`builtin` to avoid user aliases shadowing common tools.
- Naming patterns:
  - Internal helpers: `_forgit_*` (primarily in `bin/git-forgit`).
  - Public entry points: `forgit::*` functions and short aliases.
  - Tests: `tests/*.test.sh` with `test_*` functions.

## Testing Guidelines

Tests use [bashunit](https://bashunit.typeddevs.com/). Add unit tests for parsing helpers and regressions, and validate behavior in bash + zsh (plugin code is shared). If you touch completions, verify the corresponding files in `completions/`.

## Commit & Pull Request Guidelines

- Commit subjects commonly follow `Type: summary` (e.g. `Fix: ...`, `Feat: ...`, `Docs: ...`, `Refactor: ...`, `Chore: ...`, `Meta: ...`), sometimes with a scope (e.g. `Chore(deps): ...`).
- PRs should follow `.github/pull_request_template.md`: clear description, relevant tests checked (bash/zsh/fish), and docs updates for user-facing changes. Include screenshots/GIFs when changing interactive UX.
