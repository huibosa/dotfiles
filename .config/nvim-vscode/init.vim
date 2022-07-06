nnoremap Y y$
vnoremap Y "+y
nnoremap Q @q
nnoremap < <<
nnoremap > >>
nnoremap c* *Ncgn

noremap <silent> H g^
noremap <silent> L g$
noremap <silent> j gj
noremap <silent> k gk

set clipboard=unnamedplus

nnoremap <silent> <c-l> :nohlsearch<cr><c-l>

call plug#begin()

Plug 'machakann/vim-sandwich'
Plug 'godlygeek/tabular'

call plug#end()
