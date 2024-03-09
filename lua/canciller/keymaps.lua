local map = vim.keymap.set

-- Set highlight on search, but clear on pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Disable arrow keys in normal mode
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- map('i', '<esc>', '<nop>', { desc = 'Disable esc in insert mode' })
map('i', 'jk', '<esc>', { desc = 'Exit insert mode' })
map('c', 'jk', '<c-c>', { desc = 'Exit command mode' })
map('t', 'jk', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ctrl+] not working on latam keybord
map('n', '<c-+>', '<c-]>')

-- Tab movement
map('n', '<tab>', ':tabn<cr>', { silent = true, desc = 'Move to previous tab' })
map('n', '<s-tab>', ':tabp<cr>', { silent = true, desc = 'Move to next tab' })

-- Move to end/start of line
map('n', 'L', '$')
map('n', 'H', '0')

map('n', ']q', function()
  ---@diagnostic disable-next-line: param-type-mismatch
  pcall(vim.cmd, 'cnext')
end, {
  desc = 'Go to next [Q]uickfix item',
})

map('n', '[q', function()
  ---@diagnostic disable-next-line: param-type-mismatch
  pcall(vim.cmd, 'cprev')
end, {
  desc = 'Go to previous [Q]uickfix item',
})
