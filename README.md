# forgit

`forgit` is a utility tool for git taking advantage of fuzzy finder [`fzf`](https://github.com/junegunn/fzf).

## Demo

![screenshot](screenshot.png)

## Install

### zplug([Recommand](https://github.com/zplug/zplug))

Just add this line to your zshrc:

    `zplug 'wfxr/forgit', defer:1`

### Manually

Clone this repo somewhere and source the `forgit.plugin.zsh` at ~/.zshrc.

## Commands

### ga

Interactive `git add`

    <Tab>          Mark/Unmark(and move down)
    <C-r>          Reverse selection
    <Enter>        Confirml and quit
    <C-j/n><C-k/p> Selection down/up

    <?>            Toogle preview window
    <A-w>          Toggle preview wrap
    <A-j><C-k>     Preview down/up

### glo

Interactive `git log`

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

### Tips

Install [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) for better quality of diff result.

## License

[MIT](LICENSE.txt)
