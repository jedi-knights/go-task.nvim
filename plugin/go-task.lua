vim.api.nvim_create_user_command("GoTaskRun", function(opts)
  require("go_task.commands").run_task(opts.args)
end, { nargs = "*" })

vim.api.nvim_create_user_command("GoTaskPick", function()
  require("go_task.ui").task_picker()
end, {})

