local M = {}

function M.parse_task_list(lines)
  local tasks = {}
  for _, line in ipairs(lines) do
    local name, desc = line:match("^%* ([^:%s]+):?%s*(.*)")
    if name then
      table.insert(tasks, { name = name, desc = desc })
    end
  end
  return tasks
end

return M
