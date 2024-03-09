local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup('canciller-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

autocmd('BufEnter', {
  desc = "Don't auto comment new lines",
  pattern = '',
  command = 'set fo-=c fo-=r fo-=o',
})

autocmd('QuickFixCmdPost', {
  nested = true,
  pattern = '[^l]*',
  command = 'cwindow',
})

local ts_group = augroup('canciller-typescript', { clear = true })

autocmd({ 'BufNewFile', 'BufRead' }, {
  desc = 'Set typescriptreact filetype on react hook files',
  group = ts_group,
  pattern = 'use*.ts',
  command = 'setlocal filetype=typescriptreact',
})

autocmd({ 'BufNewFile', 'BufRead' }, {
  desc = 'Set jsonc filetype on tsconfig.json file',
  group = ts_group,
  pattern = { 'tsconfig.json', 'tsconfig.*.json' },
  command = 'setlocal filetype=jsonc',
})
