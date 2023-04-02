return {
	{
		"stevearc/dressing.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		lazy = true,
		init = function()
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end

			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
		opts = function()
			return {
				input = {
					start_in_insert = true,
					mappings = {
						n = {
							["q"] = "Close",
						},
					},
				},
				select = {
					telescope = require("telescope.themes").get_cursor({
						initial_mode = "normal",
					}),
				},
			}
		end,
	},
	{
		"windwp/nvim-spectre",
		opts = {
			highlight = {
				ui = "String",
				search = "IncSearch",
				replace = "Substitute",
			},
		},
		keys = {
			{
				"<leader>sr",
				function()
					require("spectre").open()
				end,
				desc = "Replace in files (Spectre)",
			},
		},
	},
	{
		"nvim-zh/colorful-winsep.nvim",
		opts = {
			highlight = {
				bg = "#16161E",
				fg = "#1F3442",
			},
			-- timer refresh rate
			interval = 30,
		},
		event = { "WinNew" },
	},
	{
		"anuvyklack/windows.nvim",
		dependencies = {
			"anuvyklack/middleclass",
			"anuvyklack/animation.nvim",
		},
		opts = {
			autowidth = { enable = true },
			ignore = {
				filetype = { "neo-tree", "lazy", "noice" },
			},
		},
	},
}
