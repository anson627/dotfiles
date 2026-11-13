# Non-login interactive shells (tmux/herdr panes, IDE terminals) read only this
# file, so hand off to .bash_profile for the same PATH, prompt and hooks.
[ -f ~/.bash_profile ] && . ~/.bash_profile
