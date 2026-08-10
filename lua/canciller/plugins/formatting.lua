return {
  'stevearc/conform.nvim',
  config = function()
    local typescriptFormatters = function()
      local biomeRoot = vim.fs.root(0, 'biome.json')
      if biomeRoot then
        return { 'biome-check', 'biome-organize-imports' }
      end

      local eslintRoot = vim.fs.root(0, '.eslintrc.json')

      if eslintRoot then
        return { 'eslint_d' }
      end

      return {}
    end

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
        typescriptreact = typescriptFormatters,
        typescript = typescriptFormatters,
        javascriptreact = typescriptFormatters,
        javascript = typescriptFormatters,
        html = { 'prettierd' },
        css = { 'prettierd' },
      },
    })
  end,
}
