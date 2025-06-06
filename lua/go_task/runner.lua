-- lua/go_task/runner.lua

local Job = require("plenary.job")
local config = require("go_task.config")

local M = {}

-- Dependencies (can be overridden in tests)
M._deps = {
  api = vim.api,
  notify = vim.notify,
  schedule = vim.schedule,
  env = vim.env,
  Job = Job,
  config = config,
}

function M._with(deps)
  M._deps = vim.tbl_extend("force", M._deps, deps)
end

-- Utility: are we in headless mode?
local function in_headless()
  return #M._deps.api.nvim_list_uis() == 0
end

-- Create a floating terminal buffer for job output
function M.create_floating_terminal()
  local api = M._deps.api
  local buf = api.nvim_create_buf(false, true)

  api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = 20,
    col = math.floor(vim.o.columns * 0.1),
    row = math.floor(vim.o.lines * 0.2),
    style = "minimal",
    border = "rounded",
  })

  return buf
end

-- Append a line to the terminal buffer
function M.append_to_terminal(buf, line)
  M._deps.schedule(function()
    M._deps.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
  end)
end

-- Create a job object for the given task
function M.create_task_job(task_name, buf)
  return M._deps.Job:new({
    command = M._deps.config.task_bin or "task",
    args = { task_name },

    on_stdout = function(_, line)
      M.append_to_terminal(buf, line)
    end,

    on_stderr = function(_, line)
      M.append_to_terminal(buf, "[stderr] " .. line)
    end,

    on_exit = function(_, code)
      local msg = "Task '" .. task_name .. "' exited with code " .. code
      M._deps.schedule(function()
        if M._deps.config.debug and not in_headless() and not M._deps.env.CI then
          M._deps.notify(msg, M._deps.config.log_level, { title = "go-task.nvim" })
        end
        M._deps.api.nvim_buf_set_lines(buf, -1, -1, false, { "", msg })
      end)
    end,
  })
end

-- Main entrypoint: run a task and show terminal
function M.run(task_name)
  if not task_name or task_name == "" then
    M._deps.notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end

  local buf = M.create_floating_terminal()
  local job = M.create_task_job(task_name, buf)
  job:start()
end

return M
