-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
  {
    'stevearc/oil.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    },
    init = function()
      vim.cmd([[nnoremap <silent> - :Oil<cr>]])
    end,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      {
        's1n7ax/nvim-window-picker',
        version = '2.*',
        event = 'VeryLazy',
        name = 'window-picker',
        opts = {
          show_prompt = false,
          fg_color = '#ededed',
          other_win_hl_color = '#e35e4f',
          use_winbar = 'always',
        },
      },
    },
    opts = {
      window = {
        auto_expand_width = true,
        position = 'left',
      },
      close_if_last_window = true,
      auto_clean_after_session_restore = true,
      event_handlers = {
        {
          event = 'neo_tree_buffer_enter',
          handler = function()
            vim.cmd([[
              setlocal relativenumber
            ]])
          end,
        },
        {
          event = 'file_opened',
          handler = function()
            -- Auto close on file opened
            require('neo-tree').close_all()
          end,
        },
      },
      filesystem = {
        hijack_netrw_behavior = 'disabled',
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
        },
      },
    },
    init = function()
      vim.cmd([[nnoremap <silent> \ :Neotree toggle<cr>]])
    end,
  },
}
