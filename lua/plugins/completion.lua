return {
  {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'onsails/lspkind.nvim',
      {
        'L3MON4D3/luasnip',
        build = (not jit.os:find('Windows'))
            and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
      },
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    opts = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')
      local luasnip = require('luasnip')

      luasnip.config.setup({
        history = true,
        delete_check_events = 'TextChanged',
      })

      require('luasnip.loaders.from_vscode').lazy_load()

      lspkind.init({
        preset = 'codicons',
      })

      return {
        view = {
          entries = {
            name = 'custom',
            selection_order = 'near_cursor',
          },
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<c-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<c-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<c-b>'] = cmp.mapping.scroll_docs(-4),
          ['<c-f>'] = cmp.mapping.scroll_docs(4),
          ['<c-space>'] = cmp.mapping.complete(),
          ['<c-e>'] = cmp.mapping.abort(),
          ['<c-y>'] = cmp.mapping.confirm({
            select = true,
          }),
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          {
            name = 'buffer',
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end,
            },
          },
          { name = 'path' },
          { name = 'luasnip' },
        }),
        experimental = {
          ghost_text = {
            hl_group = 'LspCodeLens',
          },
        },
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
            before = function(entry, vim_item)
              if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= '' then
                vim_item.menu = entry.completion_item.detail
              end
              return vim_item
            end,
          }),
        },
      }
    end,
  },
  -- {
  --   'L3MON4D3/LuaSnip',
  --   build = (not jit.os:find('Windows'))
  --       and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
  --     or nil,
  --   dependencies = {
  --     {
  --       'rafamadriz/friendly-snippets',
  --       config = function()
  --         require('luasnip.loaders.from_vscode').lazy_load()
  --       end,
  --     },
  --   },
  --   opts = {
  --     history = true,
  --     delete_check_events = 'TextChanged',
  --   },
  --   -- stylua: ignore
  --   keys = {
  --     {
  --       "<tab>",
  --       function()
  --         return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
  --       end,
  --       expr = true, silent = true, mode = "i",
  --     },
  --     { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
  --     { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
  --   },
  -- },
}
