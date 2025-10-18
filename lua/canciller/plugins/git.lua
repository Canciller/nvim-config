return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            ---@diagnostic disable-next-line: param-type-mismatch
            gs.nav_hunk('next')
          end
        end, {
          desc = 'Git: Go to next [H]unk',
        })

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            ---@diagnostic disable-next-line: param-type-mismatch
            gs.nav_hunk('prev')
          end
        end, {
          desc = 'Git: Go to previous [H]unk',
        })

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, {
          desc = 'Git: [H]unk [S]tage',
        })
        map('n', '<leader>hr', gs.reset_hunk, {
          desc = 'Git: [H]unk [R]eset',
        })

        map('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, {
          desc = 'Git: [H]unk [S]tage',
        })

        map('v', '<leader>hr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, {
          desc = 'Git: [H]unk [R]eset',
        })

        map('n', '<leader>hS', gs.stage_buffer, { desc = 'Git: [H]unk [S]tage Buffer' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'Git: [H]unk [R]eset Buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'Git: [H]unk [P]review' })
        map('n', '<leader>hi', gs.preview_hunk_inline, { desc = 'Git: [H]unk [I]nline Preview' })

        map('n', '<leader>hd', gs.diffthis, { desc = 'Git: [H]unk [D]iff' })
        map('n', '<leader>hD', function()
          gs.diffthis('~')
        end, { desc = 'Git: [H]unk [D]iff Previous' })

        map('n', '<leader>hQ', function()
          gs.setqflist('all')
        end, { desc = 'Git: [H]unk Set [Q]uickfix List' })
        map('n', '<leader>hq', gs.setqflist, {
          desc = 'Git: [H]unk Set [Q]uickfix List (Current File)',
        })

        -- Toggles
        -- map('n', '<leader>tb', gs.toggle_current_line_blame)
        -- map('n', '<leader>tw', gs.toggle_word_diff)
      end,
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
