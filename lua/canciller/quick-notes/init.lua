local util = require('canciller.quick-notes.util')

---@class QuickNotesConfig
---@field dir string Directory (relative to cwd) holding the note files, e.g. '.notes' or '.plans'
---@field keymap string Operator mapping; works with any motion or in visual mode
---@field quick_keymap string Same, but saves straight to the last file used in this project
---@field goto_keymap string In a note file: jump to the source of the entry under the cursor
---@field next_keymap string In a note file: next note
---@field prev_keymap string In a note file: previous note
---@field width number Float width as a fraction of the editor
---@field height number Float height as a fraction of the editor
local config = {
  dir = '.notes',
  keymap = '<leader>n',
  quick_keymap = '<leader>N',
  goto_keymap = 'gf',
  next_keymap = ']n',
  prev_keymap = '[n',
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
---@field quick? boolean Save to the last used file without asking
---@field dest? string Destination (relative to cwd) when quick

---Ask which file the note goes to. `on_choice` gets a path relative to cwd,
---and is not called if the user cancels.
---@param on_choice fun(rel_path: string)
local function choose_file(on_choice)
  local dir = M.config.dir
  local names = util.list_notes(dir)
  local new_file = '+ New file…'

  local items = vim.list_extend(vim.deepcopy(names), { new_file })

  vim.ui.select(items, {
    prompt = ('Save note to %s/'):format(dir),
    format_item = function(item)
      for i, name in ipairs(names) do
        if name == item then
          return ('%d. %s'):format(i, name)
        end
      end
      return item
    end,
  }, function(item)
    if not item then
      return
    end
    if item ~= new_file then
      return on_choice(vim.fs.joinpath(dir, item))
    end

    vim.ui.input({ prompt = 'File name: ' }, function(input)
      if not input then
        return
      end
      local name = util.note_filename(input)
      if not name then
        vim.notify('Invalid file name', vim.log.levels.ERROR)
        return
      end
      vim.fn.mkdir(dir, 'p')
      on_choice(vim.fs.joinpath(dir, name))
    end)
  end)
end

---@param target QuickNotesTarget
---@param rel_path string
---@param note string[]
---@return boolean
local function save(target, rel_path, note)
  local file = vim.fs.joinpath(vim.uv.cwd(), rel_path)
  local number = util.next_number(file)
  local ok, err = util.append(file, util.format_entry(vim.tbl_extend('force', target, {
    number = number,
    note = note,
  })))

  if not ok then
    vim.notify('Quick note failed: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  util.write_last(vim.uv.cwd(), rel_path)
  vim.notify(('Quick note %d saved to %s'):format(number, rel_path))
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
        bottom = target.dest and (' :wq save to %s · <C-c> cancel '):format(target.dest)
          or ' :wq save · <C-c> cancel ',
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

  -- deferred: `:wq` quits the current window right after the write, so closing
  -- here synchronously would make it quit the window underneath instead
  local function close()
    vim.schedule(function()
      if note.winid and vim.api.nvim_win_is_valid(note.winid) then
        vim.api.nvim_win_close(note.winid, true)
      end
    end)
  end

  -- `:w` / `:wq` land here because of buftype=acwrite. The buffer stays
  -- modified until a file is chosen, so a `:wq` quit fails (window stays open)
  -- and cancelling the picker keeps the note.
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      if util.is_blank(lines) then
        vim.notify('Quick note is empty, nothing saved', vim.log.levels.WARN)
        vim.bo[buf].modified = false
        return
      end

      -- deferred so the picker opens after `:wq` has finished; otherwise its
      -- trailing `:q` closes the picker window
      local function done(rel_path)
        if save(target, rel_path, lines) then
          vim.bo[buf].modified = false
          close()
        end
      end

      vim.schedule(function()
        if target.dest then
          done(target.dest)
        else
          choose_file(done)
        end
      end)
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
local function capture(quick, first, last, scol, ecol)
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    vim.notify('Quick note: buffer has no file', vim.log.levels.WARN)
    return
  end

  local dest
  if quick then
    dest = util.read_last(vim.uv.cwd())
    if not dest or vim.uv.fs_stat(vim.fs.joinpath(vim.uv.cwd(), dest)) == nil then
      if dest then
        util.write_last(vim.uv.cwd(), nil)
      end
      vim.notify(
        ('Quick note: no file used yet in this project, use %s first'):format(M.config.keymap),
        vim.log.levels.WARN
      )
      return
    end
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
    quick = quick,
    dest = dest,
  })
end

---Called by `g@` after the motion completes
M.operator = function()
  capture(false, vim.fn.line("'["), vim.fn.line("']"))
end

M.quick_operator = function()
  capture(true, vim.fn.line("'["), vim.fn.line("']"))
end

---@param key string
---@param quick boolean
---@param line_suffix string
local function map_operator(key, quick, line_suffix)
  local fn = quick and 'quick_operator' or 'operator'
  local what = quick and 'Quick note to last file' or 'Quick note'

  vim.keymap.set('n', key, function()
    vim.o.operatorfunc = ("v:lua.require'canciller.quick-notes'.%s"):format(fn)
    return 'g@'
  end, { expr = true, desc = what .. ' on motion' })

  vim.keymap.set('n', key .. line_suffix, function()
    vim.o.operatorfunc = ("v:lua.require'canciller.quick-notes'.%s"):format(fn)
    return 'g@_'
  end, { expr = true, desc = what .. ' on current line' })

  vim.keymap.set('x', key, function()
    local mode = vim.fn.mode()
    local a, b = vim.fn.getpos('v'), vim.fn.getpos('.')
    -- order the two ends so start <= end
    if a[2] > b[2] or (a[2] == b[2] and a[3] > b[3]) then
      a, b = b, a
    end
    vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)

    if mode == 'V' then
      return capture(quick, a[2], b[2])
    end

    -- clamp past-EOL (`$`) and extend to the end of a multibyte character
    local line = vim.api.nvim_buf_get_lines(0, b[2] - 1, b[2], false)[1] or ''
    local ecol = math.min(b[3], #line)
    if ecol >= 1 then
      ecol = ecol + vim.str_utf_end(line, ecol)
    end
    capture(quick, a[2], b[2], a[3], ecol)
  end, { desc = what .. ' on selection' })
end

---Open the source file of the entry under the cursor, at the start of its range
M.goto_source = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local entry = util.find_entry(lines, vim.api.nvim_win_get_cursor(0)[1])
  if not entry then
    vim.notify('Quick note: cursor is not inside a note entry', vim.log.levels.WARN)
    return
  end

  local file = vim.fs.joinpath(vim.uv.cwd(), entry.path)
  if vim.uv.fs_stat(file) == nil then
    vim.notify(('Quick note: %s does not exist'):format(entry.path), vim.log.levels.WARN)
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(file))
  local line = math.min(entry.line, vim.api.nvim_buf_line_count(0))
  vim.api.nvim_win_set_cursor(0, { line, math.max((entry.col or 1) - 1, 0) })
  vim.cmd('normal! zz')
end

---@param backward boolean
local function jump_note(backward)
  local flags = backward and 'bW' or 'W'
  for _ = 1, vim.v.count1 do
    if vim.fn.search('^## Note \\d\\+ ', flags) == 0 then
      break
    end
  end
  vim.cmd('normal! zz')
end

M.next_note = function()
  jump_note(false)
end

M.prev_note = function()
  jump_note(true)
end

---@param buf integer
local function is_note_file(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fs.joinpath(vim.uv.cwd(), M.config.dir) .. '/'
  return name:sub(1, #dir) == dir and name:match('%.md$') ~= nil
end

M.setup = function(args)
  M.config = vim.tbl_deep_extend('force', M.config, args or {})
  map_operator(M.config.keymap, false, 'n')
  map_operator(M.config.quick_keymap, true, 'N')

  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('quick-notes-navigation', { clear = true }),
    pattern = '*.md',
    callback = function(ev)
      if vim.b[ev.buf].quick_notes_mapped or not is_note_file(ev.buf) then
        return
      end
      vim.b[ev.buf].quick_notes_mapped = true

      local function map(key, fn, desc)
        vim.keymap.set('n', key, fn, { buffer = ev.buf, desc = 'Quick note: ' .. desc })
      end
      map(M.config.goto_keymap, M.goto_source, 'go to source')
      map(M.config.next_keymap, M.next_note, 'next note')
      map(M.config.prev_keymap, M.prev_note, 'previous note')
    end,
  })
end

return M
