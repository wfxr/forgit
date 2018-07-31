#!/usr/bin/env bash

__forgit_fzf() {
    FZF_DEFAULT_OPTS="
        $FZF_DEFAULT_OPTS
        --ansi
        --height '80%'
        --bind='alt-k:preview-up,alt-p:preview-up'
        --bind='alt-j:preview-down,alt-n:preview-down'
        --bind='ctrl-r:toggle-all'
        --bind='ctrl-s:toggle-sort'
        --bind='?:toggle-preview'
        --preview-window='right:60%'
        --bind='alt-w:toggle-preview-wrap'
        $FORGIT_FZF_DEFAULT_OPTS
    " fzf "$@"
}

__forgit_color_to_grep_code() {
    case "$1" in
        black)
            echo -E '\[30m'
            ;;
        red)
            echo -E '\[31m'
            ;;
        green)
            echo -E '\[32m'
            ;;
        yellow)
            echo -E '\[33m'
            ;;
        blue)
            echo -E '\[34m'
            ;;
        magenta)
            echo -E '\[35m'
            ;;
        cyan)
            echo -E '\[36m'
            ;;
        white)
            echo -E '\[97m'
            ;;
    esac
}

# diff is fancy with diff-so-fancy!
command -v diff-so-fancy >/dev/null 2>&1 && forgit_fancy='|diff-so-fancy'
command -v emojify >/dev/null 2>&1       && forgit_emojify='|emojify'

__forgit_inside_work_tree() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

__forgit_get_git_color() {
  local color=$(git config $1);
  color=${color:-$2}
  echo $(__forgit_color_to_grep_code $color)
}

# git commit browser
__forgit_log() {
  if [[ __forgit_inside_work_tree -ne 0 ]]; then
    return 1
  fi
  local cmd="echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I% git show --color=always % $forgit_emojify $forgit_fancy"
  eval "git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' $@ $forgit_emojify" |
      __forgit_fzf +s +m --tiebreak=index \
          --bind="enter:execute($cmd |LESS='-R' less)" \
          --bind="ctrl-y:execute-silent(echo {} |grep -o '[a-f0-9]\{7\}' |pbcopy)+abort" \
          --preview="$cmd"
}

__forgit_add() {
  if [[ __forgit_inside_work_tree -ne 0 ]]; then
    return 1
  fi
  added=$(__forgit_get_git_color "color.status.untracked" "red")
  changed=$(__forgit_get_git_color "color.status.changed" "red")
  unmerged=$(__forgit_get_git_color "color.status.unmerged" "red")

  local files=$(git -c color.status=always status --short |
        grep -e "$added" -e "$changed" -e "$unmerged" |
        awk '{printf "[%10s]  ", $1; $1=""; print $0}' |
        __forgit_fzf -0 -m --nth 2..,.. \
        --preview="git diff --no-ext-diff --color=always -- {-1} $forgit_emojify $forgit_fancy" |
        cut -d] -f2 |
        sed 's/.* -> //' | # for rename case
        tr '\n' ' ' | tr -s ' ' | sed -e 's/^[[:space:]]*//')
  if [[ -n "$files" ]]; then
    cmd="git add $files"
    bind '"\e[0n": "'"$cmd"'"';
    printf '\e[5n'
  else
    echo 'Nothing to add.'
  fi
}

alias ${forgit_add:-ga}=__forgit_add
alias ${forgit_log:-glo}=__forgit_log
