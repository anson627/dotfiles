" -- Vim-plug --
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
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
filetype on
filetype plugin on

set termguicolors " Enable true color
colorscheme onedark " Set colorscheme

set nocp " Enable features which are not Vi compatible
set linebreak " Word wrap without line breaks
set whichwrap=b,s,<,>,[,] " Wrap around at the beginning and end
set hidden  " Hide buffers when they are abandoned
set history=50 " Set preview window
set laststatus=2 " Display status of last window
set ruler " Display row and colum numbers
set showcmd " Show command in command line
set showmode " Show mode in command line
set clipboard=unnamed " Copy paste between windows
set autoread " Auto reload file
set number " Display line numbers
set regexpengine=0 " Disable regex engine

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

" --- Shortcuts --
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nmap <Leader>n :setlocal number!<CR>
nmap <Leader>p :set paste!<CR>

" -- Coding Style --
set cinoptions+=g0,j1
set encoding=utf-8
autocmd BufWritePre * :%s/\s\+$//e

" -- FZF --
let $FZF_DEFAULT_COMMAND = 'find . -type f -not -path "./.git/*"'
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
nmap <Leader>b :Buffers<CR>
nmap <Leader>c :Commits<CR>
nmap <Leader>f :Files<CR>

" -- NerdCommenter --
let g:NERDSpaceDelims = 1

" -- Fugitive --
set statusline+=%{FugitiveStatusline()}

