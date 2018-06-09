# forgit

`forgit` is a utility tool for git taking advantage of fuzzy finder fzf.

## Installation

Make sure you have [`fzf`](https://github.com/junegunn/fzf) installed.

### for [zplug](https://github.com/zplug/zplug) (Recommend)

``` zsh
zplug 'wfxr/forgit', defer:1
```

### for [zgen](https://github.com/tarjoilija/zgen)
```
zgen load wfxr/forgit
```

### for [antigen](https//github.com/zsh-users/antigen)

```
antigen bundle wfxr/forgit
```

### Manually

Clone this repo somewhere and source the `forgit.plugin.zsh` at ~/.zshrc.

## Commands

### ga

Interactive `git add` selector

![screenshot](screenshot-ga.png)

### glo

Interactive `git log` browser

![screenshot](screenshot-glo.png)

### gd

Interactive `git diff` browser

### gcf

Interactive `git checkout <file>` selector

### gclean

Interactive `git clean` selector

### gi

Interactive `.gitignore` generator

![screenshot](screenshot-gi.png)

## Default keybinds

| Keybind    | Action                |
| ---------- | --------------------- |
| `<Enter>`  | Confirm               |
| `<Tab>`    | Toggle mark           |
| `<C-k/p>`  | Selection up          |
| `<C-j/n>`  | Selection down        |
| `<A-k/p>`  | Preview up            |
| `<A-j/n>`  | Preview down          |
| `<A-w>`    | Toggle preview wrap   |
| `<?>`      | Toggle preview window |
| `<C-r>`    | Toggle selection      |
| `<C-s>`    | Toggle sort           |

## Custom options

You can change the default aliases by defining these variables below.

``` bash
# Define them before sourcing the plugin if you don't use any plugin manager.
forgit_log=glo
forgit_diff=gd
forgit_add=ga
forgit_ignore=gi
forgit_restore=gcf
forgit_clean=gclean
```

You can add custom fzf options for `forgit`, including keybinds, layout, etc.
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

### Tips

- Hit `q` to Quit from full screen preview any time.
- Install [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) to have better `diff` output.
- Commands like `glo`, `gd`, `gcf` and `gclean` accept path arguments to restrain the items listed in fzf(eg, `glo main.go test.go`, `gclean output/`).
- Call `gi` with arguments to get wanted `.gitignore` contents directly(eg, `gi c++`).

## [License](LICENSE.txt)

The MIT License (MIT)

Copyright (c) 2018 Wenxuan Zhang
