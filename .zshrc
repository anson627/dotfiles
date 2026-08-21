# Machine-local environment variables
[ -f ~/.profile ] && . ~/.profile

export EDITOR="vim"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacad
export MISE_GLOBAL_CONFIG_FILE="$HOME/.mise.toml"

# Idempotent, so a nested shell can't stack duplicate entries. /etc/zprofile has
# already run path_helper by this point, so these land in front of it.
path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.local/share/mise/shims"
export PATH

# Prompt:  user@host  cwd  (branch) $
#          sage  grey  blue  tan   orchid
# Every token opens with %b so bold from one segment can't bleed into the next.
# 256-color is sniffed from the environment because `tput` would cost a fork on
# every shell start.
case ${COLORTERM-}:${TERM-} in
    *truecolor*|*24bit*|*256color*|*direct*|*:alacritty|*:ghostty|*:wezterm|*:xterm-kitty)
        __c_id='%b%F{108}' __c_dir='%B%F{111}' __c_git='%b%F{180}'
        __c_dim='%b%F{244}' __c_sig='%b%F{176}' ;;
    *)
        __c_id='%b%F{green}' __c_dir='%B%F{blue}' __c_git='%b%F{yellow}'
        __c_dim=$'%b%{\e[2m%}' __c_sig='%b%F{magenta}' ;;
esac
__c_off='%b%f'

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
    ref=${ref//\%/%%}                          # a '%' would read as a prompt escape
    __git_ps="${__c_dim}(${__c_git}${ref}${__c_dim}) "
}
__set_prompt() {
    __git_prompt
    PS1="${__c_id}%n${__c_dim}@${__c_id}%m ${__c_dir}%1~ ${__git_ps}${__c_sig}%(!.#.\$)${__c_off} "
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd __set_prompt               # a hook, not precmd(), so other hooks survive

alias ls='ls -GFh'
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
    local f=$HOME/.cache/zsh-init/$1.zsh
    shift
    if [ ! -s "$f" ] || [ "$HOME/.mise.toml" -nt "$f" ]; then
        command -v "$1" > /dev/null || return 0
        mkdir -p "${f%/*}" && "$@" > "$f" || return 0
    fi
    . "$f"
}
cached_init zoxide zoxide init zsh
cached_init fzf fzf --zsh

# Completions: full rebuild at most once a day, cheap cached load otherwise.
fpath=(~/.zfunc $fpath)
autoload -Uz compinit
__zcd=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump
mkdir -p "${__zcd:h}"
if [[ -n ${__zcd}(#qN.mh-24) ]]; then
    compinit -C -d "$__zcd"
else
    compinit -d "$__zcd"
fi
unset __zcd
