local M = {}
local config = require("go_task.config")

---Check if we should log in current environment
---@return boolean should_log
local function should_log()
  return config.debug and not vim.env.CI and #vim.api.nvim_list_uis() > 0
end

---Log a message with the given level
---@param level number Log level
---@param message string Message to log
---@param opts? table Additional options
local function log(level, message, opts)
  if should_log() then
    vim.notify(message, level, vim.tbl_extend("force", { title = "go-task.nvim" }, opts or {}))
  end
end

---Log an error message
---@param message string Error message
---@param opts? table Additional options
function M.error(message, opts)
  log(vim.log.levels.ERROR, message, opts)
end

---Log a warning message
---@param message string Warning message
---@param opts? table Additional options
function M.warn(message, opts)
  log(vim.log.levels.WARN, message, opts)
end

---Log an info message
---@param message string Info message
---@param opts? table Additional options
function M.info(message, opts)
  log(vim.log.levels.INFO, message, opts)
end

---Log a debug message
---@param message string Debug message
---@param opts? table Additional options
function M.debug(message, opts)
  log(vim.log.levels.DEBUG, message, opts)
end

---Log project detection
---@param project_info table Project information
function M.log_project_detection(project_info)
  if not should_log() then
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
  
  M.info("Detected " .. project_type .. " project")
end

---Log task execution
---@param task_name string Task name
---@param exit_code number Exit code
function M.log_task_execution(task_name, exit_code)
  if not should_log() then
    return
  end
  
  local status = exit_code == 0 and "completed successfully" or "failed"
  M.info(string.format("Task '%s' %s with code %d", task_name, status, exit_code))
end

return M 