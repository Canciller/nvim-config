return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				sourcekit = {},
			},
			setup = {
				sourcekit = function(_, opts)
					require("lspconfig").sourcekit.setup(opts)
				end,
			},
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = function(_, opts)
			local nls = require("null-ls")
			table.insert(opts.sources, nls.builtins.formatting.swiftformat)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "swift" })
			end
		end,
	},
}
