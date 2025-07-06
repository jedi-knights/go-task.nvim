local M = {}

---Setup the plugin with configuration
---@param opts? go_task.Config Configuration options
---@param deps? table Dependencies for testing
function M.setup(opts, deps)
  deps = deps or {}
  local config = deps.config or require("go_task.config")
  config.setup(opts, deps)
end

---Get the current configuration
---@param deps? table Dependencies for testing
---@return go_task.Config config
function M.get_config(deps)
  deps = deps or {}
  local config = deps.config or require("go_task.config")
  return config.get()
end

---Run a task by name
---@param task_name string The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
---@param deps? table Dependencies for testing
function M.run_task(task_name, opts, deps)
  deps = deps or {}
  local commands = deps.commands or require("go_task.commands")
  commands.run_task(task_name, deps)
end

---Run a task silently (no UI)
---@param task_name string The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
---@param deps? table Dependencies for testing
---@return Job? job The job object
function M.run_task_silent(task_name, opts, deps)
  deps = deps or {}
  local commands = deps.commands or require("go_task.commands")
  return commands.run_task_silent(task_name, opts, deps)
end

---Get all available tasks
---@param callback fun(tasks: go_task.Task[])
---@param deps? table Dependencies for testing
function M.get_tasks(callback, deps)
  deps = deps or {}
  local ui = deps.ui or require("go_task.ui")
  ui.get_tasks(callback, deps)
end

---Check if we should load the plugin
---@param deps? table Dependencies for testing
---@return boolean should_load
function M.should_load(deps)
  deps = deps or {}
  local detector = deps.detector or require("go_task.detector")
  return detector.should_load(deps)
end

---Get project information
---@param deps? table Dependencies for testing
---@return table project_info
function M.get_project_info(deps)
  deps = deps or {}
  local detector = deps.detector or require("go_task.detector")
  return detector.get_project_info(deps)
end

return M
