---@class Config
---@field command string
---@field max_diagnostics number
local config = {
  command = 'EslintLint',
}

---@class EslintLinter
local M = {}

---@type Config
M.config = config

M.run = function()
  local success, pcall_result = pcall(require, 'fidget.progress')

  local progress

  if success then
    progress = pcall_result
  end

  local cmd = 'npx eslint --format=compact --quiet .'

  local handle = progress
    and progress.handle.create({
      title = 'Eslint Linting',
      message = 'Running Eslint linter...',
      lsp_client = { name = 'eslint-linter' },
    })

  local on_exit = function()
    if handle then
      handle:finish()
    end
  end

  local on_stdout = function(_, data)
    local qf_list = {}

    local err_count = 0
    local warn_count = 0

    for _, line in ipairs(data) do
      if line ~= '' then -- Ignore empty lines
        -- Match the filename, line number, column number, level, message, and rule
        -- Example line:
        -- /home/canciller/ecomm_StoreNextB2C/public/HDMX/images/PaidIcon.js: line 5, col 17, Error - 'theme' is defined but never used. Allowed unused args must match /^_/u. (@typescript-eslint/no-unused-vars)
        local pattern = '(.-):%s*line%s*(%d+),%s*col%s*(%d+),%s*(%a+)%s*-%s*(.*)%s*%((.-)%)'
        local filename, lnum, col, level, full_message, title = line:match(pattern)

        local type = 'I'
        if level == 'Error' then
          err_count = err_count + 1
          type = 'E'
        elseif level == 'Warning' then
          warn_count = warn_count + 1
          type = 'W'
        end

        if filename and lnum and col and full_message and title and level then
          table.insert(qf_list, {
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = title .. ': ' .. full_message,
            type = type,
          })
        end
      end
    end

    vim.fn.setqflist(qf_list, 'r')

    if #qf_list > 0 then
      vim.cmd('copen')
      -- TODO: Show the number of errors and warnings
      vim.notify(
        'Found ' .. #qf_list .. ' Eslint lint issues',
        err_count > 0 and vim.log.levels.ERROR or vim.log.levels.WARN
      )
    else
      vim.cmd('cclose')
      vim.notify('No Eslint lint issues found', vim.log.levels.INFO)
    end
  end

  vim.fn.jobstart(cmd, {
    on_stdout = on_stdout,
    on_exit = on_exit,
    stdout_buffered = true,
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

M.setup()
