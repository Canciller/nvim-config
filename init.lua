require('canciller.options')
require('canciller.keymaps')
require('canciller.autocmds')
require('canciller.commands')

vim.lsp.enable('lua_ls')
-- vim.lsp.enable('ts_ls')
vim.lsp.enable('tsgo')
vim.lsp.enable('tailwindcss')

-- require('canciller.load_test_lsp')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: Plugins can also be configured to run lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup({
        icons = {
          mappings = false,
        },
      })

      -- Document existing key chains
      require('which-key').add({
        { '<leader>c', group = '[C]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>r', group = '[R]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[S]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>sn', group = '[S]earch [N]o ignore' },
        { '<leader>sn_', hidden = true },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>w_', hidden = true },
        { '<leader>g', group = '[G]it' },
        { '<leader>g_', hidden = true },
      })
    end,
  },

  -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup({ n_lines = 500 })
    end,
  },

  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  {
    'gbprod/substitute.nvim',
    enabled = false,
    config = function()
      require('substitute').setup({})

      vim.keymap.set('n', 's', require('substitute').operator, { noremap = true })
      vim.keymap.set('n', 'ss', require('substitute').line, { noremap = true })
      vim.keymap.set('n', 'S', require('substitute').eol, { noremap = true })
      vim.keymap.set('x', 's', require('substitute').visual, { noremap = true })
    end,
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
  -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    'tris203/precognition.nvim',
    opts = {},
  },

  {
    'knubie/vim-kitty-navigator',
  },

  {
    'yorickpeterse/nvim-pqf',
    config = function()
      require('pqf').setup({
        signs = {
          error = 'E',
          warning = 'W',
          hint = 'H',
          info = 'I',
        },
      })
    end,
  },

  {
    dir = '~/Projects/typescript-type-checker.nvim',
    opts = {},
  },
  -- {
  --   'Canciller/typescript-type-checker.nvim',
  --   opts = {},
  -- },

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
  --
  --  Here are some example plugins that I've included in the kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/canciler/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/canciller/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'canciller.plugins' },
}, {
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  change_detection = {
    notify = false,
  },
})
