local M = {}

---@return go_task.Task[]
---@param lines string[] Lines from `task --list` output
---@param deps? table Dependencies for testing
function M.parse_task_list(lines, deps)
  deps = deps or {}
  local notify = deps.notify or vim.notify
  
  if not lines or type(lines) ~= "table" then
    notify("Invalid input: lines must be a table", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return {}
  end

  local tasks = {}
  for i, line in ipairs(lines) do
    if type(line) ~= "string" then
      notify(string.format("Invalid line %d: expected string, got %s", i, type(line)), vim.log.levels.WARN, { title = "go-task.nvim" })
      goto continue
    end
    
    local name, desc = line:match("^%* ([^:%s]+):?%s*(.*)")
    if name then
      table.insert(tasks, { name = name, desc = desc })
    end
    ::continue::
  end
  
  return tasks
end

---Parse a single task line
---@param line string Single line from task output
---@param deps? table Dependencies for testing
---@return go_task.Task? task The parsed task or nil if invalid
function M.parse_task_line(line, deps)
  if not line or type(line) ~= "string" then
    return nil
  end
  
  local name, desc = line:match("^%* ([^:%s]+):?%s*(.*)")
  if name then
    return { name = name, desc = desc }
  end
  
  return nil
end

return M
