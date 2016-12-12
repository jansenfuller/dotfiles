call plug#begin()

Plug 'scrooloose/syntastic'                   " Syntax checking hacks
Plug 'tpope/vim-fugitive'                     " Git wrapper
Plug 'tpope/vim-surround'                     " Quoting and Partheneses matching and editing
Plug 'itchyny/lightline.vim'                  " Lightweight status bar
Plug 'airblade/vim-gitgutter'                 " Shows git diff in gutter (line number bar on the left)
Plug 'raimondi/delimitmate'                   " Auto closing of quotes, parns, brackets, etc
Plug 'valloric/youcompleteme'                 " Autocompletion engine
Plug 'yggdroot/indentline'                    " Display indentation with vertical lines
Plug 'slim-template/vim-slim'                 " Slim syntax highlighting
Plug 'bronson/vim-trailing-whitespace'        " Notifies of whitespace and can fix it too.
Plug 'ervandew/supertab'                      " Autocomplete with Tab
Plug 'wakatime/vim-wakatime'                  " Tracks time spent on projects and files
Plug 'jansenfuller/crayon'

call plug#end()

syntax on
colorscheme crayon
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
" Use statusbar instead
set noshowmode

" Litghtline ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightlineFugitive',
      \   'filename': 'LightlineFilename',
      \   'fileformat': 'LightlineFileformat',
      \   'filetype': 'LightlineFiletype',
      \   'fileencoding': 'LightlineFileencoding',
      \   'mode': 'LightlineMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
      \ }

function! LightlineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! LightlineFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' && has_key(g:lightline, 'ctrlp_item') ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

function! LightlineFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ''  " edit here for cool mark
      let branch = fugitive#head()
      return branch !=# '' ? mark.branch : ''
    endif
  catch
  endtry
  return ''
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

" |||||||||||||||||||||||||||||||||||||||||||||||||||| ||||||||||||||||||||||||||||||||||


set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_python_pylint_args='--ignore=E501,E225'
let g:syntastic_python_pylint_post_args="--max-line-length=220"

set laststatus=2
