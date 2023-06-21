return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'jose-elias-alvarez/typescript.nvim' },
    opts = {
      servers = {
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        tailwindcss = {},
      },
      setup = {
        tsserver = function(_, opts)
          require('typescript').setup({
            disable_commands = false, -- prevent the plugin from creating Vim commands
            debug = false, -- enable debug logging for commands
            go_to_source_definition = {
              fallback = true, -- fall back to standard LSP definition on failure
            },
            server = opts,
          })
        end,
        tailwindcss = function(_, opts)
          require('lspconfig').tailwindcss.setup(opts)
        end,
      },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(
        opts.sources,
        nls.builtins.diagnostics.eslint_d.with({
          diagnostics_format = '[eslint] #{m}\n(#{c})',
        })
      )
      table.insert(opts.sources, nls.builtins.code_actions.eslint_d)
      table.insert(opts.sources, nls.builtins.formatting.eslint_d)
      table.insert(opts.sources, nls.builtins.formatting.prettierd)

      table.insert(opts.sources, require('typescript.extensions.null-ls.code-actions'))
      table.insert(opts.sources, nls.builtins.diagnostics.tsc)

      table.insert(opts.sources, nls.builtins.formatting.rustywind)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'typescript', 'tsx', 'javascript', 'css', 'html' })
      end
    end,
  },
}
