local M = {
    task_bin = "task",
    taskfile = "Taskfile.yml",
    debug = false,
    log_level = vim.log.levels.INFO,
}

function M.setup(opts)
    M = vim.tbl_deep_extend("force", M, opts or {})
end

function M.toggle_debug()
    M.debug = not M.debug

    vim.notify("go-task.nvim debug: " .. (M.debug and "enabled" or "disabled"), 
        M.log_level, { title = "go-task.nvim" }
    )
end

return M
 
