-- NOTE: If clipboard is not working in windows, make sure to install win32yank from https://github.com/equalsraf/win32yank

local o = vim.opt

o.shortmess:append({ I = true })

-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Disable format on save (./plugins/formatting.lua)
vim.g.disable_autoformat = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

o.termguicolors = true
o.background = 'dark'

o.number = true
o.relativenumber = true
o.numberwidth = 5

-- Enable mouse mode, can be useful for resizing splits for example!
o.mouse = 'a'

-- Don't show the mode, since it's already in status line
o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
o.clipboard = 'unnamedplus'

-- Case-insensitive searching UNLESS \C or capital in search
o.ignorecase = true
o.smartcase = true

-- Keep signcolumn on by default
o.signcolumn = 'yes'

-- Decrease update time
o.updatetime = 250
o.timeoutlen = 300

-- Configure how new splits should be opened
o.splitright = true
o.splitbelow = true

o.inccommand = 'split' -- Preview substitutions live, as you type!

o.cursorline = true -- Show which line your cursor is on

o.scrolloff = 10 -- Keep 10 lines visible while scrolling
o.sidescrolloff = 15
o.sidescroll = 1

o.title = true
o.titlestring = '%t %m'

o.autowrite = true -- Write open buffers on :make

o.undofile = false -- Don't keep track of my undo's between sessions
o.swapfile = false -- No swap files

o.hlsearch = true
o.signcolumn = 'yes'
o.ignorecase = false

o.foldlevel = 99
o.foldlevelstart = 99

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Default indentation settings.
-- These apply unless overridden by a filetype plugin, .editorconfig,
-- or a project-specific configuration.

o.breakindent = true -- Wrapped lines keep the indentation of the original line.
o.autoindent = true -- New lines inherit the indentation of the previous line.
o.smartindent = true -- Increase indentation automatically for common language constructs.
o.smarttab = true -- At the start of a line, <Tab> uses 'shiftwidth' instead of 'tabstop'.
o.expandtab = true -- Insert spaces instead of literal tab characters.
o.shiftround = true -- Round indentation to the nearest multiple of 'shiftwidth'.
o.shiftwidth = 4 -- Indentation width (used by >>, <<, auto-indent, =, and LSP formatting).
o.tabstop = 4 -- Display width of literal tab ('\t') characters.
o.softtabstop = 4 -- Number of spaces <Tab>/<BS> inserts or removes while editing.
