local M = {}

---Setup the plugin with configuration
---@param opts? go_task.Config Configuration options
function M.setup(opts)
  require("go_task.config").setup(opts)
end

---Get the current configuration
---@return go_task.Config config
function M.get_config()
  return require("go_task.config").get()
end

---Run a task by name
---@param task_name string The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
function M.run_task(task_name, opts)
  require("go_task.commands").run_task(task_name)
end

---Run a task silently (no UI)
---@param task_name string The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
---@return Job? job The job object
function M.run_task_silent(task_name, opts)
  return require("go_task.commands").run_task_silent(task_name, opts)
end

---Get all available tasks
---@param callback fun(tasks: go_task.Task[])
function M.get_tasks(callback)
  require("go_task.ui").get_tasks(callback)
end

---Check if we should load the plugin
---@return boolean should_load
function M.should_load()
  return require("go_task.detector").should_load()
end

---Get project information
---@return table project_info
function M.get_project_info()
  return require("go_task.detector").get_project_info()
end

return M
