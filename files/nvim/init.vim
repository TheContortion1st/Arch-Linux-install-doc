" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.config/nvim/plugged')
" EXAMPLE Section of vim-plug {{{
    " Make sure you use single quotes

    " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
    "Plug 'junegunn/vim-easy-align'

    " Any valid git URL is allowed
    "Plug 'https://github.com/junegunn/vim-github-dashboard.git'

    " Multiple Plug commands can be written in a single line using | separators
    "Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

    " On-demand loading
    "Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    "Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

    " Using a non-master branch
    "Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

    " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
    "Plug 'fatih/vim-go', { 'tag': '*' }

    " Plugin options
    "Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

    " Plugin outside ~/.vim/plugged with post-update hook
    "Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

    " Unmanaged plugin (manually installed and updated)
    "Plug '~/my-prototype-plugin'
" }}} EXAMPLE Section of vim-plug

" neovim completion manager
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
" completion sources
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'

" better navigation in vim (improved nocompatible)
Plug 'tpope/vim-sensible'
" git-plugin for vim
Plug 'tpope/vim-fugitive'

" file-system explorer for vim/neovim
Plug 'preservim/nerdtree'

" file-system explorer for vim/neovim
Plug 'preservim/nerdtree'
" Initialize plugin system
call plug#end()

" General {{{
syntax enable       " enables syntax highlighting

set number	        " Show line numbers
set linebreak	    " Break lines at word (requires Wrap lines)
set showbreak=+++	" Wrap-broken line prefix
set textwidth=300	" Line wrap (number of cols)
set showmatch	    " Highlight matching brace
set visualbell	    " Use visual bell (no beeping)
 
set hlsearch	    " Highlight all search results
set smartcase	    " Enable smart-case search
"set ignorecase	    " Always case-insensitive
set incsearch	    " Searches for strings incrementally
 
set autoindent	    " Auto-indent new lines
set copyindent      " copy indent from previous line
set expandtab	    " Use spaces instead of tabs
set shiftwidth=4	" Number of auto-indent spaces
set smartindent	    " Enable smart-indent
set smarttab	    " Enable smart-tabs
set softtabstop=4	" Number of spaces per Tab
set tabstop=4       " Number of visual spaces per Tab
 
" }}} General

" Advanced {{{
set ruler	        " Show row and column ruler information
 
set undolevels=1000	" Number of undo levels
set backspace=indent,eol,start	" Backspace behaviour

" }}} Advanced

" UI Config {{{
set hidden
set number		    " show line number
set showcmd		    " show command in bottom bar
set cursorline	    " highlight current line
" }}} UI Config
