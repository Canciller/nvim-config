local util = require('canciller.typescript-type-checker.util')

---@class TypescriptTypeCheckerConfig
---@field command string The command name to use for the user command
local config = {
  command = 'Typecheck',
}

---@class TypescriptTypeChecker
local M = {}

---@type TypescriptTypeCheckerConfig
M.config = config

M.run = function()
  local rootDirPath = vim.fs.root(0, 'tsconfig.json')
  local binPath = util.from_node_modules('tsc')

  if not binPath then
    vim.notify('Could not find a TypeScript binary', vim.log.levels.ERROR)
    return
  end

  local success, pcall_result = pcall(require, 'fidget.progress')

  local progress

  if success then
    progress = pcall_result
  end

  local cmd = binPath .. ' --noEmit --pretty false'

  local handle = progress
    and progress.handle.create({
      title = 'Type-checking',
      message = 'Running TypeScript type-checker...',
      lsp_client = { name = 'typescript-type-checker' },
    })

  local on_exit = function()
    if handle then
      handle:finish()
    end
  end

  local on_stdout = function(_, data)
    local qf_list = {}

    for _, line in ipairs(data) do
      if line ~= '' then -- Ignore empty lines
        -- Match the filename, line number, column number, and the full message
        local pattern = '(.-)%((%d+),(%d+)%)%:%s*(.*)'
        local relativePath, lnum, col, full_message = line:match(pattern)

        if relativePath and lnum and col and full_message then
          local absolutePath = vim.fs.joinpath(rootDirPath, relativePath)

          table.insert(qf_list, {
            filename = absolutePath,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = full_message,
            type = 'E',
          })
        end
      end
    end

    vim.fn.setqflist(qf_list, 'r')

    if #qf_list > 0 then
      vim.cmd('copen')
      vim.notify('Found ' .. #qf_list .. ' TypeScript errors', vim.log.levels.ERROR)
    else
      vim.cmd('cclose')
      vim.notify('No TypeScript errors found', vim.log.levels.INFO)
    end
  end

  vim.fn.jobstart(cmd, {
    on_stdout = on_stdout,
    on_exit = on_exit,
    stdout_buffered = true,
    cwd = rootDirPath,
  })
end

---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend('force', M.config, args or {})

  vim.api.nvim_create_user_command(M.config.command, function()
    M.run()
  end, {
    force = true,
  })
end

return M
