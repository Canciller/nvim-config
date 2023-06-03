local cmd = vim.cmd

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = ","

cmd(":command! WQ wq")
cmd(":command! Wq wq")
cmd(":command! W w")
cmd(":command! Q q")

-- disable arrow keys
map("", "<up>", "<nop>")
map("", "<down>", "<nop>")
map("", "<left>", "<nop>")
map("", "<right>", "<nop>")

-- disable esc in insert mode
-- map('i', '<esc>', '<nop>')

-- enter normal mode in insert mode
map("i", "jk", "<esc>")
-- map('v', 'jk', '<esc>')
map("c", "jk", "<c-c>")

map("t", "jk", "<C-\\><C-n>")

-- ctrl+] not working on latam keybord
map("n", "<c-+>", "<c-]>")

-- split movement
map("n", "<c-h>", "<c-w>h")
map("n", "<c-l>", "<c-w>l")
map("n", "<c-j>", "<c-w>j")
map("n", "<c-k>", "<c-w>k")

-- split resize
map("n", "<up>", ":res -5<cr>")
map("n", "<down>", ":res +5<cr>")
map("n", "<left>", ":vertical res -5<cr>")
map("n", "<right>", ":vertical res +5<cr>")

-- tab movement
map("n", "<tab>", ":tabn<cr>")
map("n", "<s-tab>", ":tabp<cr>")

-- move to end/start of line
map("n", "L", "$")
map("n", "H", "0")

-- disable hlsearch
map("n", "<esc><esc>", ":nohlsearch<cr>")

-- enter normal mode in terminal
map("t", "<esc>", "<c-\\><c-n>")

-- reload configuration
map("n", "<leader>r", ":so %<cr>")

-- open keymaps.lua in new tab
map("n", "<leader>gk", ":tabedit $CONFIG/nvim/lua/keymaps.lua<cr>")

-- open autocmds.lua in new tab
map("n", "<leader>ga", ":tabedit $CONFIG/nvim/lua/autocmds.lua<cr>")

-- open options.lua in new tab
map("n", "<leader>go", ":tabedit $CONFIG/nvim/lua/options.lua<cr>")

-- record macro
map("n", "q", "<nop>")
map("n", "<leader>q", "q")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		local o = {
			noremap = true,
			silent = true,
			buffer = ev.buf,
		}

		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
		vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", o)
		vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", o)

		vim.keymap.set("n", "K", vim.lsp.buf.hover, o)

		vim.keymap.set("n", "<f2>", vim.lsp.buf.rename, o)

		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
		vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, o)

		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)

		vim.keymap.set("n", "[e", function()
			vim.diagnostic.goto_prev({
				severity = vim.diagnostic.severity.ERROR,
			})
		end, o)
		vim.keymap.set("n", "]e", function()
			vim.diagnostic.goto_next({
				severity = vim.diagnostic.severity.ERROR,
			})
		end, o)
	end,
})
