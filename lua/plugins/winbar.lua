return {
  {
    'utilyre/barbecue.nvim',
    name = 'barbecue',
    enabled = true,
    -- version = '*',
    dependencies = {
      'SmiteshP/nvim-navic',
      'nvim-tree/nvim-web-devicons', -- optional dependency
    },
    opts = {
      -- configurations go here
    },
    init = function()
      vim.g.navic_silence = true
    end,
  },
}
