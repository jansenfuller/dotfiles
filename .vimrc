" Plugin Calls
call plug#begin()
  Plug 'scrooloose/syntastic'                     " Syntax checks
  Plug 'pangloss/vim-javascript'                  " Javascript support
  Plug 'valloric/youcompleteme'                   " Autocompletion
  Plug 'itchyny/lightline.vim'                    " Fast status bar
  Plug 'airblade/vim-gitgutter'                   " Shows git diff in gutter (line number bar on the left)
  Plug 'tpope/vim-fugitive'                       " Git wrapper
  Plug 'wakatime/vim-wakatime'                    " Tracks time spent on projects and files
  Plug 'jansenfuller/crayon'                      " My colorsheme
  Plug 'yggdroot/indentline'                      " Display indentation with vertical lines
  Plug 'scrooloose/nerdtree'
call plug#end()


set nocompatible                        " Not vi compatable
filetype plugin indent on               " Filetype auto-detection
syntax on                               " Syntax highlighting
colorscheme crayon

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

" bindings for easy split nav
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
set splitbelow                          " Will always vsplit below
set splitright                          " Will always hsplit right

" Tab bindings
nnoremap <C-S-Left> :tabprevious<CR>
nnoremap <C-S-Right> :tabnext<CR>
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

" NERDTree binding
map <C-n> :NERDTreeToggle<CR>

" Ignore complied files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

" Delete trailing white space on save
autocmd BufWritePre * :%s/\s\+$//e

" Enables and sets lightline
let g:lightline = {
    \'colorscheme': 'jellybeans',
    \'active': {
    \   'left':[
    \           [ 'mode', 'paste', 'ale' ],
    \           [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
    \   'right': [
    \           ['lineinfo'], ['percent'],
    \           ['fileformat', 'filetype', 'readonly']]
    \},'component': {
    \  'lineinfo': ' %3l:%-2v'
    \},
    \'component_function': {
    \ 'gitbranch': 'fugitive#head',
    \}
  \}

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_highlighting = 1
let g:syntastic_error_symbol = '⨉'
let g:syntastic_warning_symbol = '⚠ '
let g:syntastic_javascript_checkers = ['eslint']
