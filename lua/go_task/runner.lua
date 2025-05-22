local Job = require("plenary.job")
local config = require("go_task.config")

local M = {}

local function in_headless()
  return #vim.api.nvim_list_uis() == 0
end

function M.run(task_name)
  if not task_name or task_name == "" then
    vim.notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end

  -- Create terminal buffer
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(term_buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = 20,
    col = math.floor(vim.o.columns * 0.1),
    row = math.floor(vim.o.lines * 0.2),
    style = "minimal",
    border = "rounded",
  })

  -- Run the task
  Job:new({
    command = config.task_bin or "task",
    args = { task_name },
    on_stdout = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, { line })
      end)
    end,
    on_stderr = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, { "[stderr] " .. line })
      end)
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        local msg = "Task '" .. task_name .. "' exited with code " .. code
        if config.debug and not in_headless() and not vim.env.CI then
          vim.notify(msg, config.log_level, { title = "go-task.nvim" })
        end
        vim.api.nvim_buf_set_lines(term_buf, -1, -1, false, { "", msg })
      end)
    end,
  }):start()
end

return M
