-- lua/go_task/plugin.lua

local M = {}

function M.setup_commands()
  vim.api.nvim_create_user_command("GoTaskRun", function(opts)
    require("go_task.commands").run_task(opts.args)
  end, { nargs = "*" })

  vim.api.nvim_create_user_command("GoTaskPick", function()
    require("go_task.ui").task_picker()
  end, {})

  vim.api.nvim_create_user_command("GoTaskDebugToggle", function()
    require("go_task.config").toggle_debug()
  end, { desc = "Toggle debug logging for go-task.nvim" })
end

function M.setup_autocmd()
  vim.api.nvim_create_autocmd("BufReadPre", {
    pattern = "*",
    callback = function()
      local detector = require("go_task.detector")
      if detector.should_load() then
        require("go_task").setup()
      end
    end,
  })
end

return M
