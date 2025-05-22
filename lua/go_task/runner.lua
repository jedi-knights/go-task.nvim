local Job = require("plenary.job")

local M = {}

function M.run(task_name)
  if not task_name or task_name == "" then
    vim.notify("Task name required", vim.log.levels.ERROR)
    return
  end

  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(term_buf, true, {
    relative = "editor", width = 80, height = 20,
    col = 10, row = 5, style = "minimal", border = "rounded"
  })

  Job:new({
    command = "task",
    args = { task_name },
    on_stdout = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, { line })
      end)
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, { "Task failed with code " .. code })
        end)
      end
    end,
  }):start()
end

return M
