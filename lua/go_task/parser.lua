-- lua/go_task/parser.lua

local M = {}

--- Validate input is a list of strings
-- @param lines any
-- @return boolean
function M.is_valid_input(lines)
  return type(lines) == "table"
end

--- Parse a single task line
-- @param line string
-- @return string|nil, string|nil
function M.parse_line(line)
  if type(line) ~= "string" then return nil, nil end
  return line:match("^%*%s+([^:%s]+):?%s*(.*)")
end

--- Build a structured task entry
-- @param name string
-- @param desc string
-- @return table
function M.build_task(name, desc)
  return {
    name = name,
    desc = desc or ""
  }
end

--- Main parser: convert a list of lines into structured task list
-- @param lines table<string>
-- @return table<{name: string, desc: string}>
function M.parse_task_list(lines)
  if not M.is_valid_input(lines) then
    error("Expected table of strings for lines")
  end

  local tasks = {}

  for _, line in ipairs(lines) do
    local name, desc = M.parse_line(line)
    if name then
      table.insert(tasks, M.build_task(name, desc))
    end
  end

  return tasks
end

return M
