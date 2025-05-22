local M = {}

function M.parse_task_list(lines)
  local tasks = {}
  for _, line in ipairs(lines) do
    local task = line:match("^%* ([^:%s]+)")
    if task then
      table.insert(tasks, task)
    end
  end
  return tasks
end

return M
