-- tests/helpers/mock_vim_fn.lua

local M = {}

--- Setup `vim.fn` to stub only specific functions.
-- Functions not stubbed will raise an error to prevent silent test failures.
-- @param stubs table<string, function> - table of function stubs
function M.mock_vim_fn(stubs)
  local original_fn = vim.fn

  -- Replace `vim.fn` with a stubbed version
  vim.fn = setmetatable({}, {
    __index = function(_, key)
      if stubs[key] then
        return stubs[key]
      end
      error("vim.fn." .. key .. " was not stubbed")
    end
  })

  -- Return restore function to be called in `after_each`
  return function()
    vim.fn = original_fn
  end
end

return M
