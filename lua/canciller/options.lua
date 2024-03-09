local o = vim.opt

-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

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

o.breakindent = true -- Enable break indent
o.autoindent = true -- Continue indentation to new line
o.smartindent = true -- Add extra indent when it makes sense
o.smarttab = true -- <tab> at the start of a line behaves as expected
o.expandtab = true -- <tab> inserts spaces
o.shiftwidth = 2 -- >>, << shift line by 2 spaces
o.tabstop = 2 -- <tab> appears as 2 spaces
o.softtabstop = 2 -- <tab> behaves as 2 spaces when editing
o.shiftround = true

-- Save undo history
o.undofile = true

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

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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
