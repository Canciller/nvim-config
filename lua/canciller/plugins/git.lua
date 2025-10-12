return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'FabijanZulj/blame.nvim',
    event = 'BufEnter',
    opts = {
      focus_blame = true,
    },
    keys = {
      { '<leader>gb', '<cmd>BlameToggle<cr>', desc = '[G]it [B]lame toggle window' },
    },
  },
}
