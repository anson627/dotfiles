# Machine-local environment variables
[ -f ~/.profile ] && . ~/.profile

export EDITOR="vim"
export MISE_GLOBAL_CONFIG_FILE="$HOME/.mise.toml"

# Idempotent, so an inheriting child shell can't stack duplicate entries.
path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.local/share/mise/shims"
export PATH

# Everything below is interactive-only
case $- in *i*) ;; *) return ;; esac

# Prompt:  user@host  cwd  (branch) $
#          sage  grey  blue  tan   orchid
# Every token opens with a reset so bold from one segment can't bleed into the
# next. 256-color is sniffed from the environment because `tput` would cost a
# fork on every shell start.
case ${COLORTERM-}:${TERM-} in
    *truecolor*|*24bit*|*256color*|*direct*|*:alacritty|*:ghostty|*:wezterm|*:xterm-kitty)
        __c_id='\[\033[0;38;5;108m\]'   __c_dir='\[\033[0;1;38;5;111m\]'
        __c_git='\[\033[0;38;5;180m\]'  __c_dim='\[\033[0;38;5;244m\]'
        __c_sig='\[\033[0;38;5;176m\]' ;;
    *)
        __c_id='\[\033[0;32m\]'  __c_dir='\[\033[0;1;34m\]'
        __c_git='\[\033[0;33m\]' __c_dim='\[\033[0;2m\]'
        __c_sig='\[\033[0;35m\]' ;;
esac
__c_off='\[\033[0m\]'

# Branch of the enclosing repo, pre-colored, into $__git_ps. Reads .git/HEAD
# directly: no `git` fork, so it stays cheap on every prompt.
__git_prompt() {
    local dir=$PWD base gd head ref junk
    __git_ps=
    while [ -n "$dir" ]; do
        if [ -e "$dir/.git" ]; then base=$dir gd=$dir/.git; break; fi
        dir=${dir%/*}
    done
    [ -n "$gd" ] || return 0
    if [ -f "$gd" ]; then                      # worktree / submodule: "gitdir: <path>"
        read -r junk gd < "$gd" || return 0
        case $gd in /*) ;; *) gd=$base/$gd ;; esac
    fi
    read -r head < "$gd/HEAD" 2> /dev/null || return 0
    case $head in
        "ref: refs/heads/"*) ref=${head#ref: refs/heads/} ;;
        "ref: "*)            ref=${head#ref: } ;;
        *)                   ref=${head:0:7} ;;
    esac
    __git_ps="${__c_dim}(${__c_git}${ref}${__c_dim}) "
}
__set_prompt() {
    __git_prompt
    PS1="${__c_id}\u${__c_dim}@${__c_id}\h ${__c_dir}\W ${__git_ps}${__c_sig}\\\$${__c_off} "
}
PROMPT_COMMAND="__set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

alias ls='ls -Fh --color=auto'
alias grep='grep --color=auto'
alias gg='git grep --color=auto -r'
alias k='kubectl'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias claude='claude --dangerously-skip-permissions'
alias codex='codex --yolo'

# Source a tool's shell hook from a cache instead of paying the tool's own
# startup cost; install.sh warms the same files. Stale once .mise.toml moves.
cached_init() {
    local f=$HOME/.cache/bash-init/$1.bash
    shift
    if [ ! -s "$f" ] || [ "$HOME/.mise.toml" -nt "$f" ]; then
        command -v "$1" > /dev/null || return 0
        mkdir -p "${f%/*}" && "$@" > "$f" || return 0
    fi
    . "$f"
}
cached_init zoxide zoxide init bash
cached_init fzf fzf --bash

if [ -r /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi
