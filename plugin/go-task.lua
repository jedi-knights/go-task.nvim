vim.api.nvim_create_user_command("GoTaskRun", function(opts)
    require("go_task.commands").run_task(opts.args)
end, { nargs = "?", desc = "Run a go-task by name" })

vim.api.nvim_create_user_command("GoTaskPick", function()
    require("go_task.ui").task_picker()
end, { desc = "Pick a go-task using Snack picker" })

-- Check and load on startup
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        local detector = require("go_task.detector")
        if detector.should_load() then
            require("go_task").setup()
        end
    end,
})

-- Check and load when directory changes (for project switching)
vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = function()
        local detector = require("go_task.detector")
        if detector.should_load() then
            require("go_task").setup()
        end
    end,
})

vim.api.nvim_create_user_command("GoTaskDebugToggle", function()
  require("go_task.config").toggle_debug()
end, { desc = "Toggle debug logging for go-task.nvim" })

