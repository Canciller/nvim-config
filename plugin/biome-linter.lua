---@class Config
---@field command string
---@field max_diagnostics number
local config = {
  command = "BiomeLint",
  max_diagnostics = 1000,
}

---@class BiomeLinter
local M = {}

---@type Config
M.config = config

M.run = function()
  local success, pcall_result = pcall(require, "fidget.progress")

  local progress

  if success then
    progress = pcall_result
  end

  local cmd = "npx biome lint --reporter=github --max-diagnostics=" .. M.config.max_diagnostics

  local handle = progress
    and progress.handle.create({
      title = "Biome Linting",
      message = "Running Biome linter...",
      lsp_client = { name = "biome-linter" },
    })

  local on_exit = function()
    if handle then
      handle:finish()
    end
  end

  local on_stdout = function(_, data)
    local qf_list = {}

    for _, line in ipairs(data) do
      if line ~= "" then -- Ignore empty lines
        -- Match the level, title, filename, line number, column number, and the full message
        -- Example line:
        -- ::warning title=lint/suspicious/noTsIgnore,file=src/utils/index.ts,line=90,endLine=90,col=10,endColumn=20::Unsafe use of the @ts-ignore directive found in this comment.
        local pattern = "::(%a+) title=([^,]+),file=([^,]+),line=(%d+),endLine=%d+,col=(%d+),endColumn=%d+::(.*)"
        -- local filename, lnum, col, full_message = line:match(pattern)
        local level, title, filename, lnum, col, full_message = line:match(pattern)

        local type = "I"
        if level == "error" then
          type = "E"
        elseif level == "warning" then
          type = "W"
        end

        if filename and lnum and col and full_message then
          table.insert(qf_list, {
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = title .. ": " .. full_message,
            type = type,
          })
        end
      end
    end

    vim.fn.setqflist(qf_list, "r")

    if #qf_list > 0 then
      vim.cmd("copen")
      vim.notify("Found " .. #qf_list .. " Biome lint issues", vim.log.levels.WARN)
    else
      vim.cmd("cclose")
      vim.notify("No Biome lint issues found", vim.log.levels.INFO)
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
  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  vim.api.nvim_create_user_command(M.config.command, function()
    M.run()
  end, {
    force = true,
  })
end

M.setup()
