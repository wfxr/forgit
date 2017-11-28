# forgit

`forgit` is a utility tool for git taking advantage of fuzzy finder [`fzf`](https://github.com/junegunn/fzf).

## Install

### zplug([Recommand](https://github.com/zplug/zplug))

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

- You can quit full screen preview by enter `q` and continue browsing.
- Install [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) will give you better quality of diff output.
- `GI` works like `gi` but will **append** contents to `.gitignore` directly.

## License

[MIT](LICENSE.txt)
