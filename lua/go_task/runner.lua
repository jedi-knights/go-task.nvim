local M = {}

local function in_headless(deps)
  deps = deps or {}
  local vim_api = deps.vim_api or vim.api
  
  return #vim_api.nvim_list_uis() == 0
end

---Create a floating terminal window
---@param width number Window width (0-1)
---@param height number Window height (0-1)
---@param deps? table Dependencies for testing
---@return number buffer_id
local function create_terminal_window(width, height, deps)
  deps = deps or {}
  local vim_api = deps.vim_api or vim.api
  local vim_o = deps.vim_o or vim.o
  
  local term_buf = vim_api.nvim_create_buf(false, true)
  local win_opts = {
    relative = "editor",
    width = math.floor(vim_o.columns * width),
    height = math.floor(vim_o.lines * height),
    col = math.floor(vim_o.columns * (1 - width) / 2),
    row = math.floor(vim_o.lines * (1 - height) / 2),
    style = "minimal",
    border = "rounded",
  }
  
  vim_api.nvim_open_win(term_buf, true, win_opts)
  return term_buf
end

---Run a task with the given options
---@param task_name string The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
---@param deps? table Dependencies for testing
function M.run(task_name, opts, deps)
  deps = deps or {}
  local Job = deps.Job or require("plenary.job")
  local config = deps.config or require("go_task.config")
  local notify = deps.notify or vim.notify
  local schedule = deps.schedule or vim.schedule
  local vim_api = deps.vim_api or vim.api
  local vim_fn = deps.vim_fn or vim.fn
  local vim_env = deps.vim_env or vim.env
  
  opts = opts or {}
  
  -- Validate inputs
  if not task_name or task_name == "" then
    notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end
  
  if type(task_name) ~= "string" then
    notify("Task name must be a string", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end

  -- Create terminal buffer
  local term_buf = create_terminal_window(0.8, 0.6, deps)
  local cwd = opts.cwd or vim_fn.getcwd()

  -- Run the task
  local job = Job:new({
    command = config.task_bin,
    args = { task_name },
    cwd = cwd,
    on_stdout = function(_, line)
      schedule(function()
        vim_api.nvim_buf_set_lines(term_buf, -1, -1, false, { line })
        if opts.on_stdout then
          opts.on_stdout(line)
        end
      end)
    end,
    on_stderr = function(_, line)
      schedule(function()
        vim_api.nvim_buf_set_lines(term_buf, -1, -1, false, { "[stderr] " .. line })
        if opts.on_stderr then
          opts.on_stderr(line)
        end
      end)
    end,
    on_exit = function(_, code)
      schedule(function()
        local msg = string.format("Task '%s' exited with code %d", task_name, code)
        if config.debug and not in_headless(deps) and not vim_env.CI then
          notify(msg, config.log_level, { title = "go-task.nvim" })
        end
        vim_api.nvim_buf_set_lines(term_buf, -1, -1, false, { "", msg })
        
        if opts.on_exit then
          opts.on_exit(code)
        end
      end)
    end,
  })
  
  job:start()
  return job
end

---Run a task silently (no UI)
---@param task_name string The name of the task to run
---@param opts? go_task.RunnerOptions Additional options
---@param deps? table Dependencies for testing
---@return Job job The job object
function M.run_silent(task_name, opts, deps)
  deps = deps or {}
  local Job = deps.Job or require("plenary.job")
  local config = deps.config or require("go_task.config")
  local notify = deps.notify or vim.notify
  local vim_fn = deps.vim_fn or vim.fn
  
  opts = opts or {}
  
  if not task_name or task_name == "" then
    notify("Task name required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end

  local cwd = opts.cwd or vim_fn.getcwd()
  
  local job = Job:new({
    command = config.task_bin,
    args = { task_name },
    cwd = cwd,
    on_stdout = opts.on_stdout,
    on_stderr = opts.on_stderr,
    on_exit = opts.on_exit,
  })
  
  job:start()
  return job
end

return M
