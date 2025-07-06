-- lua/go-task/commands.lua

local M = {}
local runner = require("go_task.runner")

---Run a task by name
---@param task_name string|nil The name of the task to run
function M.run_task(task_name)
  -- Validate input
  if not task_name then
    vim.notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if type(task_name) ~= "string" then
    vim.notify("Task name must be a string", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if task_name == "" then
    vim.notify("Task name cannot be empty", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  -- Run the task
  runner.run(task_name)
end

---Run a task silently (no UI)
---@param task_name string|nil The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
function M.run_task_silent(task_name, opts)
  -- Validate input
  if not task_name then
    vim.notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if type(task_name) ~= "string" then
    vim.notify("Task name must be a string", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if task_name == "" then
    vim.notify("Task name cannot be empty", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  -- Run the task silently
  return runner.run_silent(task_name, opts)
end

return M
