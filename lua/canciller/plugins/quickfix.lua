return {
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
  },
  {
    'yorickpeterse/nvim-pqf',
    config = function()
      require('pqf').setup({
        signs = {
          error = 'E',
          warning = 'W',
          hint = 'H',
          info = 'I',
        },
      })
    end,
  },
}
