local M = {}

---Check if we should log in current environment
---@param deps? table Dependencies for testing
---@return boolean should_log
local function should_log(deps)
  deps = deps or {}
  local config = deps.config or require("go_task.config")
  local vim_api = deps.vim_api or vim.api
  local vim_env = deps.vim_env or vim.env
  
  return config.debug and not vim_env.CI and #vim_api.nvim_list_uis() > 0
end

---Log a message with the given level
---@param level number Log level
---@param message string Message to log
---@param opts? table Additional options
---@param deps? table Dependencies for testing
local function log(level, message, opts, deps)
  deps = deps or {}
  local notify = deps.notify or vim.notify
  local tbl_extend = deps.tbl_extend or vim.tbl_extend
  
  if should_log(deps) then
    notify(message, level, tbl_extend("force", { title = "go-task.nvim" }, opts or {}))
  end
end

---Log an error message
---@param message string Error message
---@param opts? table Additional options
---@param deps? table Dependencies for testing
function M.error(message, opts, deps)
  log(vim.log.levels.ERROR, message, opts, deps)
end

---Log a warning message
---@param message string Warning message
---@param opts? table Additional options
---@param deps? table Dependencies for testing
function M.warn(message, opts, deps)
  log(vim.log.levels.WARN, message, opts, deps)
end

---Log an info message
---@param message string Info message
---@param opts? table Additional options
---@param deps? table Dependencies for testing
function M.info(message, opts, deps)
  log(vim.log.levels.INFO, message, opts, deps)
end

---Log a debug message
---@param message string Debug message
---@param opts? table Additional options
---@param deps? table Dependencies for testing
function M.debug(message, opts, deps)
  log(vim.log.levels.DEBUG, message, opts, deps)
end

---Log project detection
---@param project_info table Project information
---@param deps? table Dependencies for testing
function M.log_project_detection(project_info, deps)
  deps = deps or {}
  
  if not should_log(deps) then
    return
  end
  
  local project_type = ""
  if project_info.is_go and project_info.has_taskfile then
    project_type = "Go + Taskfile"
  elseif project_info.is_go then
    project_type = "Go"
  else
    project_type = "Taskfile"
  end
  
  M.info("Detected " .. project_type .. " project", nil, deps)
end

---Log task execution
---@param task_name string Task name
---@param exit_code number Exit code
---@param deps? table Dependencies for testing
function M.log_task_execution(task_name, exit_code, deps)
  deps = deps or {}
  
  if not should_log(deps) then
    return
  end
  
  local status = exit_code == 0 and "completed successfully" or "failed"
  M.info(string.format("Task '%s' %s with code %d", task_name, status, exit_code), nil, deps)
end

return M 