---@type go_task.Config
local default_config = {
    task_bin = "task",
    taskfile = "Taskfile.yml",
    debug = false,
    log_level = vim.log.levels.INFO,
}

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
---@param deps? table Dependencies for testing
function M.setup(opts, deps)
    deps = deps or {}
    local notify = deps.notify or vim.notify
    local tbl_extend = deps.tbl_extend or vim.tbl_deep_extend
    
    local new_config = tbl_extend("force", M, opts or {})
    validate_config(new_config)
    
    -- Update the module state
    for k, v in pairs(new_config) do
        M[k] = v
    end
end

---Toggle debug mode
---@param deps? table Dependencies for testing
function M.toggle_debug(deps)
    deps = deps or {}
    local notify = deps.notify or vim.notify
    
    M.debug = not M.debug
    notify(
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

---Reset configuration to defaults (useful for testing)
---@param deps? table Dependencies for testing
function M.reset(deps)
    deps = deps or {}
    local notify = deps.notify or vim.notify
    
    for k, v in pairs(default_config) do
        M[k] = v
    end
    
    if deps.debug then
        notify("Configuration reset to defaults", vim.log.levels.INFO, { title = "go-task.nvim" })
    end
end

---Create a new config instance (useful for testing)
---@param opts? go_task.Config
---@param deps? table Dependencies for testing
---@return go_task.Config
function M.new(opts, deps)
    deps = deps or {}
    local tbl_extend = deps.tbl_extend or vim.tbl_deep_extend
    
    local config = tbl_extend("force", default_config, opts or {})
    validate_config(config)
    return config
end

return M
 
