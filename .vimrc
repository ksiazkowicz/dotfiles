set nocompatible

let g:windows=has('win32') || has('win64')
let g:haiku=has('haiku') || has('beos')

if g:windows
    behave mswin
    set runtimepath+=~/.vim
    set clipboard=unnamed
    set shell=powershell
    set shellcmdflag=-command
endif

if g:haiku
    set runtimepath+=~/.vim
endif

if g:windows && !has('gui_running') && $ConEmuANSI == "ON"
    set term=xterm
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"

    inoremap <Char-0x07F> <BS>
    nnoremap <Char-0x07F> <BS>

    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"

    inoremap <Esc>[62~ <C-X><C-E>
    inoremap <Esc>[63~ <C-X><C-Y>
    nnoremap <Esc>[62~ <C-E>
    nnoremap <Esc>[63~ <C-Y>
endif

if !g:windows && !has('gui_running')
    set term=screen-256color
    set t_ut=
endif

" important things without which I can't live :(
syntax on
set enc=utf8
set encoding=utf-8
set backspace=2
set laststatus=2
set tabstop=4
set shiftwidth=4
set expandtab
set colorcolumn=80,120

" plugins
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tomasiser/vim-code-dark'
Plug 'jreybert/vimagit'
Plug 'jmcantrell/vim-virtualenv'
Plug 'scrooloose/nerdtree'
call plug#end()

" gvim settings
if has('gui_running')
    if g:windows
        set guifont=Source_Code_Variable:h10:cANSI:qDRAFT
    else
        set guifont=Source\ Code\ Pro\ 11
    endif
    set guioptions -=m
    set guioptions -=T
endif

" themes
let g:airline_powerline_fonts = 1
map <F7> mzgg=G`z
let g:airline_theme="codedark"

if g:windows && !has('gui_running') && $ConEmuANSI != "ON"
    colorscheme desert
else
    colorscheme codedark
endif 

" keyboard mappings
inoremap <C-v> <ESC>"+pa
vnoremap <C-c> "+y
vnoremap <C-d> "+d

map <F2> :NERDTreeToggle<CR>
map <F7> :tabn<CR>
map <F8> :tabp<CR>
map <F9> :tabclose<CR>
map <F6> :tabe

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
