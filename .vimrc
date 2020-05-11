call plug#begin('~/.vim/plugged')
  Plug 'itchyny/lightline.vim'
  Plug 'altercation/vim-colors-solarized'
	Plug 'airblade/vim-gitgutter'
call plug#end()

set nocompatible                        " Not vi compatable
filetype plugin indent on               " Filetype auto-detection
syntax on                               " Syntax highlighting
set background=dark
colorscheme solarized

" General Settings
set noswapfile                          " They're just annoying. Who likes them?
set number                              " Line numbers
set ruler                               " Always show current position
set lazyredraw                          " Don't redraw while executing macros
set ttyfast                             " Rendering? I actually don't know what this does
set laststatus=2                        " Always show the status line
set history=100                         " Vim command history saved up to 100 commands
set scrolljump=8                        " Scroll 8 lines at a time at bottom/top

" Indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab                           " use spaces instead of tabs.
set smarttab                            " let's tab key insert 'tab stops', and bksp deletes tabs.
set shiftround                          " tab / shifting moves to closest tabstop.
set autoindent                          " Match indents on new lines.
set smartindent                         " Intellegently dedent / indent new lines based on rules.

" Swapping and buffer fixes
set hidden                              " allow me to have buffers with unsaved changes.
set autoread                            " when a file has changed on disk, just load it. Don't ask.
set noswapfile                          " Does what it says, no swapping
set nobackup                            " Doens't backup stuff I think?
set nowb                                " No idea what this is

" Make search more sane
set ignorecase                          " case insensitive search
set smartcase                           " If there are uppercase letters, become case-sensitive.
set incsearch                           " live incremental searching
set showmatch                           " live match highlighting
set hlsearch                            " highlight matches
set gdefault                            " use the `g` flag by default.

" Ignore complied files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

" Lightline Config
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo'],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
