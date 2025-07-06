local M = {}
local config = require("go_task.config")

-- Check if file exists
---@param name string File path to check
---@return boolean exists
local function file_exists(name)
    if not name or type(name) ~= "string" then
        return false
    end
    return vim.fn.filereadable(name) == 1
end

-- Check if we are in a Go project
---@return boolean is_go_project
function M.is_go_project()
    return file_exists("go.mod") or vim.fn.glob("*.go") ~= ""
end

-- Check if a Taskfile is present
---@return boolean has_taskfile
function M.has_taskfile()
    return file_exists("Taskfile.yml") or file_exists("Taskfile.yaml")
end

-- Check if running in headless mode
---@return boolean is_headless
local function in_headless()
    return #vim.api.nvim_list_uis() == 0
end

-- Should we load the plugin?
---@return boolean should_load
function M.should_load()
    local is_go = M.is_go_project()
    local has_task = M.has_taskfile()

    if is_go or has_task then
        if config.debug and not in_headless() and not vim.env.CI then
            local project_type = ""
            if is_go and has_task then
                project_type = "Go + Taskfile"
            elseif is_go then
                project_type = "Go"
            else
                project_type = "Taskfile"
            end
            
            vim.notify(
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
---@return table project_info
function M.get_project_info()
    return {
        is_go = M.is_go_project(),
        has_taskfile = M.has_taskfile(),
        cwd = vim.fn.getcwd(),
    }
end

return M
