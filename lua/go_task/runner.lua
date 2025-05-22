local Job = require("plenary.job")

local M = {}

function M.run(task_name, callback)
  Job:new({
    command = "task",
    args = { task_name },
    on_exit = function(j)
      vim.schedule(function()
        callback(j:result(), j:code())
      end)
    end,
  }):start()
end

return M
