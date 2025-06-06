-- lua/go_task/utils/file.lua
local M = {}

function M.file_exists(name)
  return vim.fn.filereadable(name) == 1
end

function M.glob_exists(pattern)
  return vim.fn.glob(pattern) ~= ""
end

return M

