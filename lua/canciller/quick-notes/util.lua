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

---@param lines string[]
---@return boolean
M.is_blank = function(lines)
  return vim.trim(table.concat(lines, '\n')) == ''
end

return M
