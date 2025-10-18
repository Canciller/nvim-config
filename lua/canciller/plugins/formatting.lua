return { -- Autoformat
  'stevearc/conform.nvim',
  config = function()
    require('conform').setup({
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 60000, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'eslint_d', 'prettierd', stop_after_first = false },
        javascriptreact = { 'eslint_d', 'prettierd', stop_after_first = false },
        typescript = { 'eslint_d', 'prettierd', stop_after_first = false },
        typescriptreact = { 'eslint_d', 'prettierd', stop_after_first = false },
        html = { 'prettierd' },
        css = { 'prettierd' },
        vue = { 'eslint_d', 'prettierd', stop_after_first = false },
      },
    })
  end,
}
