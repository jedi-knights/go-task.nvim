local M = {
  task_bin = "task",
  taskfile = "Taskfile.yml",
}

function M.setup(opts)
  M = vim.tbl_deep_extend("force", M, opts or {})
end

return M
