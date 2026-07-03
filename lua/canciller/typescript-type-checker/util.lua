local M = {}

---Find a command in node_modules
---@param cmd string
---@return string | nil
M.from_node_modules = function(cmd)
  return M.find_executable({ 'node_modules/.bin/' .. cmd })
end

---Search parent directories for a relative path to a command
---@param paths string[]
---@return string | nil
---@example
--- local path = require("canciller.typescript-type-checker.util").find_executable({ "node_modules/.bin/tsc" }, "tsc")
M.find_executable = function(paths)
  local buffDir = vim.fn.expand('%:p:h')

  for _, path in ipairs(paths) do
    local normpath = vim.fs.normalize(path)
    local is_absolute = vim.startswith(normpath, '/')

    if is_absolute and vim.fn.executable(normpath) == 1 then
      return normpath
    end

    local idx = normpath:find('/', 1, true)
    local dir, subpath

    if idx then
      dir = normpath:sub(1, idx - 1)
      subpath = normpath:sub(idx)
    else
      -- This is a bare relative-path executable
      dir = normpath
      subpath = ''
    end

    local results = vim.fs.find(dir, { upward = true, path = buffDir, limit = math.huge })
    for _, result in ipairs(results) do
      local fullpath = result .. subpath

      if vim.fn.executable(fullpath) == 1 then
        return fullpath
      end
    end
  end

  return nil
end

return M
