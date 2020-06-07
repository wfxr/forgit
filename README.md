<h1 align="center">💤 forgit</h1>
<p align="center">
    <em>Utility tool for using git interactively. Powered by <a href="https://github.com/junegunn/fzf">junegunn/fzf</a>.</em>
</p>

<p align="center">
  <a href="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-blue"
    ><img
      src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-blue"
  /></a>
  <a href="https://github.com/unixorn/awesome-zsh-plugins"
    ><img
      src="https://img.shields.io/badge/Awesome-zsh--plugins-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC"
  /></a>
  <a href="https://wfxr.mit-license.org/2017"
    ><img
      src="https://img.shields.io/badge/License-MIT-brightgreen.svg"
  /></a>
</p>

This tool is designed to help you use git more efficiently.
It's **lightweight** and **easy to use**.

### 📥 Installation

*Make sure you have [`fzf`](https://github.com/junegunn/fzf) installed.*

``` zsh
# for zplug
zplug 'wfxr/forgit'

# for zgen
zgen load 'wfxr/forgit'

# for antigen
antigen bundle 'wfxr/forgit'

# manually
# Clone the repository and source it in your shell's rc file.
```

You can run the following command to try `forgit` without installing:

``` bash
# for bash / zsh
source <(curl -s https://raw.githubusercontent.com/wfxr/forgit/master/forgit.plugin.zsh)
# for fish
source (curl -s https://raw.githubusercontent.com/wfxr/forgit/master/forgit.plugin.fish | psub)
```

### 📝 Features

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

- **Interactive `git stash` viewer** (`gss`)

- **Interactive `git clean` selector** (`gclean`)

### ⌨  Keybinds

| Key                                           | Action                  |
| :-------------------------------------------: | ----------------------- |
| <kbd>Enter</kbd>                              | Confirm                 |
| <kbd>Tab</kbd>                                | Toggle mark             |
| <kbd>?</kbd>                                  | Toggle preview window   |
| <kbd>Alt</kbd> - <kbd>W</kbd>                 | Toggle preview wrap     |
| <kbd>Ctrl</kbd> - <kbd>S</kbd>                | Toggle sort             |
| <kbd>Ctrl</kbd> - <kbd>R</kbd>                | Toggle selection        |
| <kbd>Ctrl</kbd> - <kbd>K</kbd> / <kbd>P</kbd> | Selection move up       |
| <kbd>Ctrl</kbd> - <kbd>J</kbd> / <kbd>N</kbd> | Selection move down     |
| <kbd>Alt</kbd> - <kbd>K</kbd> / <kbd>P</kbd>  | Preview move up         |
| <kbd>Alt</kbd> - <kbd>J</kbd> / <kbd>N</kbd>  | Preview move down       |

### ⚙  Options

You can change the default aliases by defining these variables below.
(To disable all aliases, Set the `FORGIT_NO_ALIASES` flag.)

``` bash
forgit_log=glo
forgit_diff=gd
forgit_add=ga
forgit_reset_head=grh
forgit_ignore=gi
forgit_restore=gcf
forgit_clean=gclean
forgit_stash_show=gss
```

You can add default fzf options for `forgit`, including keybinds, layout, etc.
(No need to repeat the options already defined in `FZF_DEFAULT_OPTS`)

``` bash
FORGIT_FZF_DEFAULT_OPTS="
--exact
--border
--cycle
--reverse
--height '80%'
"
```

Customizing fzf options for each command individually is also supported:

| Command  | Option                       |
|----------|------------------------------|
| `ga`     | `FORGIT_ADD_FZF_OPTS`        |
| `glo`    | `FORGIT_LOG_FZF_OPTS`        |
| `gi`     | `FORGIT_IGNORE_FZF_OPTS`     |
| `gd`     | `FORGIT_DIFF_FZF_OPTS`       |
| `grh`    | `FORGIT_RESET_HEAD_FZF_OPTS` |
| `gcf`    | `FORGIT_CHECKOUT_FZF_OPTS`   |
| `gss`    | `FORGIT_STASH_FZF_OPTS`      |
| `gclean` | `FORGIT_CLEAN_FZF_OPTS`      |

Complete loading order of fzf options is:

1. `FZF_DEFAULT_OPTS` (fzf global)
2. `FORGIT_FZF_DEFAULT_OPTS` (forgit global)
3. `FORGIT_CMD_FZF_OPTS` (command specific)

**Example**
```
# adds a keybind to drop the selected stash but do not quit fzf
FORGIT_STASH_FZF_OPTS='
--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"
'
```

### 📦 Optional dependencies

- [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) or [`delta`](https://github.com/dandavison/delta): Improve the `git diff` output.

- [`bat`](https://github.com/sharkdp/bat.git): Syntax highlighting for `gitignore`.

- [`emoji-cli`](https://github.com/wfxr/emoji-cli): Emoji support for `git log`.

### 💡 Tips

- Hit `q` to quit from full screen preview any time.
- Commands like `glo`, `gd`, `gcf` and `gclean` accept arguments to restrain the items listed in fzf(eg, `glo develop`, `glo f738479..188a849b -- main.go`, `gclean output/` etc.).
- `gd` supports specifying revision(eg, `gd HEAD~`, `gd v1.0 README.md`).
- Call `gi` with arguments to get the wanted `.gitignore` contents directly(eg, `gi cmake c++`).

### 📃 License

[MIT](https://wfxr.mit-license.org/2017) (c) Wenxuan Zhang
