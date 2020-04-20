# forgit

![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-blue)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2017)

`forgit` is a utility tool powered by fzf for using git interactively.

## Installation

*Make sure you have [`fzf`](https://github.com/junegunn/fzf) installed.*

### Try Online

Run the following command in your shell to try `forgit` without installing:

##### Bash and ZSH 

``` bash
source <(curl -Ss https://raw.githubusercontent.com/wfxr/forgit/master/forgit.plugin.zsh)
```
##### Fish 3.0 (NOTE: 3.1 is not currently supported)
``` fish
source (curl -Ss https://raw.githubusercontent.com/wfxr/forgit/master/forgit.plugin.fish | psub)
```

### Installation using a ZSH Plugin manager
### [Zplug](https://github.com/zplug/zplug)
``` zsh
zplug 'wfxr/forgit'
```

### [Zgen](https://github.com/tarjoilija/zgen)
``` zsh
zgen load 'wfxr/forgit'
```

### [Antigen](https://github.com/zsh-users/antigen)
``` zsh
antigen bundle 'wfxr/forgit'
```

### Manual Installation

Download and source `forgit.plugin.zsh`, `forgit.plugin.sh`, or `forgit.plugin.fish` in your shell config.

## Commands

### ga

Interactive `git add` selector

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/forgit-ga.png)

### glo

Interactive `git log` viewer

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/forgit-glo.png)

*The log graph can be disabled by option `FORGIT_LOG_GRAPH_ENABLE` (see discuss in [issue #71](https://github.com/wfxr/forgit/issues/71)).*

### gi

Interactive `.gitignore` generator

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/forgit-gi.png)

### gd

Interactive `git diff` viewer

### grh

Interactive `git reset HEAD <file>` selector

### gcf

Interactive `git checkout <file>` selector

### gss

Interactive `git stash` viewer

### gclean

Interactive `git clean` selector


## Default keybinds

| Keybind                                       | Action                  |
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

## Custom options

You can change the default aliases by defining these variables below.
(To disable all aliases, Set the `FORGIT_NO_ALIASES` flag.)

``` bash
# Define them before sourcing the plugin if you don't use any plugin manager.
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

The complete loading order of fzf options is:

1. `FZF_DEFAULT_OPTS`(fzf global)
2. `FORGIT_FZF_DEFAULT_OPTS`(forgit global)
3. `FORGIT_CMD_FZF_OPTS`(command specific)

**Example**
```
// adds a keybind to drop the selected stash but do not quit fzf
FORGIT_STASH_FZF_OPTS='
--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"
'
```

## Optional

- [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) or [`delta`](https://github.com/dandavison/delta): Improve the `git diff` output.

- [`bat`](https://github.com/sharkdp/bat.git): Syntax highlighting for `gitignore`.

- [`emoji-cli`](https://github.com/wfxr/emoji-cli): Emoji support for `git log`.

## Tips

- Hit `q` to quit from full screen preview any time.
- Commands like `glo`, `gd`, `gcf` and `gclean` accept arguments to restrain the items listed in fzf(eg, `glo develop`, `glo f738479..188a849b -- main.go`, `gclean output/` etc.).
- `gd` supports specifying revision(eg, `gd HEAD~`, `gd v1.0 README.md`).
- Call `gi` with arguments to get the wanted `.gitignore` contents directly(eg, `gi cmake c++`).

## License

[MIT](https://wfxr.mit-license.org/2017) (c) Wenxuan Zhang
