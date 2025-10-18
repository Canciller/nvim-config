return {
  'zbirenbaum/copilot.lua',
  enabled = true,
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
}
