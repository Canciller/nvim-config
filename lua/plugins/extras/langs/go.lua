return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'jose-elias-alvarez/typescript.nvim' },
    opts = {
      servers = {
        gopls = {},
      },
      setup = {
        gopls = function(_, opts)
          require('lspconfig').gopls.setup(opts)
        end,
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'go' })
      end
    end,
  },
}
