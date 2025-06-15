" Minimalistic Vim configuration

" Enable syntax highlighting
syntax on
filetype plugin indent on

" Basic settings
set number
set showmatch
set ignorecase
set smartcase
set incsearch
set hlsearch

" Indentation
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4

" File-specific indentation
autocmd FileType javascript,json setlocal tabstop=2 shiftwidth=2
autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab

" UI
set laststatus=2
set ruler
set wildmenu

" Key mappings
let mapleader = " "

" Quick save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Clear search highlighting
nnoremap <leader>h :nohlsearch<CR>

" Go-specific commands
autocmd FileType go nnoremap <leader>r :!go run %<CR>
autocmd FileType go nnoremap <leader>f :!goimports -w %<CR>

" Node.js-specific commands
autocmd FileType javascript nnoremap <leader>r :!node %<CR>

" Basic status line
set statusline=%f%m%r%h%w%=%y\ %l,%c\ %P