return {
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      -- char = "▏",
      char = '│',
      filetype_exclude = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy' },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    },
    config = function(opts)
      require('indent_blankline').setup(opts)
      -- See: https://github.com/lukas-reineke/indent-blankline.nvim/issues/489#issuecomment-1276972280
      vim.api.nvim_create_autocmd('CursorMoved', { command = 'IndentBlanklineRefresh' })
    end,
  },
  {
    'echasnovski/mini.indentscope',
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      -- symbol = "▏",
      symbol = '│',
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy', 'mason' },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
    config = function(_, opts)
      require('mini.indentscope').setup(opts)
    end,
  },
}
