-- lua/go-task/core.lua

local M = {}

-- Dependency injection for shell and notify
M._deps = {
  shell = require("go-task.shell"), -- expected to provide run() and capture()
  notify = function(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
  end,
  cwd = function()
    return vim.fn.getcwd()
  end,
  findfile = function(name, path)
    return vim.fn.findfile(name, path)
  end
}

-- Allow overriding dependencies (for testing)
function M._with(deps)
  M._deps = vim.tbl_extend("force", M._deps, deps)
end

-- Find Taskfile
function M.find_taskfile()
  local cwd = M._deps.cwd()
  local path = M._deps.findfile("Taskfile.yml", cwd .. ";")
  return path ~= "" and path or nil
end

-- Run a go-task task
function M.run(task_name)
  if not task_name or task_name == "" then
    return false, "Task name is required"
  end

  local success, err = M._deps.shell.run("task", { task_name }, M._deps.cwd())
  if success then
    return true, "Task '" .. task_name .. "' completed successfully!"
  else
    return false, "Task '" .. task_name .. "' failed: " .. (err or "unknown error")
  end
end

-- List available tasks
function M.list()
  local ok, result = M._deps.shell.capture("task", { "--list" })
  if not ok then
    return false, "Failed to list tasks"
  end
  return true, result
end

-- Reload stub (extend in future)
function M.reload()
  return true, "Reload is not implemented yet"
end

-- Public helpers that print (optional, for commands.lua)
function M.run_and_notify(task_name)
  local ok, msg = M.run(task_name)
  M._deps.notify(msg, ok and vim.log.levels.INFO or vim.log.levels.ERROR)
end

function M.list_and_notify()
  local ok, result = M.list()
  local level = ok and vim.log.levels.INFO or vim.log.levels.ERROR
  local message = ok and table.concat(result, "\n") or result
  M._deps.notify(message, level)
end

function M.reload_and_notify()
  local _, msg = M.reload()
  M._deps.notify(msg)
end

return M
