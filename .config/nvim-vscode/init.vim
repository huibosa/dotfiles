set guicursor="i:block"
set shada="NONE"

inoremap <C-d> <Del>

nnoremap Y y$
vnoremap Y "+y
nnoremap c* *Ncgn

noremap <silent> H ^
noremap <silent> L $
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
  -- {"windwp/nvim-autopairs", config = function()
  --   local autopairs = require("nvim-autopairs")
  --     autopairs.setup({ map_c_h = true, })
  --   end
  -- },
  {
    "echasnovski/mini.surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    opts = {
        mappings = {
            add = "gsa", -- Add surrounding in Normal and Visual modes
            delete = "gsd", -- Delete surrounding
            find = "gsf", -- Find surrounding (to the right)
            find_left = "gsF", -- Find surrounding (to the left)
            highlight = "gsh", -- Highlight surrounding
            replace = "gsr", -- Replace surrounding
            update_n_lines = "gsn", -- Update `n_lines`
        },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {"nvim-treesitter/nvim-treesitter"},
    config = function()
        require("nvim-treesitter.configs").setup({
            textobjects = {
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        ["a="] = { query = "@assignment.outer", desc = "outer assignment" },
                        ["i="] = { query = "@assignment.inner", desc = "inner assignment" },

                        ["aa"] = { query = "@parameter.outer", desc = "outer parameter" },
                        ["ia"] = { query = "@parameter.inner", desc = "inner parameter" },

                        ["aj"] = { query = "@conditional.outer", desc = "outer conditional" },
                        ["ij"] = { query = "@conditional.inner", desc = "inner conditional" },

                        ["al"] = { query = "@loop.outer", desc = "outer loop" },
                        ["il"] = { query = "@loop.inner", desc = "inner loop" },

                        -- ["ab"] = { query = "@block.outer", desc = "outer block" },
                        -- ["ib"] = { query = "@block.inner", desc = "inner block" },

                        ["af"] = { query = "@function.outer", desc = "outer function" },
                        ["if"] = { query = "@function.inner", desc = "inner function" },

                        ["ac"] = { query = "@class.outer", desc = "outer class" },
                        ["ic"] = { query = "@class.inner", desc = "inner class" },

                        ["ar"] = { query = "@return.outer", desc = "outer return" },
                        ["ir"] = { query = "@return.outer", desc = "inner return" },

                        ["a/"] = { query = "@comment.outer", desc = "outer comment" },
                        ["i/"] = { query = "@comment.inner", desc = "inner comment" },
                    },
                    include_surrounding_whitespace = true,
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>a"] = "@parameter.inner", -- swap object under cursor with next
                    },
                    swap_previous = {
                        ["<leader>A"] = "@parameter.inner", -- swap object under cursor with previous
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]a"] = { query = "@parameter.outer", desc = "Next argument start" },
                        ["]f"] = { query = "@function.outer", desc = "Next function start" },
                        ["]r"] = { query = "@return.outer", desc = "Next return start" },
                        ["]c"] = { query = "@class.outer", desc = "Next class start" },
                        ["]j"] = { query = "@conditional.outer", desc = "Next judge start" },
                        ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
                    },
                    goto_next_end = {
                        ["]A"] = { query = "@parameter.outer", desc = "Next argument end" },
                        ["]F"] = { query = "@function.outer", desc = "Next function end" },
                        ["]R"] = { query = "@return.outer", desc = "Next return end" },
                        ["]C"] = { query = "@class.outer", desc = "Next class end" },
                        ["]J"] = { query = "@conditional.outer", desc = "Next judge end" },
                        ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
                    },
                    goto_previous_start = {
                        ["[a"] = { query = "@parameter.outer", desc = "Previous argument start" },
                        ["[f"] = { query = "@function.outer", desc = "Previous function start" },
                        ["[r"] = { query = "@return.outer", desc = "Previous return start" },
                        ["[c"] = { query = "@class.outer", desc = "Previous class start" },
                        ["[j"] = { query = "@conditional.outer", desc = "Previous judge start" },
                        ["[l"] = { query = "@loop.outer", desc = "Previous loop start" },
                    },
                    goto_previous_end = {
                        ["[A"] = { query = "@parameter.outer", desc = "Previous argument end" },
                        ["[F"] = { query = "@function.outer", desc = "Previous function end" },
                        ["[R"] = { query = "@return.outer", desc = "Previous return end" },
                        ["[C"] = { query = "@class.outer", desc = "Previous class end" },
                        ["[J"] = { query = "@conditional.outer", desc = "Previous judge end" },
                        ["[L"] = { query = "@loop.outer", desc = "Previous loop end" },
                    },
                },
            },
        })
        local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

        -- Repeat movement with ; and ,
        vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
        vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)


        -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
        vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
        vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
        vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
        vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
    end
  }
})
EOF

au TextChanged * silent! lua vim.treesitter.get_parser():parse()

" nnoremap = <Cmd>call VSCodeCall('editor.action.formatSelection')<CR><Esc>
" xnoremap = <Cmd>call VSCodeCall('editor.action.formatSelection')<CR>
nnoremap == <Cmd>call VSCodeCall('editor.action.format')<CR>

nnoremap gd <Cmd>call VSCodeNotify('editor.action.peekDefinition')<CR>
nnoremap gD <Cmd>call VSCodeNotify('editor.action.peekDeclaration')<CR>
nnoremap gy <Cmd>call VSCodeNotify('editor.action.peekTypeDefinition')<CR>
nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>
nnoremap gI <Cmd>call VSCodeNotify('editor.action.peekImplementation')<CR>

nnoremap <space>fs <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
nnoremap <space>fS <Cmd>call VSCodeNotify('workbench.action.showAllSymbols')<CR>

nnoremap <space>cr <Cmd>call VSCodeNotify('editor.action.rename')<CR>
nnoremap <space>ca <Cmd>call VSCodeNotify('editor.action.sourceAction')<CR>
