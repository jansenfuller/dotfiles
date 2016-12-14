call plug#begin()

Plug 'airblade/vim-gitgutter'                   " Shows git diff in gutter (line number bar on the left)
Plug 'tpope/vim-fugitive'                       " Git wrapper
Plug 'tpope/vim-surround'                       " Quoting and Partheneses matching and editing
Plug 'tpope/vim-git'                            " Support plugin for fugitive
Plug 'vim-airline/vim-airline'                  " Fast status bar
Plug 'slim-template/vim-slim'                   " Slim syntax highlighting
" Plug 'bronson/vim-trailing-whitespace'          " Notifies of whitespace and can fix it too.
" Plug 'scrooloose/syntastic'                     " Syntax checking hacks
Plug 'jiangmiao/auto-pairs'                     " Auto closing of quotes, parns, brackets, etc
Plug 'valloric/youcompleteme'                   " Autocompletion engine
Plug 'yggdroot/indentline'                      " Display indentation with vertical lines
Plug 'ervandew/supertab'                        " Autocomplete with Tab
Plug 'wakatime/vim-wakatime'                    " Tracks time spent on projects and files
Plug 'jansenfuller/crayon'

call plug#end()

syntax enable
filetype plugin indent on
colorscheme crayon

" Use system clipboard
if has("clipboard")
    set clipboard=unnamed
endif

set number                                      " Line numbering
set relativenumber                              " Adds number to lines based on place in file
" Shows current line number and relative LNs
set nohlsearch                                  " Doesn't highlight search matches
set incsearch                                   " Unless it is the one selected
set ignorecase                                  " Searching case-insensitive
set autoindent                                  " Auto intenting
set tabstop=4                                   " Tab spacing
set softtabstop=4                               " unify
set shiftwidth=4                                " Indent and outdent by 4 columns
set shiftround                                  " Always indent to nearest tabstop
set expandtab                                   " use spaces instead of tabs
set lazyredraw                                  " Wait to redraw
set ttyfast                                     " Somehow improves performance?
set scrolljump=8                                " Scroll 8 lines at a time at bottom/top
let html_no_rendering=1                         " Don't render italic, bold, links in HTML

" Remap split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright

autocmd BufNewFile,BufRead *.slim set ft=slim   " Enbales vim-slim

set laststatus=2
