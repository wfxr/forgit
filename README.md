<h1 align="center">💤 forgit</h1>
<p align="center">
    <em>Utility tool for using git interactively. Powered by <a href="https://github.com/junegunn/fzf">junegunn/fzf</a>.</em>
</p>

<p align="center">
    <a href="https://github.com/wfxr/forgit/actions">
        <img src="https://github.com/wfxr/forgit/workflows/ci/badge.svg"/>
    </a>
    <a href="https://wfxr.mit-license.org/2017">
        <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg"/>
    </a>
    <a href="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-blue">
        <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-blue"/>
    </a>
    <a href="https://github.com/unixorn/awesome-zsh-plugins">
        <img src="https://img.shields.io/badge/Awesome-zsh--plugins-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC"/>
    </a>
    <a href="https://github.com/pre-commit/pre-commit">
        <img src="https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white" alt="pre-commit" />
    </a>
    <a href="https://github.com/wfxr/forgit/graphs/contributors">
        <img src="https://img.shields.io/github/contributors/wfxr/forgit" alt="Contributors"/>
    </a>
</p>

This tool is designed to help you use git more efficiently.
It's **lightweight** and **easy to use**.

# 📥 Installation

*Make sure you have [`fzf`](https://github.com/junegunn/fzf) installed.*

``` zsh
# for zplug
zplug 'wfxr/forgit'

# for zgen
zgen load 'wfxr/forgit'

# for antigen
antigen bundle 'wfxr/forgit'

# for fisher (requires fisher v4.4.3 or higher)
fisher install wfxr/forgit

# for omf
omf install https://github.com/wfxr/forgit

# for zinit
zinit load wfxr/forgit

# for oh-my-zsh
git clone https://github.com/wfxr/forgit.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/forgit

# manually
# Clone the repository and source it in your shell's rc file or put bin/git-forgit into your $PATH
```

## Homebrew

To install using brew
```sh
brew install forgit
```

Then add the following to your shell's config file:
```sh
# Fish:
# ~/.config/fish/config.fish:
[ -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish ]; and source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish

# Zsh:
# ~/.zshrc:
[ -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh ] && source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh

# Bash:
# ~/.bashrc:
[ -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.sh ] && source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.sh
```

## Fig

[Fig](https://fig.io) adds apps, shortcuts, and autocomplete to your existing terminal.

Install `forgit` in just one click.

[![Install with Fig](https://fig.io/badges/install-with-fig.svg)](https://fig.io/plugins/other/forgit)

## Arch User Repository

[AUR](https://wiki.archlinux.org/title/Arch_User_Repository) packages, maintained by the developers of forgit, are available. Install the [forgit](https://aur.archlinux.org/packages/forgit) package for the latest release or [forgit-git](https://aur.archlinux.org/packages/forgit-git) to stay up to date with the latest commits from the master branch of this repository.

# 📝 Features

- **Interactive `git add` selector** (`ga`)

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/forgit-ga.png)

- **Interactive `git log` viewer** (`glo`)

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/forgit-glo.png)

*The log graph can be disabled by option `FORGIT_LOG_GRAPH_ENABLE` (see discuss in [issue #71](https://github.com/wfxr/forgit/issues/71)).*

- **Interactive `.gitignore` generator** (`gi`)

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/forgit-gi.png)

- **Interactive `git diff` viewer** (`gd`)

- **Interactive `git reset HEAD <file>` selector** (`grh`)

- **Interactive `git checkout <file>` selector** (`gcf`)

- **Interactive `git checkout <branch>` selector** (`gcb`)

- **Interactive `git branch -D <branch>` selector** (`gbd`)

- **Interactive `git checkout <tag>` selector** (`gct`)

- **Interactive `git checkout <commit>` selector** (`gco`)

- **Interactive `git revert <commit>` selector** (`grc`)

- **Interactive `git stash` viewer** (`gss`)

- **Interactive `git stash push` selector** (`gsp`)

- **Interactive `git clean` selector** (`gclean`)

- **Interactive `git cherry-pick` selector** (`gcp`)

- **Interactive `git rebase -i` selector** (`grb`)

- **Interactive `git blame` selector** (`gbl`)

- **Interactive `git commit --fixup && git rebase -i --autosquash` selector** (`gfu`)

# ⌨ Keybindings

| Key                                           | Action                                      |
| :-------------------------------------------: | ------------------------------------------- |
| <kbd>Enter</kbd>                              | Confirm                                     |
| <kbd>Tab</kbd>                                | Toggle mark and move down                   |
| <kbd>Shift</kbd> - <kbd>Tab</kbd>             | Toggle mark and move up                     |
| <kbd>?</kbd>                                  | Toggle preview window                       |
| <kbd>Alt</kbd> - <kbd>W</kbd>                 | Toggle preview wrap                         |
| <kbd>Ctrl</kbd> - <kbd>S</kbd>                | Toggle sort                                 |
| <kbd>Ctrl</kbd> - <kbd>R</kbd>                | Toggle selection                            |
| <kbd>Ctrl</kbd> - <kbd>Y</kbd>                | Copy commit hash/stash ID*                  |
| <kbd>Ctrl</kbd> - <kbd>K</kbd> / <kbd>P</kbd> | Selection move up                           |
| <kbd>Ctrl</kbd> - <kbd>J</kbd> / <kbd>N</kbd> | Selection move down                         |
| <kbd>Alt</kbd> - <kbd>K</kbd> / <kbd>P</kbd>  | Preview move up                             |
| <kbd>Alt</kbd> - <kbd>J</kbd> / <kbd>N</kbd>  | Preview move down                           |
| <kbd>Alt</kbd> - <kbd>E</kbd>                 | Open file in default editor (when possible) |

\* Available when the selection contains a commit hash or a stash ID.
For Linux users `FORGIT_COPY_CMD` should be set to make copy work. Example: `FORGIT_COPY_CMD='xclip -selection clipboard'`.

# ⚙ Options

Options can be set via environment variables. They have to be **exported** in
order to be recognized by `forgit`.

For instance, if you want to order branches in `gcb` by the last committed date you could:

```shell
export FORGIT_CHECKOUT_BRANCH_BRANCH_GIT_OPTS='--sort=-committerdate'
```

## shell aliases

You can change the default aliases by defining these variables below.
(To disable all aliases, Set the `FORGIT_NO_ALIASES` flag.)

``` bash
forgit_log=glo
forgit_diff=gd
forgit_add=ga
forgit_reset_head=grh
forgit_ignore=gi
forgit_checkout_file=gcf
forgit_checkout_branch=gcb
forgit_branch_delete=gbd
forgit_checkout_tag=gct
forgit_checkout_commit=gco
forgit_revert_commit=grc
forgit_clean=gclean
forgit_stash_show=gss
forgit_stash_push=gsp
forgit_cherry_pick=gcp
forgit_rebase=grb
forgit_blame=gbl
forgit_fixup=gfu
```

## git integration

You can use forgit as a sub-command of git by making `git-forgit` available in `$PATH`:

```sh
# after `forgit` was loaded
PATH="$PATH:$FORGIT_INSTALL_DIR/bin"
```

*Some plugin managers can help do this.*

Then, any forgit command will be a sub-command of git:

```cmd
git forgit log
git forgit add
git forgit diff
```

Optionally you can add [aliases in git](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases):

```sh
git config --global alias.cf 'forgit checkout_file'
```

And use forgit functions via a git alias:

```sh
git cf
```

## git options

If you want to customize `git`'s behavior within forgit there is a dedicated variable for each forgit command.
These are passed to the according `git` calls.

| Command  | Option                                                                      |
| -------- | --------------------------------------------------------------------------- |
| `ga`     | `FORGIT_ADD_GIT_OPTS`                                                       |
| `glo`    | `FORGIT_LOG_GIT_OPTS`                                                       |
| `gd`     | `FORGIT_DIFF_GIT_OPTS`                                                      |
| `grh`    | `FORGIT_RESET_HEAD_GIT_OPTS`                                                |
| `gcf`    | `FORGIT_CHECKOUT_FILE_GIT_OPTS`                                             |
| `gcb`    | `FORGIT_CHECKOUT_BRANCH_GIT_OPTS`, `FORGIT_CHECKOUT_BRANCH_BRANCH_GIT_OPTS` |
| `gbd`    | `FORGIT_BRANCH_DELETE_GIT_OPTS`                                             |
| `gct`    | `FORGIT_CHECKOUT_TAG_GIT_OPTS`                                              |
| `gco`    | `FORGIT_CHECKOUT_COMMIT_GIT_OPTS`                                           |
| `grc`    | `FORGIT_REVERT_COMMIT_GIT_OPTS`                                             |
| `gss`    | `FORGIT_STASH_SHOW_GIT_OPTS`                                                |
| `gsp`    | `FORGIT_STASH_PUSH_GIT_OPTS`                                                |
| `gclean` | `FORGIT_CLEAN_GIT_OPTS`                                                     |
| `grb`    | `FORGIT_REBASE_GIT_OPTS`                                                    |
| `gbl`    | `FORGIT_BLAME_GIT_OPTS`                                                     |
| `gfu`    | `FORGIT_FIXUP_GIT_OPTS`                                                     |
| `gcp`    | `FORGIT_CHERRY_PICK_GIT_OPTS`                                               |

## pagers

Forgit will use the default configured pager from git (`core.pager`,
`pager.show`, `pager.diff`) but can be altered with the following environment
variables:

| Use case             | Option                | Fallbacks to                                  |
| ------------         | -------------------   | --------------------------------------------- |
| common pager         | `FORGIT_PAGER`        | `git config core.pager` _or_ `cat`            |
| pager on `git show`  | `FORGIT_SHOW_PAGER`   | `git config pager.show` _or_ `$FORGIT_PAGER`  |
| pager on `git diff`  | `FORGIT_DIFF_PAGER`   | `git config pager.diff` _or_ `$FORGIT_PAGER`  |
| pager on `git blame` | `FORGIT_BLAME_PAGER`  | `git config pager.blame` _or_ `$FORGIT_PAGER` |
| pager on `gitignore` | `FORGIT_IGNORE_PAGER` | `bat -l gitignore --color always` _or_ `cat`  |
| git log format       | `FORGIT_GLO_FORMAT`   | `%C(auto)%h%d %s %C(black)%C(bold)%cr%reset`  |

## fzf options

You can add default fzf options for `forgit`, including keybindings, layout, etc.
(No need to repeat the options already defined in `FZF_DEFAULT_OPTS`)

``` bash
export FORGIT_FZF_DEFAULT_OPTS="
--exact
--border
--cycle
--reverse
--height '80%'
"
```

Customizing fzf options for each command individually is also supported:

| Command  | Option                            |
|----------|-----------------------------------|
| `ga`     | `FORGIT_ADD_FZF_OPTS`             |
| `glo`    | `FORGIT_LOG_FZF_OPTS`             |
| `gi`     | `FORGIT_IGNORE_FZF_OPTS`          |
| `gd`     | `FORGIT_DIFF_FZF_OPTS`            |
| `grh`    | `FORGIT_RESET_HEAD_FZF_OPTS`      |
| `gcf`    | `FORGIT_CHECKOUT_FILE_FZF_OPTS`   |
| `gcb`    | `FORGIT_CHECKOUT_BRANCH_FZF_OPTS` |
| `gbd`    | `FORGIT_BRANCH_DELETE_FZF_OPTS`   |
| `gct`    | `FORGIT_CHECKOUT_TAG_FZF_OPTS`    |
| `gco`    | `FORGIT_CHECKOUT_COMMIT_FZF_OPTS` |
| `grc`    | `FORGIT_REVERT_COMMIT_FZF_OPTS`   |
| `gss`    | `FORGIT_STASH_FZF_OPTS`           |
| `gsp`    | `FORGIT_STASH_PUSH_FZF_OPTS`      |
| `gclean` | `FORGIT_CLEAN_FZF_OPTS`           |
| `grb`    | `FORGIT_REBASE_FZF_OPTS`          |
| `gbl`    | `FORGIT_BLAME_FZF_OPTS`           |
| `gfu`    | `FORGIT_FIXUP_FZF_OPTS`           |
| `gcp`    | `FORGIT_CHERRY_PICK_FZF_OPTS`     |

Complete loading order of fzf options is:

1. `FZF_DEFAULT_OPTS` (fzf global)
2. `FORGIT_FZF_DEFAULT_OPTS` (forgit global)
3. `FORGIT_CMD_FZF_OPTS` (command specific)

Examples:

- `ctrl-d` to drop the selected stash but do not quit fzf (`gss` specific).

```sh
export FORGIT_STASH_FZF_OPTS='
--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"
'
```

- `ctrl-e` to view the logs in a vim buffer (`glo` specific).

```sh
export FORGIT_LOG_FZF_OPTS='
--bind="ctrl-e:execute(echo {} |grep -Eo [a-f0-9]+ |head -1 |xargs git show |vim -)"
'
```

## other options

| Option                      | Description                               | Default                                       |
|-----------------------------|-------------------------------------------|-----------------------------------------------|
| `FORGIT_LOG_FORMAT`         | git log format                            | `%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset` |
| `FORGIT_PREVIEW_CONTEXT`    | lines of diff context in preview mode     | 3                                             |
| `FORGIT_FULLSCREEN_CONTEXT` | lines of diff context in full-screen mode | 10                                            |
| `FORGIT_DIR_VIEW`           | command used to preview directories       | `tree` if available, otherwise `find`         |

# 📦 Optional dependencies

- [`delta`](https://github.com/dandavison/delta) / [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy): For better human-readable diffs.

- [`bat`](https://github.com/sharkdp/bat.git): Syntax highlighting for `gitignore`.

- [`emoji-cli`](https://github.com/wfxr/emoji-cli): Emoji support for `git log`.

# Completions

## Bash

- Put [`completions/git-forgit.bash`](https://github.com/wfxr/forgit/blob/master/completions/git-forgit.bash) in
  `~/.local/share/bash-completion/completions` to have bash tab completion for `git forgit` and configured git aliases.
- Source [`completions/git-forgit.bash`](https://github.com/wfxr/forgit/blob/master/completions/git-forgit.bash) explicitly to have
  bash tab completion for forgit shell functions and aliases (e.g., `gcb <tab>` completes branches).

## Zsh

- Put [`completions/_git-forgit`](completions/_git-forgit) in a directory in your `$fpath` (e.g., `/usr/share/zsh/site-functions`) to have zsh tab completion for `git forgit` and configured git aliases, as well as shell command aliases, such as `forgit::add` and `ga`

If you're having issues after updating, and commands such as `forgit::add` or aliases `ga` aren't working, remove your completions cache and restart your shell.

```zsh
> rm ~/.zcompdump
> zsh
```

# 💡 Tips

- Most of the commands accept optional arguments (e.g., `glo develop`, `glo f738479..188a849b -- main.go`, `gco master`).
- `gd` supports specifying revision(e.g., `gd HEAD~`, `gd v1.0 README.md`).
- Call `gi` with arguments to get the wanted `.gitignore` contents directly(e.g., `gi cmake c++`).

# 📃 License

[MIT](https://wfxr.mit-license.org/2017) (c) Wenxuan Zhang
