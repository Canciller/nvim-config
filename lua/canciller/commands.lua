local command = vim.api.nvim_create_user_command

-- Eslint
command('Eslint', function()
  local success, pcall_result = pcall(require, 'fidget.progress')

  local progress

  if success then
    progress = pcall_result
  end

  local eslint_command = 'npx eslint . --ext .ts,.tsx,.js,.jsx --format=unix'

  local handle = progress
    and progress.handle.create({
      title = 'ESLint',
      message = 'Checking for ESLint issues...',
      lsp_client = { name = 'eslint' },
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
        local filename, lnum, col, message = line:match('([^:]+):(%d+):(%d+):%s*(.*)')
        if filename and lnum and col and message then
          local severity = message:match('%[(%w+)/')
          local type = severity == 'Error' and 'E' or 'W'
          local modified_message = message:gsub('%[Error/', '['):gsub('%[Warning/', '[')

          table.insert(qf_list, {
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = modified_message,
            type = type, -- Set the type based on severity
          })
        end
      end
    end

    vim.fn.setqflist(qf_list, 'r')

    if #qf_list > 0 then
      vim.cmd('copen')
      vim.notify('Found ' .. #qf_list .. ' ESlint issues', vim.log.levels.WARN)
    else
      vim.cmd('cclose')
      vim.notify('No ESlint issues found', vim.log.levels.INFO)
    end
  end

  vim.fn.jobstart(eslint_command, {
    on_stdout = on_stdout,
    on_exit = on_exit,
    stdout_buffered = true,
  })
end, {})

-- Format
command('Format', function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ['end'] = { args.line2, end_line:len() },
    }
  end
  require('conform').format({ async = true, lsp_format = 'fallback', range = range })
end, { range = true })

-- FormatDisable
vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})

-- FormatEnable
vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})
