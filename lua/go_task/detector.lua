local M = {}

-- Check if file exists
---@param name string File path to check
---@param deps? table Dependencies for testing
---@return boolean exists
local function file_exists(name, deps)
    deps = deps or {}
    local vim_fn = deps.vim_fn or vim.fn
    
    if not name or type(name) ~= "string" then
        return false
    end
    return vim_fn.filereadable(name) == 1
end

-- Check if we are in a Go project
---@param deps? table Dependencies for testing
---@return boolean is_go_project
function M.is_go_project(deps)
    deps = deps or {}
    local vim_fn = deps.vim_fn or vim.fn
    
    return file_exists("go.mod", deps) or vim_fn.glob("*.go") ~= ""
end

-- Check if a Taskfile is present
---@param deps? table Dependencies for testing
---@return boolean has_taskfile
function M.has_taskfile(deps)
    return file_exists("Taskfile.yml", deps) or file_exists("Taskfile.yaml", deps)
end

-- Check if running in headless mode
---@param deps? table Dependencies for testing
---@return boolean is_headless
local function in_headless(deps)
    deps = deps or {}
    local vim_api = deps.vim_api or vim.api
    
    return #vim_api.nvim_list_uis() == 0
end

-- Should we load the plugin?
---@param deps? table Dependencies for testing
---@return boolean should_load
function M.should_load(deps)
    deps = deps or {}
    local config = deps.config or require("go_task.config")
    local notify = deps.notify or vim.notify
    local vim_env = deps.vim_env or vim.env
    
    local is_go = M.is_go_project(deps)
    local has_task = M.has_taskfile(deps)

    if is_go or has_task then
        if config.debug and not in_headless(deps) and not vim_env.CI then
            local project_type = ""
            if is_go and has_task then
                project_type = "Go + Taskfile"
            elseif is_go then
                project_type = "Go"
            else
                project_type = "Taskfile"
            end
            
            notify(
                "go-task.nvim: Detected " .. project_type .. " project",
                vim.log.levels.INFO,
                { title = "go-task.nvim" }
            )
        end
        return true
    end

    return false
end

-- Get project information
---@param deps? table Dependencies for testing
---@return table project_info
function M.get_project_info(deps)
    deps = deps or {}
    local vim_fn = deps.vim_fn or vim.fn
    
    return {
        is_go = M.is_go_project(deps),
        has_taskfile = M.has_taskfile(deps),
        cwd = vim_fn.getcwd(),
    }
end

return M
