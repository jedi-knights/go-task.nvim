-- lua/go-task/commands.lua

local M = {}
local task = require("go-task.core") -- assuming this is your task execution logic

-- Register Neovim user commands
function M.setup()
  vim.api.nvim_create_user_command("GoTaskRun", function(opts)
    task.run(opts.args)
  end, {
    nargs = "?",      -- make argument optional
    complete = "file" -- or provide a custom completion
  })

  vim.api.nvim_create_user_command("GoTaskList", function()
    task.list()
  end, {})

  vim.api.nvim_create_user_command("GoTaskReload", function()
    task.reload()
  end, {})
end

return M
