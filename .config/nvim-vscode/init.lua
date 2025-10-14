local keymap = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", {
        noremap = true,
        silent = true,
    }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

if vim.g.vscode then
    local vscode = require("vscode-neovim")
    keymap("n", "gd", function() vscode.action("editor.action.revealDefinition") end)
    keymap("n", "gD", function() vscode.action("editor.action.revealDeclaration") end)
    keymap("n", "grt", function() vscode.action("editor.action.goToTypeDefinition") end)
    keymap("n", "grr", function() vscode.action("editor.action.goToReferences") end)
    keymap("n", "gri", function() vscode.action("editor.action.goToImplementation") end)
    keymap("n", "grn", function() vscode.action("editor.action.rename") end)
    keymap("n", "gra", function() vscode.action("editor.action.sourceAction") end)
    keymap("n", "grf", function() vscode.action("editor.action.formatDocument") end)

    keymap("n", "<SPACE>ss", function() vscode.action("workbench.action.gotoSymbol") end)
    keymap("n", "<SPACE>sS", function() vscode.action("workbench.action.showAllSymbols") end)
end

keymap("n", "J", "mzJ`z") -- Join next without moving cursor

local opt = vim.opt

-- Set up cursor color and shape in various modes
opt.guicursor = "i:block"

opt.shadafile = "NONE"
opt.ignorecase = true
opt.smartcase = true

vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_pythonx_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1

vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1

vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1

vim.g.loaded_2html_plugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_shada_plugin = 1

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_netrwSettings = 1

vim.g.loaded_fzf = 1
vim.g.loaded_fzf_vim = 1

vim.g.loaded_tutor = 1
vim.g.loaded_tutor_mode_plugin = 1

vim.g.loaded_spellfile_plugin = 1

vim.g.loaded_syntax = 1
vim.g.loaded_synmenu = 1
vim.g.loaded_optwin = 1
vim.g.loaded_compiler = 1
vim.g.loaded_bugreport = 1
vim.g.loaded_ftplugin = 1

vim.g.did_install_default_menus = 1
vim.g.loaded_sql_completion = 1
vim.g.loaded_spec = 1
vim.g.loaded_man = 1
vim.g.load_black = 1
vim.g.loaded_gtags = 1
vim.g.loaded_gtags_cscope = 1

-- -- Create a new augroup to group the autocommands
-- local augroup = vim.api.nvim_create_augroup("TextChangedGroup", { clear = true })
--
-- -- Define the autocommand
-- vim.api.nvim_create_autocmd("TextChanged", {
--     group = augroup,
--     callback = function()
--         local buf = vim.api.nvim_get_current_buf()
--         local has_parser = pcall(vim.treesitter.get_parser, buf)
--
--         if has_parser then
--             local parser = vim.treesitter.get_parser(buf)
--             parser:parse()
--         end
--     end,
-- })

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
    {
        "windwp/nvim-autopairs",
        config = function()
            local autopairs = require("nvim-autopairs")
            autopairs.setup({ map_c_h = true })
        end,
    },
    {
        "echasnovski/mini.surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        opts = {
            mappings = {
                add = "gsa",            -- Add surrounding in Normal and Visual modes
                delete = "gsd",         -- Delete surrounding
                find = "gsf",           -- Find surrounding (to the right)
                find_left = "gsF",      -- Find surrounding (to the left)
                highlight = "gsh",      -- Highlight surrounding
                replace = "gsr",        -- Replace surrounding
                update_n_lines = "gsn", -- Update `n_lines`
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = { "BufReadPost", "BufNewFile" },
        branch = "main",
        opts = {
            select = {
                lookahead = true,
                include_surrounding_whitespace = true,
                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "<c-v>",
                },
            },
            move = {
                set_jumps = true,
            },
        },
        config = function(_, opts)
            require("nvim-treesitter-textobjects").setup(opts)

            -- Select
            local select = require("nvim-treesitter-textobjects.select").select_textobject
            local keymap = vim.keymap.set
            local modes = { "x", "o" }

            keymap(modes, "a=", function() select("@assignment.outer", "textobjects") end, { desc = "outer assignment" })
            keymap(modes, "i=", function() select("@assignment.inner", "textobjects") end, { desc = "inner assignment" })

            keymap(modes, "aa", function() select("@parameter.outer", "textobjects") end, { desc = "outer parameter" })
            keymap(modes, "ia", function() select("@parameter.inner", "textobjects") end, { desc = "inner parameter" })

            keymap(modes, "aj", function() select("@conditional.outer", "textobjects") end,
                { desc = "outer conditional" })
            keymap(modes, "ij", function() select("@conditional.inner", "textobjects") end,
                { desc = "inner conditional" })

            keymap(modes, "ao", function() select("@loop.outer", "textobjects") end, { desc = "outer loop" })
            keymap(modes, "io", function() select("@loop.inner", "textobjects") end, { desc = "inner loop" })

            keymap(modes, "ab", function() select("@block.outer", "textobjects") end, { desc = "outer block" })
            keymap(modes, "ib", function() select("@block.inner", "textobjects") end, { desc = "inner block" })

            keymap(modes, "af", function() select("@function.outer", "textobjects") end, { desc = "outer function" })
            keymap(modes, "if", function() select("@function.inner", "textobjects") end, { desc = "inner function" })

            keymap(modes, "ac", function() select("@class.outer", "textobjects") end, { desc = "outer class" })
            keymap(modes, "ic", function() select("@class.inner", "textobjects") end, { desc = "inner class" })

            keymap(modes, "ar", function() select("@return.outer", "textobjects") end, { desc = "outer return" })
            keymap(modes, "ir", function() select("@return.inner", "textobjects") end, { desc = "inner return" })

            keymap(modes, "a/", function() select("@comment.outer", "textobjects") end, { desc = "outer comment" })
            keymap(modes, "i/", function() select("@comment.inner", "textobjects") end, { desc = "inner comment" })

            -- Swap
            local swap = require("nvim-treesitter-textobjects.swap")

            vim.keymap.set("n", "<leader>csn", function() swap.swap_next("@parameter.inner") end,
                { desc = "Swap with next param" })
            vim.keymap.set("n", "<leader>csp", function() swap.swap_previous("@parameter.inner") end,
                { desc = "Swap with prev param" })

            -- Move
            local move = require("nvim-treesitter-textobjects.move")
            local move_modes = { "n", "x", "o" }

            -- Goto next start
            keymap(move_modes, "]a", function() move.goto_next_start("@parameter.outer", "textobjects") end,
                { desc = "Next arg start" })
            keymap(move_modes, "]f", function() move.goto_next_start("@function.outer", "textobjects") end,
                { desc = "Next func start" })
            keymap(move_modes, "]r", function() move.goto_next_start("@return.outer", "textobjects") end,
                { desc = "Next return start" })
            keymap(move_modes, "]c", function() move.goto_next_start("@class.outer", "textobjects") end,
                { desc = "Next class start" })
            keymap(move_modes, "]j", function() move.goto_next_start("@conditional.outer", "textobjects") end,
                { desc = "Next cond start" })
            keymap(move_modes, "]o", function() move.goto_next_start("@loop.outer", "textobjects") end,
                { desc = "Next loop start" })
            keymap(move_modes, "]/", function() move.goto_next_start("@comment.outer", "textobjects") end,
                { desc = "Next loop start" })

            -- Goto next end
            keymap(move_modes, "]A", function() move.goto_next_end("@parameter.outer", "textobjects") end)
            keymap(move_modes, "]F", function() move.goto_next_end("@function.outer", "textobjects") end)
            keymap(move_modes, "]R", function() move.goto_next_end("@return.outer", "textobjects") end)
            keymap(move_modes, "]C", function() move.goto_next_end("@class.outer", "textobjects") end)
            keymap(move_modes, "]J", function() move.goto_next_end("@conditional.outer", "textobjects") end)
            keymap(move_modes, "]O", function() move.goto_next_end("@loop.outer", "textobjects") end)

            -- Goto previous start
            keymap(move_modes, "[a", function() move.goto_previous_start("@parameter.outer", "textobjects") end)
            keymap(move_modes, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
            keymap(move_modes, "[r", function() move.goto_previous_start("@return.outer", "textobjects") end)
            keymap(move_modes, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end)
            keymap(move_modes, "[j", function() move.goto_previous_start("@conditional.outer", "textobjects") end)
            keymap(move_modes, "[o", function() move.goto_previous_start("@loop.outer", "textobjects") end)
            keymap(move_modes, "[/", function() move.goto_previous_start("@comment.outer", "textobjects") end)

            -- Goto previous end
            keymap(move_modes, "[A", function() move.goto_previous_end("@parameter.outer", "textobjects") end)
            keymap(move_modes, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end)
            keymap(move_modes, "[R", function() move.goto_previous_end("@return.outer", "textobjects") end)
            keymap(move_modes, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end)
            keymap(move_modes, "[J", function() move.goto_previous_end("@conditional.outer", "textobjects") end)
            keymap(move_modes, "[O", function() move.goto_previous_end("@loop.outer", "textobjects") end)

            local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

            -- Repeat movement with ; and , vim way
            keymap(move_modes, ";", ts_repeat_move.repeat_last_move)
            keymap(move_modes, ",", ts_repeat_move.repeat_last_move_opposite)

            -- Make builtin f, F, t, T also repeatable with ; and ,
            keymap(move_modes, "f", ts_repeat_move.builtin_f_expr, { expr = true })
            keymap(move_modes, "F", ts_repeat_move.builtin_F_expr, { expr = true })
            keymap(move_modes, "t", ts_repeat_move.builtin_t_expr, { expr = true })
            keymap(move_modes, "T", ts_repeat_move.builtin_T_expr, { expr = true })
        end,
    },
})
