-- lua/go-task/core.lua

local M = {}
local uv = vim.loop

-- Utilities
local function find_taskfile()
  local cwd = vim.fn.getcwd()
  local path = vim.fn.findfile("Taskfile.yml", cwd .. ";")
  if path == "" then
    vim.notify("Taskfile.yml not found", vim.log.levels.WARN)
    return nil
  end
  return path
end

-- Run a task using go-task
function M.run(task_name)
  if not task_name or task_name == "" then
    vim.notify("Usage: :GoTaskRun <task>", vim.log.levels.ERROR)
    return
  end

  local cmd = { "task", task_name }

  -- Spawn process and stream output
  local handle
  handle = uv.spawn("task", {
    args = { task_name },
    cwd = vim.fn.getcwd(),
    stdio = { nil, uv.new_pipe(false), uv.new_pipe(false) },
  }, function(code, signal)
    handle:close()
    if code == 0 then
      vim.notify("Task '" .. task_name .. "' completed successfully!", vim.log.levels.INFO)
    else
      vim.notify("Task '" .. task_name .. "' failed with code " .. code, vim.log.levels.ERROR)
    end
  end)
end

-- List all available tasks
function M.list()
  local output = vim.fn.systemlist({ "task", "--list" })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to list tasks", vim.log.levels.ERROR)
    return
  end
  vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
end

-- Reload tasks (if you cache them in the future)
function M.reload()
  vim.notify("Reload not implemented yet", vim.log.levels.INFO)
end

return M
