return {
  {
    'zbirenbaum/copilot.lua',
    enabled = false,
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          -- Only works on macOS
          accept = '<D-y>',
          next = '<D-]>',
          prev = '<D-[>',
        },
      },
      panel = {
        enabled = true,
      },
    },
  },
  {
    'github/copilot.vim',
    enabled = false,
    cmd = 'Copilot',
    event = 'InsertEnter',
    keys = {
      { '<D-]>', '<Plug>(copilot-next)', mode = 'i', desc = 'Next Copilot suggestion' },
      { '<D-[>', '<Plug>(copilot-previous)', mode = 'i', desc = 'Previous Copilot suggestion' },
    },
  },
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup({})
    end,
  },
}
