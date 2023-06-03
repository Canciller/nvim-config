return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = false,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		version = false,
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
			"windwp/nvim-ts-autotag",
			-- 'mrjones2014/nvim-ts-rainbow',
		},
		opts = {
			highlight = {
				enable = true,
				disable = function(lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local js_max_filesize = 50 * 1024 -- 50 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if
						ok
						and stats
						and (stats.size > max_filesize or lang == "js" and stats.size > js_max_filesize)
					then
						return true
					end
				end,
			},
			indent = {
				enable = true,
			},
			ensure_installed = {
				"vim",
				"comment",
				"help",
				"lua",
				"tsx",
				"typescript",
				"javascript",
				"json",
				"css",
				"html",
				"markdown",
				"markdown_inline",
				"regex",
				"bash",
				"rust",
				"toml",
			},
			context_commentstring = {
				enable = true,
				enable_autocmd = false,
			},
			autotag = {
				enable = true,
			},
			--[[ rainbow = {
				enable = true,
			}, ]]
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
