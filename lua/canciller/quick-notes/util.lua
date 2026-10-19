local M = {}

---Next entry number, based on the `N. ` entry headers already in the file
---@param path string
---@return integer
M.next_number = function(path)
  local f = io.open(path, 'r')
  if not f then
    return 1
  end

  local last = 0
  for line in f:lines() do
    local n = line:match('^## Note (%d+) ') or line:match('^(%d+)%. .+ Line %d+')
    if n then
      last = math.max(last, tonumber(n))
    end
  end
  f:close()

  return last + 1
end

---@param first integer
---@param last integer
---@param scol? integer
---@param ecol? integer
---@return string
M.range_label = function(first, last, scol, ecol)
  if scol and ecol then
    if first == last then
      return ('Line %d:%d to %d'):format(first, scol, ecol)
    end
    return ('Line %d:%d to %d:%d'):format(first, scol, last, ecol)
  end
  if first == last then
    return ('Line %d'):format(first)
  end
  return ('Line %d to %d'):format(first, last)
end

---Parse an entry header written by `format_entry`
---@param line string
---@return { path: string, line: integer, col?: integer }?
M.parse_header = function(line)
  local path, l, c = line:match('^## Note %d+ — `(.-)` · Line (%d+):?(%d*)')
  if not path then
    return nil
  end
  return { path = path, line = tonumber(l), col = tonumber(c) }
end

---Header of the entry containing `row` (1-based). Nil when `row` is outside
---any entry, i.e. a `---` separator comes before a header.
---@param lines string[]
---@param row integer
---@return { path: string, line: integer, col?: integer }?
M.find_entry = function(lines, row)
  for i = row, 1, -1 do
    local header = M.parse_header(lines[i])
    if header then
      return header
    end
    if lines[i] == '---' then
      return nil
    end
  end
  return nil
end

---Build the markdown for a single entry
---@param opts { number: integer, path: string, first: integer, last: integer, scol?: integer, ecol?: integer, note: string[], code: string[], lang: string }
---@return string
M.format_entry = function(opts)
  local lines = {
    ('## Note %d — `%s` · %s'):format(opts.number, opts.path, M.range_label(opts.first, opts.last, opts.scol, opts.ecol)),
    '',
    '```' .. opts.lang,
  }
  vim.list_extend(lines, opts.code)
  vim.list_extend(lines, { '```', '', '**Notes:**', '' })
  vim.list_extend(lines, opts.note)
  vim.list_extend(lines, { '', '---', '', '' })

  return table.concat(lines, '\n')
end

---Append text to a file, creating it if needed. Never truncates.
---@param path string
---@param text string
---@return boolean ok, string? err
M.append = function(path, text)
  local f, err = io.open(path, 'a')
  if not f then
    return false, err
  end
  f:write(text)
  f:close()
  return true
end

---Markdown files in `dir`, sorted by name. Empty if the dir doesn't exist.
---@param dir string
---@return string[] names
M.list_notes = function(dir)
  local names = {}
  for name, type in vim.fs.dir(dir) do
    if type == 'file' and name:match('%.md$') then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

---Normalise a user-typed file name. Returns nil if it isn't a plain name.
---@param name string
---@return string?
M.note_filename = function(name)
  name = vim.trim(name)
  if name == '' or name:find('[/\\]') or name:sub(1, 1) == '.' then
    return nil
  end
  return name:match('%.md$') and name or (name .. '.md')
end

---@param lines string[]
---@return boolean
M.is_blank = function(lines)
  return vim.trim(table.concat(lines, '\n')) == ''
end

local function state_file()
  return vim.fs.joinpath(vim.fn.stdpath('state'), 'quick-notes', 'state.json')
end

---@return table<string, string>
local function read_state()
  local f = io.open(state_file(), 'r')
  if not f then
    return {}
  end
  local text = f:read('*a')
  f:close()

  local ok, decoded = pcall(vim.json.decode, text)
  return (ok and type(decoded) == 'table') and decoded or {}
end

---Last note file (relative to cwd) used in this project
---@param cwd string
---@return string?
M.read_last = function(cwd)
  local last = read_state()[cwd]
  return type(last) == 'string' and last or nil
end

---@param cwd string
---@param rel_path? string nil clears the entry
M.write_last = function(cwd, rel_path)
  local state = read_state()
  state[cwd] = rel_path
  vim.fn.mkdir(vim.fs.dirname(state_file()), 'p')
  M.overwrite(state_file(), vim.json.encode(state))
end

---Replace the whole content of a file (state only; notes are append-only)
---@param path string
---@param text string
M.overwrite = function(path, text)
  local f = io.open(path, 'w')
  if f then
    f:write(text)
    f:close()
  end
end

return M
