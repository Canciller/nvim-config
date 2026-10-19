local util = require('canciller.quick-notes.util')

---@class QuickNotesConfig
---@field file string File (relative to cwd) the notes are appended to
---@field keymap string Operator mapping; works with any motion or in visual mode
---@field width number Float width as a fraction of the editor
---@field height number Float height as a fraction of the editor
local config = {
  file = 'quick-notes.md',
  keymap = '<leader>n',
  width = 0.6,
  height = 0.4,
}

---@class QuickNotes
local M = {}

---@type QuickNotesConfig
M.config = config

---@class QuickNotesTarget
---@field path string
---@field first integer
---@field last integer
---@field scol? integer
---@field ecol? integer
---@field code string[]
---@field lang string

---@param target QuickNotesTarget
local function save(buf, target)
  local note = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if util.is_blank(note) then
    vim.notify('Quick note is empty, nothing saved', vim.log.levels.WARN)
    return true
  end

  local file = vim.fs.joinpath(vim.uv.cwd(), M.config.file)
  local number = util.next_number(file)
  local ok, err = util.append(file, util.format_entry(vim.tbl_extend('force', target, {
    number = number,
    note = note,
  })))

  if not ok then
    vim.notify('Quick note failed: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  vim.notify(('Quick note %d saved to %s'):format(number, M.config.file))
  return true
end

---@param target QuickNotesTarget
local function open_float(target)
  local Popup = require('nui.popup')
  local Layout = require('nui.layout')

  local label = util.range_label(target.first, target.last, target.scol, target.ecol)

  -- top: read-only snippet, highlighted with the source filetype
  local code = Popup({
    enter = false,
    focusable = false,
    border = {
      style = 'rounded',
      text = { top = (' %s · %s '):format(target.path, label), top_align = 'center' },
    },
    buf_options = { modifiable = true, filetype = target.lang },
    win_options = { number = true, relativenumber = false, cursorline = false },
  })

  -- bottom: the note itself
  local note = Popup({
    enter = true,
    border = {
      style = 'rounded',
      text = {
        top = ' Notes ',
        top_align = 'center',
        bottom = ' :wq save · <C-c> cancel ',
        bottom_align = 'center',
      },
    },
    buf_options = { buftype = 'acwrite', filetype = 'markdown' },
    win_options = { wrap = true },
  })

  local layout = Layout(
    {
      relative = 'editor',
      position = '50%',
      size = {
        width = math.floor(vim.o.columns * M.config.width),
        height = math.floor(vim.o.lines * M.config.height),
      },
    },
    Layout.Box({
      Layout.Box(code, { size = '40%' }),
      Layout.Box(note, { grow = 1 }),
    }, { dir = 'col' })
  )
  layout:mount()

  vim.api.nvim_buf_set_lines(code.bufnr, 0, -1, false, target.code)
  vim.bo[code.bufnr].modifiable = false
  vim.api.nvim_buf_set_name(note.bufnr, 'quick-note://' .. target.path)

  local buf = note.bufnr

  -- the layout owns two windows; tear both down once the note window is gone
  -- (`:wq`, `:q`, <C-c>, ...)
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(note.winid),
    once = true,
    callback = function()
      vim.schedule(function()
        pcall(layout.unmount, layout)
      end)
    end,
  })

  -- `:w` / `:wq` land here because of buftype=acwrite
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      if save(buf, target) then
        vim.bo[buf].modified = false
        -- `:wq` quits the window right after this runs, so only close it
        -- ourselves for a plain `:w`
        vim.schedule(function()
          if note.winid and vim.api.nvim_win_is_valid(note.winid) then
            vim.api.nvim_win_close(note.winid, true)
          end
        end)
      end
    end,
  })

  -- <C-c> discards the note and closes everything
  vim.keymap.set({ 'i', 'n' }, '<C-c>', function()
    vim.bo[buf].modified = false
    vim.cmd('stopinsert')
    vim.api.nvim_win_close(note.winid, true)
  end, { buffer = buf, desc = 'Cancel quick note' })

  -- `:q` on an empty note should just close instead of raising E37
  vim.api.nvim_create_autocmd('QuitPre', {
    buffer = buf,
    callback = function()
      if util.is_blank(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) then
        vim.bo[buf].modified = false
      end
    end,
  })

  vim.cmd('startinsert')
end

---@param first integer
---@param last integer
---@param scol? integer 1-based start column (charwise visual only)
---@param ecol? integer 1-based inclusive end column
local function capture(first, last, scol, ecol)
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    vim.notify('Quick note: buffer has no file', vim.log.levels.WARN)
    return
  end

  local code
  if scol and ecol then
    code = vim.api.nvim_buf_get_text(buf, first - 1, scol - 1, last - 1, ecol, {})
  else
    code = vim.api.nvim_buf_get_lines(buf, first - 1, last, false)
  end

  open_float({
    path = vim.fn.fnamemodify(name, ':.'),
    first = first,
    last = last,
    scol = scol,
    ecol = ecol,
    code = code,
    lang = vim.bo[buf].filetype,
  })
end

---Called by `g@` after the motion completes
M.operator = function()
  capture(vim.fn.line("'["), vim.fn.line("']"))
end

M.setup = function(args)
  M.config = vim.tbl_deep_extend('force', M.config, args or {})
  local key = M.config.keymap

  vim.keymap.set('n', key, function()
    vim.o.operatorfunc = "v:lua.require'canciller.quick-notes'.operator"
    return 'g@'
  end, { expr = true, desc = 'Quick note on motion' })

  vim.keymap.set('n', key .. 'n', function()
    vim.o.operatorfunc = "v:lua.require'canciller.quick-notes'.operator"
    return 'g@_'
  end, { expr = true, desc = 'Quick note on current line' })

  vim.keymap.set('x', key, function()
    local mode = vim.fn.mode()
    local a, b = vim.fn.getpos('v'), vim.fn.getpos('.')
    -- order the two ends so start <= end
    if a[2] > b[2] or (a[2] == b[2] and a[3] > b[3]) then
      a, b = b, a
    end
    vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)

    if mode == 'V' then
      return capture(a[2], b[2])
    end

    -- clamp past-EOL (`$`) and extend to the end of a multibyte character
    local line = vim.api.nvim_buf_get_lines(0, b[2] - 1, b[2], false)[1] or ''
    local ecol = math.min(b[3], #line)
    if ecol >= 1 then
      ecol = ecol + vim.str_utf_end(line, ecol)
    end
    capture(a[2], b[2], a[3], ecol)
  end, { desc = 'Quick note on selection' })
end

return M
