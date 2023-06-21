return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        severity_sort = true,
        virtual_text = false,
        virtual_lines = false,
        update_in_insert = false,
        float = {
          border = 'rounded',
        },
      },
    },
    config = function(_, opts)
      -- diagnostics

      local signs = {
        Error = ' ',
        Warn = ' ',
        Info = ' ',
        Hint = '💡',
      }

      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
      end

      vim.diagnostic.config(opts.diagnostics)

      -- servers
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      for name, server_opts_or_empty in pairs(opts.servers) do
        local server_opts = server_opts_or_empty or {}

        local final_server_opts = vim.tbl_deep_extend('force', {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            vim.lsp.buf.inlay_hint(bufnr, true)

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
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = function()
      local nls = require('null-ls')
      return {
        root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
        sources = {
          nls.builtins.formatting.shfmt,
          nls.builtins.code_actions.gitsigns,
          nls.builtins.diagnostics.todo_comments,
        },
      }
    end,
  },
  {
    'https://git.sr.ht/~nedia/auto-format.nvim',
    event = 'BufWinEnter',
    opts = {},
  },
}
