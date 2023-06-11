return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"ray-x/lsp_signature.nvim",
			"jose-elias-alvarez/null-ls.nvim",
		},
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				severity_sort = true,
				virtual_text = false,
				virtual_lines = false,
				update_in_insert = false,
				float = {
					border = "rounded",
				},
			},
		},
		config = function(_, opts)
			-- diagnostics

			local signs = {
				Error = "E",
				Warn = "W",
				Hint = "H",
				Info = "I",
			}

			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = opts.diagnostics.float.border,
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = opts.diagnostics.float.border,
			})

			vim.diagnostic.config(opts.diagnostics)

			-- servers

			-- local capabilities =
			-- 	require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- this fucking line made jsx props to not be listed in cmp!!
			-- capabilities.textDocument.completion.completionItem.snippetSupport = false

			for name, server_opts_or_empty in pairs(opts.servers) do
				local server_opts = server_opts_or_empty or {}

				local final_server_opts = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						-- Format on save
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = vim.api.nvim_create_augroup("LspFormatting", {}),
							callback = function()
								local buf = vim.api.nvim_get_current_buf()

								vim.lsp.buf.format({
									filter = function(c)
										return c.name == "null-ls"
									end,
									bufnr = buf,
								})
							end,
						})

						-- LSP signature
						require("lsp_signature").on_attach({
							bind = true, -- This is mandatory, otherwise border config won't get registered.
							handler_opts = {
								border = "rounded",
							},
							hint_prefix = " ",
							hint_enable = false,
							hi_parameter = "IncSearch",
						}, bufnr)

						--[[ if base_server_opts.inlay_hints then
							require("lsp-inlayhints").on_attach(client, bufnr)
						end ]]

						if server_opts.on_attach then
							server_opts.on_attach(client, bufnr)
						end
					end,
				}, server_opts)

				opts.setup[name](name, final_server_opts)
			end
		end,
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local nls = require("null-ls")
			return {
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
				sources = {
					nls.builtins.formatting.shfmt,
					nls.builtins.code_actions.gitsigns,
					nls.builtins.diagnostics.todo_comments,
				},
			}
		end,
	},
	{
		"j-hui/fidget.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
	--[[ {
		"lvimuser/lsp-inlayhints.nvim",
		lazy = false,
		opts = {
			inlay_hints = {
				parameter_hints = {
					show = true,
					prefix = "<- ",
					separator = ", ",
					remove_colon_start = false,
					remove_colon_end = true,
				},
				type_hints = {
					-- type and other hints
					show = true,
					prefix = "=> ",
					separator = ", ",
					remove_colon_start = true,
					remove_colon_end = false,
				},
				only_current_line = false,
				-- separator between types and parameter hints. Note that type hints are
				-- shown before parameter
				labels_separator = " ",
				-- whether to align to the length of the longest line in the file
				max_len_align = false,
				-- padding from the left if max_len_align is true
				max_len_align_padding = 1,
				-- highlight group
				highlight = "LspInlayHint",
				-- virt_text priority
				priority = 0,
			},
		},
	}, ]]
}
