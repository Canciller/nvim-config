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
						-- initial_mode = "normal",
						layout_config = {
							height = 0.5,
						},
					}),
				},
			}
		end,
	},
	{
		"windwp/nvim-spectre",
		opts = {
			result_padding = "│  ",
			live_update = false,
			highlight = {
				ui = "String",
				-- search = "IncSearch",
				search = "DiagnosticVirtualTextWarn",
				-- replace = "Substitute",
				replace = "DiagnosticVirtualTextHint",
			},
		},
		init = function()
			vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
				desc = "Search current word",
			})
		end,
		keys = {
			{
				"<leader>sr",
				function()
					require("spectre").open()
				end,
				desc = "Replace in files (Spectre)",
			},
			{
				"<leader>sw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search current word (Spectre)",
			},
		},
	},
	{
		"nvim-zh/colorful-winsep.nvim",
		enabled = false,
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
		enabled = false,
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
