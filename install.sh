#!/usr/bin/env bash

set -eu

repo=$(cd "$(dirname "$0")" && pwd)
os=$(uname -s)

case $os in
    Darwin) shell=zsh  links=".zshrc" ;;
    Linux)  shell=bash links=".bash_profile" ;;
    *) echo "unsupported OS: $os" >&2; exit 1 ;;
esac
links="$links .gitconfig .gitignore_global .mise.toml .vimrc .config/herdr/config.toml"

# --- links -----------------------------------------------------------------

for f in $links; do
    [ -e "$repo/$f" ] || continue
    target=$HOME/$f
    # Nested entries (.config/...) need their parent before ln can land there.
    case $f in */*) mkdir -p "${target%/*}" ;; esac
    # Anything already there that isn't one of our symlinks predates this repo
    # on the machine, so keep a copy rather than silently dropping it.
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup=$target.bak
        n=1
        while [ -e "$backup" ]; do backup=$target.bak.$n; n=$((n + 1)); done
        mv "$target" "$backup"
        echo "kept existing ~/$f as ${backup##*/}"
    fi
    if ln -sfn "$repo/$f" "$target"; then
        echo "linked ~/$f -> $repo/$f"
    else
        echo "WARNING: could not link ~/$f" >&2   # never block the toolchain bootstrap
    fi
done

# --- macOS prerequisites ---------------------------------------------------

# Command Line Tools are the only thing macOS needs from outside mise: they are
# the sole source of git (and of cc, for the odd tool mise builds instead of
# downloading). No Homebrew -- everything it used to carry here, gh included,
# now comes from .mise.toml, which is also what the Linux box uses.
if [ "$os" = Darwin ] && ! xcode-select -p > /dev/null 2>&1; then
    xcode-select --install || true   # a GUI installer; can't be scripted
    echo "installing Command Line Tools -- re-run this script once it finishes" >&2
    exit 1
fi

# --- toolchain -------------------------------------------------------------

export PATH="$HOME/.local/bin:$PATH"
export MISE_GLOBAL_CONFIG_FILE="$HOME/.mise.toml"

if ! command -v mise > /dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
fi
mise install --quiet || echo "WARNING: some mise tools failed to install" >&2

# --- shell hook cache ------------------------------------------------------

# Populate what cached_init in the rc file reads, so the first shell after
# a rebuild is as fast as the hundredth. Each hook is optional: a tool that
# isn't installed just leaves its cache file absent.
export PATH="$HOME/.local/share/mise/shims:$PATH"
cache=$HOME/.cache/$shell-init
rm -rf "$cache"
mkdir -p "$cache"
warm() {
    command -v "$1" > /dev/null 2>&1 || return 0
    "$@" > "$cache/$1.$shell" || rm -f "$cache/$1.$shell"
}
warm zoxide init "$shell"
warm fzf "--$shell"

echo "warmed $cache"

# Pick up plugins added to .vimrc since the last run -- notably fzf, whose Vim
# side is a plugin while its binary comes from mise. Only if vim-plug is already
# there; on a fresh machine .vimrc bootstraps it on first launch. Vim exits
# non-zero from silent-ex mode even when this succeeds.
if command -v vim > /dev/null 2>&1 && [ -f "$HOME/.vim/autoload/plug.vim" ]; then
    vim -Es -u "$HOME/.vimrc" +'PlugInstall --sync' +qall < /dev/null > /dev/null 2>&1 || true
    echo "synced vim plugins"
fi

# The devbox gets a GITHUB_TOKEN from Coder; a fresh Mac has to log in once,
# and gh is also what git uses as its credential helper (see .gitconfig). The
# token check comes first because it is only exported for login shells, which
# this script isn't -- without it the devbox reports a spurious logged-out.
if [ -z "${GITHUB_TOKEN-}${GH_TOKEN-}" ] && ! gh auth status > /dev/null 2>&1; then
    echo "note: run 'gh auth login' to authenticate GitHub" >&2
fi

echo "done -- open a new $shell to pick everything up"
