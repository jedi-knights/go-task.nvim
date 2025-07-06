local M = {}

---Convert tasks to picker items
---@param tasks go_task.Task[]
---@param deps? table Dependencies for testing
---@return go_task.PickerItem[]
local function tasks_to_items(tasks, deps)
  deps = deps or {}
  local vim_tbl_map = deps.vim_tbl_map or vim.tbl_map
  
  return vim_tbl_map(function(task)
    return {
      value = task.name,
      display = string.format("%-15s %s", task.name, task.desc),
      ordinal = task.name .. " " .. task.desc,
    }
  end, tasks)
end

---Show task picker with error handling
---@param items go_task.PickerItem[]
---@param deps? table Dependencies for testing
local function show_picker(items, deps)
  deps = deps or {}
  local Snacks = deps.Snacks or require("snacks")
  local notify = deps.notify or vim.notify
  local runner = deps.runner or require("go_task.runner")
  
  if not items or #items == 0 then
    notify("No tasks found", vim.log.levels.WARN, { title = "go-task.nvim" })
    return
  end

  Snacks.picker({
    items = items,
    title = "Go Task Picker",
    layout = { preset = "vscode" },
    confirm = "item_action",
    actions = {
      item_action = function(picker, item)
        picker:close()
        runner.run(item.value, nil, deps)
      end,
    },
  })
end

---Fetch and display tasks
---@param deps? table Dependencies for testing
function M.task_picker(deps)
  deps = deps or {}
  local Job = deps.Job or require("plenary.job")
  local config = deps.config or require("go_task.config")
  local parser = deps.parser or require("go_task.parser")
  local notify = deps.notify or vim.notify
  local schedule = deps.schedule or vim.schedule
  local vim_fn = deps.vim_fn or vim.fn
  
  -- Check if task binary is available
  if vim_fn.executable(config.task_bin) == 0 then
    notify(
      string.format("Task binary '%s' not found in PATH", config.task_bin),
      vim.log.levels.ERROR,
      { title = "go-task.nvim" }
    )
    return
  end

  Job:new({
    command = config.task_bin,
    args = { "--list" },
    on_exit = function(j)
      local lines = j:result()
      local tasks = parser.parse_task_list(lines, deps)
      local items = tasks_to_items(tasks, deps)

      schedule(function()
        show_picker(items, deps)
      end)
    end,
    on_stderr = function(_, line)
      schedule(function()
        notify(
          string.format("Task list error: %s", line),
          vim.log.levels.ERROR,
          { title = "go-task.nvim" }
        )
      end)
    end,
  }):start()
end

---Get tasks as a list (for programmatic use)
---@param callback fun(tasks: go_task.Task[])
---@param deps? table Dependencies for testing
function M.get_tasks(callback, deps)
  deps = deps or {}
  local Job = deps.Job or require("plenary.job")
  local config = deps.config or require("go_task.config")
  local parser = deps.parser or require("go_task.parser")
  local notify = deps.notify or vim.notify
  local schedule = deps.schedule or vim.schedule
  
  if not callback or type(callback) ~= "function" then
    notify("Callback function required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end

  Job:new({
    command = config.task_bin,
    args = { "--list" },
    on_exit = function(j)
      local lines = j:result()
      local tasks = parser.parse_task_list(lines, deps)
      schedule(function()
        callback(tasks)
      end)
    end,
    on_stderr = function(_, line)
      schedule(function()
        notify(
          string.format("Task list error: %s", line),
          vim.log.levels.ERROR,
          { title = "go-task.nvim" }
        )
        callback({})
      end)
    end,
  }):start()
end

return M
