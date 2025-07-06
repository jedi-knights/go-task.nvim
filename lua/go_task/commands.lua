-- lua/go-task/commands.lua

local M = {}

---Run a task by name
---@param task_name string|nil The name of the task to run
---@param deps? table Dependencies for testing
function M.run_task(task_name, deps)
  deps = deps or {}
  local notify = deps.notify or vim.notify
  local runner = deps.runner or require("go_task.runner")
  
  -- Validate input
  if not task_name then
    notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if type(task_name) ~= "string" then
    notify("Task name must be a string", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if task_name == "" then
    notify("Task name cannot be empty", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  -- Run the task
  runner.run(task_name, nil, deps)
end

---Run a task silently (no UI)
---@param task_name string|nil The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
---@param deps? table Dependencies for testing
function M.run_task_silent(task_name, opts, deps)
  deps = deps or {}
  local notify = deps.notify or vim.notify
  local runner = deps.runner or require("go_task.runner")
  
  -- Validate input
  if not task_name then
    notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if type(task_name) ~= "string" then
    notify("Task name must be a string", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if task_name == "" then
    notify("Task name cannot be empty", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  -- Run the task silently
  return runner.run_silent(task_name, opts, deps)
end

return M
