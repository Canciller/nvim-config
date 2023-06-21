return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        jsonls = {},
      },
      setup = {
        jsonls = function(_, opts)
          require('lspconfig').jsonls.setup(opts)
        end,
      },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.formatting.prettierd)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'json' })
      end
    end,
  },
}
