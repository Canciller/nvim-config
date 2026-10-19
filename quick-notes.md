## Note 1 — `lua/canciller/quick-notes/init.lua` · Line 30 to 52

```lua
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
```

**Notes:**

this is a quick note

```lua
local util = require('canciller.quick-notes.util')
```

> Test this

---

