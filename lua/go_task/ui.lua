local Job = require("plenary.job")
local Snacks = require("snacks")
local parser = require("go_task.parser")
local runner = require("go_task.runner")
local config = require("go_task.config")

local M = {}

---Convert tasks to picker items
---@param tasks go_task.Task[]
---@return go_task.PickerItem[]
local function tasks_to_items(tasks)
  return vim.tbl_map(function(task)
    return {
      value = task.name,
      display = string.format("%-15s %s", task.name, task.desc),
      ordinal = task.name .. " " .. task.desc,
    }
  end, tasks)
end

---Show task picker with error handling
---@param items go_task.PickerItem[]
local function show_picker(items)
  if not items or #items == 0 then
    vim.notify("No tasks found", vim.log.levels.WARN, { title = "go-task.nvim" })
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
        runner.run(item.value)
      end,
    },
  })
end

---Fetch and display tasks
function M.task_picker()
  -- Check if task binary is available
  if vim.fn.executable(config.task_bin) == 0 then
    vim.notify(
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
      local tasks = parser.parse_task_list(lines)
      local items = tasks_to_items(tasks)

      vim.schedule(function()
        show_picker(items)
      end)
    end,
    on_stderr = function(_, line)
      vim.schedule(function()
        vim.notify(
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
function M.get_tasks(callback)
  if not callback or type(callback) ~= "function" then
    vim.notify("Callback function required", vim.log.levels.ERROR, { title = "go-task.nvim" })
    return
  end

  Job:new({
    command = config.task_bin,
    args = { "--list" },
    on_exit = function(j)
      local lines = j:result()
      local tasks = parser.parse_task_list(lines)
      vim.schedule(function()
        callback(tasks)
      end)
    end,
    on_stderr = function(_, line)
      vim.schedule(function()
        vim.notify(
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
