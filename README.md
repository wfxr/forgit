# forgit

`forgit` is a utility tool for git taking advantage of fuzzy finder [`fzf`](https://github.com/junegunn/fzf).

## Install

### [zplug](https://github.com/zplug/zplug) (Recommend)

Just add this line to your zshrc:

    zplug 'wfxr/forgit', defer:1

### Manually

Clone this repo somewhere and source the `forgit.plugin.zsh` at ~/.zshrc.

## Commands

### ga

Interactive `git add`

![screenshot](screenshot-ga.png)

    <Tab>          Mark/Unmark(and move down)
    <C-r>          Reverse selection
    <Enter>        Confirml and quit
    <C-j/n><C-k/p> Selection down/up

    <?>            Toogle preview window
    <A-w>          Toggle preview wrap
    <A-j><C-k>     Preview down/up

### glo

Interactive `git log`

![screenshot](screenshot-glo.png)

    <Enter>        Fullscreen preview
    <C-j/n><C-k/p> Selection down/up

    <?>            Toogle preview window
    <A-w>          Toggle preview wrap
    <A-j><C-k>     Preview down/up

### gd

Interactive `git diff`

    <Enter>        Fullscreen preview
    <C-j/n><C-k/p> Selection down/up

    <?>            Toogle preview window
    <A-w>          Toggle preview wrap
    <A-j><C-k>     Preview down/up

### gi

Interactive `.gitignore` generator

![screenshot](screenshot-gi.png)

### Tips

- Quit from full screen preview any time by hitting `q`.
- Install [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) will give you better quality of diff output.
- ~~`GI` works like `gi` but **appending** contents to `.gitignore` directly.~~ (Now gi has sub options to do this)
- You can give `gi` arguments to get wanted `.gitignore` contents directly

## License

[MIT](LICENSE.txt)
