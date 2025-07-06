local M = {}

---@return go_task.Task[]
---@param lines string[] Lines from `task --list` output
function M.parse_task_list(lines)
  if not lines or type(lines) ~= "table" then
    vim.notify("Invalid input: lines must be a table", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return {}
  end

  local tasks = {}
  for i, line in ipairs(lines) do
    if type(line) ~= "string" then
      vim.notify(string.format("Invalid line %d: expected string, got %s", i, type(line)), vim.log.levels.WARN, { title = "go-task.nvim" })
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
---@return go_task.Task? task The parsed task or nil if invalid
function M.parse_task_line(line)
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
