set nocompatible " Use Vim defaults before loading plugins

" -- Vim-plug --
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup PlugBootstrap
        autocmd!
        autocmd VimEnter * ++once PlugInstall --sync | source $MYVIMRC
    augroup END
endif

call plug#begin('~/.vim/plugged')

Plug 'joshdick/onedark.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'

call plug#end()

" -- General --
syntax on
filetype plugin indent on " Enable filetype settings and indentation

set termguicolors " Enable true color
colorscheme onedark " Set colorscheme

set linebreak " Wrap at words without changing file contents
set whichwrap=b,s,<,>,[,] " Wrap around at the beginning and end
set hidden  " Hide buffers when they are abandoned
set history=50 " Remember command and search history
set laststatus=2 " Always show the status line
set ruler " Display row and column numbers
set showcmd " Show command in command line
set showmode " Show mode in command line
set clipboard=unnamed " Copy paste between windows
set autoread " Auto reload file
set number " Display line numbers
set scrolloff=5 " Keep context above and below the cursor
set regexpengine=0 " Select the regex engine automatically

" -- Reading --
let g:markdown_fenced_languages = ['python', 'bash', 'json', 'yaml'] " Highlight code blocks
augroup ReadingSettings
    autocmd!
    autocmd FileType python setlocal nowrap
    autocmd FileType markdown setlocal wrap linebreak breakindent
    " Move by displayed rows in prose; keep counted motions such as 5j
    autocmd FileType markdown nnoremap <buffer> <expr> j v:count ? 'j' : 'gj'
    autocmd FileType markdown nnoremap <buffer> <expr> k v:count ? 'k' : 'gk'
augroup END

" -- Indent -
set autoindent
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set backspace=2

" -- Search --
set showmatch
set incsearch
set hlsearch
set ignorecase
set smartcase

" -- FZF --
let $FZF_DEFAULT_COMMAND = 'rg --files' " Respect ignore rules; omit hidden files
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
let g:fzf_buffers_jump = 1
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" -- NerdCommenter --
let g:NERDSpaceDelims = 1

" -- Fugitive --
" File path, modified/read-only flags, Git status, and cursor position
set statusline=%f\ %m%r\ %{FugitiveStatusline()}%=%l:%c\ %p%%

" --- Shortcuts --
nnoremap <Leader>n :setlocal number!<CR>
nnoremap <Leader>p :set paste!<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>c :Commits<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>r :Rg<Space>

