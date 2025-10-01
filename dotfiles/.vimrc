" Basic Settings
set nocompatible
filetype plugin indent on
syntax on

" terminal height
set termwinsize=999x0

" VSCode-like appearance
set number
set relativenumber
set cursorline
set showmatch
set laststatus=2
set ruler
set wildmenu
set showcmd
set signcolumn=yes

" Search settings
set hlsearch
set incsearch
set ignorecase
set smartcase

" Indentation
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" UI improvements
set termguicolors
set background=dark
set mouse=a

" Enable native packages
set packpath=~/.vim

" Key mappings (VSCode-like)
let mapleader = " "

" Save
nnoremap <leader>s :w<CR>
nnoremap <C-s> :w<CR>

" Quit
nnoremap <leader>q :q<CR>

" File explorer
nnoremap <leader>e :Explore<CR>
nnoremap <C-b> :Lex<CR>

" Search
nnoremap <leader>f /
nnoremap <leader>h :nohlsearch<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Toggle line numbers
nnoremap <leader>n :set number! relativenumber!<CR>

" Copy to system clipboard
vnoremap <leader>y "+y
nnoremap <leader>y "+y
nnoremap <leader>p "+p
vnoremap <leader>p "+p

" Plugin configurations
colorscheme gruvbox
set background=dark

" NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeAutoDeleteBuffer=1

" Airline
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#fnamemod=':t'
let g:airline_powerline_fonts=1

" FZF (if available)
if executable('fzf')
    nnoremap <leader>ff :Files<CR>
    nnoremap <leader>fg :Rg<CR>
    nnoremap <leader>fb :Buffers<CR>
endif

" Auto-pairs
let g:AutoPairsFlyMode=1

" IndentLine
let g:indentLine_char='│'
let g:indentLine_enabled=1

" Floaterm
nnoremap <leader>tt :FloatermToggle<CR>
tnoremap <leader>tt <C-\><C-n>:FloatermToggle<CR>
let g:floaterm_width=0.8
let g:floaterm_height=0.8

" Auto commands
augroup vimrc
    autocmd!
    " Return to last edit position when opening files
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

    " Remove trailing whitespace on save
    autocmd BufWritePre * %s/\s\+$//e

    " Highlight yanked text (Vim 8.2+)
    if exists('##TextYankPost')
        autocmd TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=150})
    endif
augroup END
