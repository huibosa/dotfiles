local keymap = function(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", {
		noremap = true,
		silent = true,
	}, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

keymap("x", "Y", '"+y')
keymap("n", "c*", "*Ncgn")

keymap({ "n", "x" }, "H", "^")
keymap({ "n", "x" }, "L", "$")

-- Moving highlighted line in visual mode
keymap("v", "K", ":m '<-2<CR>gv=gv")
keymap("v", "J", ":m '>+1<CR>gv=gv")

-- Join next without moving cursor
keymap("n", "J", "mzJ`z")

keymap("n", "gd", "<CMD>lua require('vscode').call('editor.action.peekDefinition')<CR>")
keymap("n", "gD", "<CMD>lua require('vscode').call('editor.action.peekDeclaration')<CR>")
keymap("n", "gy", "<CMD>lua require('vscode').call('editor.action.peekTypeDefinition')<CR>")
keymap("n", "gr", "<CMD>lua require('vscode').call('editor.action.goToReferences')<CR>")
keymap("n", "gI", "<CMD>lua require('vscode').call('editor.action.peekImplementation')<CR>")

keymap("n", "<SPACE>ss", "<CMD>lua require('vscode').call('workbench.action.gotoSymbol')<CR>")
keymap("n", "<SPACE>sS", "<CMD>lua require('vscode').call('workbench.action.showAllSymbols')<CR>")

keymap("n", "<SPACE>cr", "<CMD>lua require('vscode').call('editor.action.rename')<CR>")
keymap("n", "<SPACE>ca", "<CMD>lua require('vscode').call('editor.action.sourceAction')<CR>")
keymap("n", "<SPACE>cf", "<CMD>lua require('vscode').call('editor.action.formatDocument')<CR>")

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

-- Create a new augroup to group the autocommands
local augroup = vim.api.nvim_create_augroup("TextChangedGroup", { clear = true })

-- Define the autocommand
vim.api.nvim_create_autocmd("TextChanged", {
	group = augroup,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local has_parser = pcall(vim.treesitter.get_parser, buf)

		if has_parser then
			local parser = vim.treesitter.get_parser(buf)
			parser:parse()
		end
	end,
})

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
		dependencies = { "nvim-treesitter/nvim-treesitter" },
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

							-- ["a/"] = { query = "@comment.outer", desc = "outer comment" },
							-- ["i/"] = { query = "@comment.inner", desc = "inner comment" },
						},
						include_surrounding_whitespace = true,
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
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
		end,
	},
})
