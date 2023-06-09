return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    opts = {
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
          handler = function(file_path)
            --auto close
            require('neo-tree').close_all()
          end,
        },
      },
      filesystem = {
        follow_current_file = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        mappings = {
          ['X'] = 'cut_to_clipboard',
          ['x'] = 'open_split',
          ['v'] = 'open_vsplit',
          ['t'] = 'open_tabnew',
        },
      },
      source_selector = {
        winbar = false,
        content_layout = 'center',
        sources = {
          { source = 'filesystem', display_name = ' 󰉓 Files ' },
          { source = 'git_status', display_name = ' 󰊢 Git ' },
        },
      },
      default_component_configs = {
        name = {
          use_git_status_colors = true,
        },
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        git_status = {
          symbols = {
            -- Change type
            added = '', -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = '', -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = '✖', -- this can only be used in the git_status source
            renamed = '', -- this can only be used in the git_status source
            -- Status type
            -- untracked = "U",
            untracked = '',
            -- unstaged = "",
            unstaged = ' ',
            -- staged = "A",
            staged = ' ',
            ignored = '',
            -- ignored = " ",
            -- conflict = "",
          },
        },
      },
    },
    init = function()
      vim.cmd([[nnoremap <silent> \ :Neotree<cr>]])
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    lazy = false,
    opts = {
      show_prompt = false,
      fg_color = '#ededed',
      other_win_hl_color = '#e35e4f',
      use_winbar = 'always',
    },
  },
}
