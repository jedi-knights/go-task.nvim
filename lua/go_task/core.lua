-- lua/go-task/core.lua

local M = {}
local uv = vim.loop

local _taskfile_cache = setmetatable({}, { __mode = "kv" })

local function get_cache_key(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    return nil
  end
  return path .. ":" .. stat.mtime.sec .. ":" .. stat.size
end

-- Utilities
local function find_taskfile()
  local cwd = vim.fn.getcwd()
  local cache_key = "find:" .. cwd

  if _taskfile_cache[cache_key] then
    return _taskfile_cache[cache_key]
  end

  local path = vim.fn.findfile("Taskfile.yml", cwd .. ";")
  if path == "" then
    vim.notify("Taskfile.yml not found", vim.log.levels.WARN)
    return nil
  end

  _taskfile_cache[cache_key] = path
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
  local taskfile = find_taskfile()
  if not taskfile then
    return
  end

  local cache_key = get_cache_key(taskfile)
  if cache_key and _taskfile_cache["list:" .. cache_key] then
    local cached_output = _taskfile_cache["list:" .. cache_key]
    vim.notify(table.concat(cached_output, "\n"), vim.log.levels.INFO)
    return
  end

  local output = vim.fn.systemlist({ "task", "--list" })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to list tasks", vim.log.levels.ERROR)
    return
  end

  if cache_key then
    _taskfile_cache["list:" .. cache_key] = output
  end

  vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
end

-- Reload tasks (clear cache)
function M.reload()
  _taskfile_cache = setmetatable({}, { __mode = "kv" })
  vim.notify("Task cache cleared", vim.log.levels.INFO)
end

return M
