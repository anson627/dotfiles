# Non-login interactive shells (tmux/herdr panes, IDE terminals) read only this
# file, so hand off to .bash_profile for the same PATH, prompt and hooks.
[ -f ~/.bash_profile ] && . ~/.bash_profile

# The Coder template's direnv installer appends the hook line below to
# ~/.bashrc on every workspace start unless it finds it verbatim -- and since
# this file is a symlink, that append would dirty the dotfiles clone. So the
# line lives here, unindented to match, guarded so it only runs when
# .bash_profile hasn't already loaded the hook and direnv is installed.
if ! declare -F _direnv_hook > /dev/null && command -v direnv > /dev/null; then
eval "$(direnv hook bash)"
fi
