return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        tailwindcss = {},
        eslint = {
          settings = {
            format = false,
          },
        },
        cssls = {},
      },
      setup = {
        tailwindcss = function(_, opts)
          require('lspconfig').tailwindcss.setup(opts)
        end,
        eslint = function(_, opts)
          require('lspconfig').eslint.setup(opts)
        end,
        cssls = function(_, opts)
          require('lspconfig').cssls.setup(opts)
        end,
      },
    },
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      settings = {
        expose_as_code_action = {
          'fix_all',
          'add_missing_imports',
          'remove_unused',
          'remove_unused_imports',
          'organize_imports',
        },
      },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.formatting.eslint_d)

      table.insert(opts.sources, nls.builtins.formatting.rustywind)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'typescript', 'tsx', 'javascript', 'css', 'scss', 'html' })
      end
    end,
  },
}
