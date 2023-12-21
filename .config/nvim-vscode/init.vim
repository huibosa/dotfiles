set guicursor="i:block"
set shada="NONE"

inoremap <C-d> <Del>

nnoremap Y y$
vnoremap Y "+y
nnoremap c* *Ncgn

" noremap <silent> H ^
" noremap <silent> L $
noremap <silent> j j
noremap <silent> k k

" Moving hilighted lines in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Join next without moving cursor
nnoremap J mzJ`z

" Custom scrolling with Ctrl-d and Ctrl-u
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Keep the cursor centered when using n and N
nnoremap n nzzzv
nnoremap N Nzzzv

set ignorecase
set smartcase

lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {"kylechui/nvim-surround", config = true},
  {"numToStr/Comment.nvim", config = true},
  {"windwp/nvim-autopairs", config = function()
    local autopairs = require("nvim-autopairs")
      autopairs.setup({ map_c_h = true, })
    end
  }
})
EOF

" nnoremap = <Cmd>call VSCodeCall('editor.action.formatSelection')<CR><Esc>
" xnoremap = <Cmd>call VSCodeCall('editor.action.formatSelection')<CR>
nnoremap == <Cmd>call VSCodeCall('editor.action.format')<CR>

nnoremap gy <Cmd>call <SID>vscodeGoToDefinition('revealDeclaration')<CR>
nnoremap gY <Cmd>call VSCodeNotify('editor.action.peekDeclaration')<CR>
nnoremap gr <Cmd>call VSCodeNotify('editor.action.referenceSearch.trigger')<CR>
nnoremap gs <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
