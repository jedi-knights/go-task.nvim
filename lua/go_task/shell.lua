-- lua/go-task/shell.lua

local Job = require("plenary.job")

local M = {}

-- Run a command and stream output (for run)
function M.run(cmd, args, cwd)
  local result = nil
  local err = nil

  Job:new({
    command = cmd,
    args = args,
    cwd = cwd,
    on_exit = function(j, return_val)
      result = return_val == 0
      err = not result and table.concat(j:stderr_result(), "\n") or nil
    end,
  }):sync()

  return result, err
end

-- Run a command and capture stdout
function M.capture(cmd, args)
  local ok, output = pcall(function()
    return vim.fn.systemlist({ cmd, unpack(args or {}) })
  end)

  if not ok or vim.v.shell_error ~= 0 then
    return false, output
  end

  return true, output
end

return M
