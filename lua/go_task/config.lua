---@type go_task.Config
local M = {
    task_bin = "task",
    taskfile = "Taskfile.yml",
    debug = false,
    log_level = vim.log.levels.INFO,
}

-- Validate configuration values
local function validate_config(config)
    if type(config.task_bin) ~= "string" or config.task_bin == "" then
        error("task_bin must be a non-empty string")
    end
    
    if type(config.taskfile) ~= "string" or config.taskfile == "" then
        error("taskfile must be a non-empty string")
    end
    
    if type(config.debug) ~= "boolean" then
        error("debug must be a boolean")
    end
    
    if type(config.log_level) ~= "number" then
        error("log_level must be a number")
    end
end

---Setup the configuration with validation
---@param opts? go_task.Config
function M.setup(opts)
    local new_config = vim.tbl_deep_extend("force", M, opts or {})
    validate_config(new_config)
    M = new_config
end

---Toggle debug mode
function M.toggle_debug()
    M.debug = not M.debug
    vim.notify(
        "go-task.nvim debug: " .. (M.debug and "enabled" or "disabled"), 
        M.log_level, 
        { title = "go-task.nvim" }
    )
end

---Get current configuration
---@return go_task.Config
function M.get()
    return M
end

return M
 
