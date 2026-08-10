require('canciller.options')
require('canciller.keymaps')
require('canciller.autocmds')
require('canciller.commands')

-- TODO: Move lsp configs to separate file
--vim.lsp.log.set_level('trace') -- Uncomment to debug lsp requests/responses with `:LspLog`
vim.lsp.enable('lua_ls')
vim.lsp.enable('vtsls')
vim.lsp.enable('tailwindcss')
vim.lsp.enable('eslint')
vim.lsp.enable('biome')

if vim.env.JAVA_21_HOME then
    vim.uv.os_setenv('JAVA_HOME', vim.env.JAVA_21_HOME)
end

vim.lsp.enable('jdtls')

local csslsCapabilities = vim.lsp.protocol.make_client_capabilities()
csslsCapabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('cssls', {
  capabilities = csslsCapabilities,
})

vim.lsp.enable('cssls')

--Enable (broadcasting) snippet capability for completion
local jsonlsCapabilities = vim.lsp.protocol.make_client_capabilities()
jsonlsCapabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('jsonls', {
  capabilities = jsonlsCapabilities,
})

vim.lsp.enable('jsonls')

vim.lsp.config('graphql', {
  filetypes = { 'graphql', 'typescriptreact', 'javascriptreact', 'javascript', 'typescript' },
})
vim.lsp.enable('graphql')

-- require('canciller.load_test_lsp')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  -- 'tpope/vim-sleuth',

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
        { '<leader>gs', group = '[G]it [S]earch' },
        { '<leader>gs_', hidden = true },
        { '<leader>h', group = 'Git: [H]unk' },
        { '<leader>h_', hidden = true },
        { '<leader>y', group = '[Y]ank' },
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
    enabled = false,
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
    enabled = false,
    opts = {
      startVisible = false,
    },
  },

  -- {
  --   'gennaro-tedesco/nvim-jqx',
  --   event = { 'BufReadPost' },
  --   ft = { 'json', 'yaml' },
  -- },

  -- {
  --   'knubie/vim-kitty-navigator',
  -- },

  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim' },
        { path = '~/Projects/nvim-ts-context-commentstring' },
      },
    },
  },
  { import = 'canciller.plugins' },
}, {
  dev = {
    path = '~/Projects',
    fallback = true,
  },
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
