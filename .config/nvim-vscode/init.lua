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

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
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
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        branch = "main",
        config = function()
            require('nvim-treesitter').install({ 'rust', 'go', 'c', 'cpp', 'python' })

            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

            -- Enable highlight
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'python', 'go' },
                callback = function() vim.treesitter.start() end,
            })
        end
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

            keymap(modes, "an", function() select("@return.outer", "textobjects") end, { desc = "outer return" })
            keymap(modes, "in", function() select("@return.inner", "textobjects") end, { desc = "inner return" })

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
            keymap(move_modes, "]n", function() move.goto_next_start("@return.outer", "textobjects") end,
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
            keymap(move_modes, "]N", function() move.goto_next_end("@return.outer", "textobjects") end)
            keymap(move_modes, "]C", function() move.goto_next_end("@class.outer", "textobjects") end)
            keymap(move_modes, "]J", function() move.goto_next_end("@conditional.outer", "textobjects") end)
            keymap(move_modes, "]O", function() move.goto_next_end("@loop.outer", "textobjects") end)

            -- Goto previous start
            keymap(move_modes, "[a", function() move.goto_previous_start("@parameter.outer", "textobjects") end)
            keymap(move_modes, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
            keymap(move_modes, "[n", function() move.goto_previous_start("@return.outer", "textobjects") end)
            keymap(move_modes, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end)
            keymap(move_modes, "[j", function() move.goto_previous_start("@conditional.outer", "textobjects") end)
            keymap(move_modes, "[o", function() move.goto_previous_start("@loop.outer", "textobjects") end)
            keymap(move_modes, "[/", function() move.goto_previous_start("@comment.outer", "textobjects") end)

            -- Goto previous end
            keymap(move_modes, "[A", function() move.goto_previous_end("@parameter.outer", "textobjects") end)
            keymap(move_modes, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end)
            keymap(move_modes, "[N", function() move.goto_previous_end("@return.outer", "textobjects") end)
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

            if vim.g.vscode then
                local make_repeatable_move_pair = function(forward_move_fn, backward_move_fn)
                    local general_repeatable_move_fn = function(opts_, ...)
                        if opts_.forward then
                            forward_move_fn(...)
                        else
                            backward_move_fn(...)
                        end
                    end

                    local repeatable_forward_move_fn = function(...)
                        ts_repeat_move.last_move = { func = general_repeatable_move_fn, opts = { forward = true }, additional_args = { ... } }
                        forward_move_fn(...)
                    end

                    local repeatable_backward_move_fn = function(...)
                        ts_repeat_move.last_move = { func = general_repeatable_move_fn, opts = { forward = false }, additional_args = { ... } }
                        backward_move_fn(...)
                    end

                    return repeatable_forward_move_fn, repeatable_backward_move_fn
                end

                local vscode = require("vscode-neovim")

                -- Make ]h, [h also repeatable with ; and ,
                local next_hunk = function() vscode.action("workbench.action.editor.nextChange") end
                local prev_hunk = function() vscode.action("workbench.action.editor.previousChange") end
                local next_hunk_repeat, prev_hunk_repeat = make_repeatable_move_pair(next_hunk, prev_hunk)
                keymap(move_modes, "]h", next_hunk_repeat, { desc = "Next Hunk" })
                keymap(move_modes, "[h", prev_hunk_repeat, { desc = "Prev Hunk" })

                -- Make ]d, [d also repeatable with ; and ,
                local next_diag = function() vscode.action("editor.action.marker.next") end
                local prev_diag = function() vscode.action("editor.action.marker.prev") end
                local next_diag_repeat, prev_diag_repeat = make_repeatable_move_pair(next_diag, prev_diag)
                keymap(move_modes, "]d", next_diag_repeat, { desc = "Next Diagnostic" })
                keymap(move_modes, "[d", prev_diag_repeat, { desc = "Prev Diagnostic" })

                -- Make ]r, [r also repeatable with ; and ,
                local next_rf = function() vscode.action("editor.action.wordHighlight.next") end
                local prev_rf = function() vscode.action("editor.action.wordHighlight.prev") end
                local next_rf_repeat, prev_rf_repeat = make_repeatable_move_pair(next_rf, prev_rf)
                keymap(move_modes, "]r", next_rf_repeat, { desc = "Next Reference" })
                keymap(move_modes, "[r", prev_rf_repeat, { desc = "Prev Reference" })
            end
        end,
    },
})
