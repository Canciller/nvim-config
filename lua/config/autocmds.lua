local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
  end,
})

-- Remove whitespace on save
autocmd('BufWritePre', {
  pattern = '',
  command = ':%s/\\s\\+$//e',
})

-- Don't auto comment new lines
autocmd('BufEnter', {
  pattern = '',
  command = 'set fo-=c fo-=r fo-=o',
})

-- Save folds on write and restore on open
augroup('RememberFolds', { clear = true })
autocmd('BufWinLeave', {
  group = 'RememberFolds',
  pattern = '*.*',
  command = 'mkview',
})
autocmd('BufWinEnter', {
  group = 'RememberFolds',
  pattern = '*.*',
  command = 'silent! loadview',
})

-- Typescript
augroup('TypescriptCompiler', { clear = true })
autocmd('FileType', {
  group = 'TypescriptCompiler',
  pattern = { 'typescript', 'typescriptreact' },
  command = 'compiler tsc',
})

augroup('ReactHooksTypescript', { clear = true })
autocmd({ 'BufNewFile', 'BufRead' }, {
  group = 'ReactHooksTypescript',
  pattern = 'use*.ts',
  command = 'setlocal filetype=typescriptreact',
})

augroup('TsconfigJsonc', { clear = true })
autocmd({ 'BufNewFile', 'BufRead' }, {
  group = 'TsconfigJsonc',
  pattern = { 'tsconfig.json', 'tsconfig.*.json' },
  command = 'setlocal filetype=jsonc',
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspInlayHintConfig', { clear = true }),
  callback = function(e)
    local bufnr = e.buf
    local client = vim.lsp.get_client_by_id(e.data.client_id)

    if client.supports_method('textDocument/inlayHint') then
      vim.api.nvim_create_autocmd('InsertEnter', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.inlay_hint(bufnr, true)
        end,
      })

      vim.api.nvim_create_autocmd('InsertLeave', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.inlay_hint(bufnr, false)
        end,
      })
    end
  end,
})
