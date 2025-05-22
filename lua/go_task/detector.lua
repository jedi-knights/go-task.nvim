local M = {}

-- Check if file exists
local function file_exists(name)
    return vim.fn.filereadable(name) == 1
end

-- Check if we are in a Go project
function M.is_go_project()
    return file_exists("go.mod") or vim.fn.glob("*.go") ~= ""
end

-- Check if a Taskfile is present
function M.has_taskfile()
    return file_exists("Taskfile.yml") or file_exists("Taskfile.yaml")
end

local function in_headless()
    return #vim.api.nvim_list_uis() == 0
end

-- Should we load the plugin?
function M.should_load()
    local is_go = M.is_go_project()
    local has_task = M.has_taskfile()

    if is_go or has_task then
        if config.debug and not in_headless() and not vim.env.CI then
            vim.notify("go-task.nvim: Detected project ("
                .. (is_go and "Go" or "")
                .. (is_go and has_task and " + " or "")
                .. (has_task and "Taskfile" or "")
                .. ")",
                vim.log.levels.INFO,
                { title = "go-task.nvim" }
            )
        end
        return true
    end

    return false
end

return M
