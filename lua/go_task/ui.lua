-- lua/go_task/ui.lua

local parser = require("go_task.parser")

local M = {}

-- Injected dependencies for testability
M._deps = {
  Job = require("plenary.job"),
  schedule = vim.schedule,
  pickers = require("telescope.pickers"),
  finders = require("telescope.finders"),
  sorter = require("telescope.config").values.generic_sorter,
  actions = require("telescope.actions"),
  action_state = require("telescope.actions.state"),
  runner = require("go_task.runner"),
  parser = parser,
}

function M._with(deps)
  M._deps = vim.tbl_extend("force", M._deps, deps)
end

--- Fetches task lines by executing `task --list`
-- @param cb function Callback with (ok, result)
function M.fetch_task_lines(cb)
  M._deps.Job:new({
    command = "task",
    args = { "--list" },
    on_exit = function(j)
      local lines = j:result()
      cb(true, lines)
    end
  }):start()
end

--- Convert parsed task entries into Telescope UI items
-- @param tasks table
-- @return table
function M.build_picker_entries(tasks)
  return vim.tbl_map(function(t)
    return {
      value = t.name,
      display = string.format("%-15s %s", t.name, t.desc or ""),
      ordinal = t.name .. " " .. (t.desc or ""),
    }
  end, tasks)
end

--- Show Telescope picker for selecting a task to run
-- @param entries table
function M.open_picker(entries)
  local actions = M._deps.actions
  local action_state = M._deps.action_state
  local runner = M._deps.runner

  M._deps.pickers.new({}, {
    prompt_title = "Go Task Picker",
    finder = M._deps.finders.new_table({ results = entries }),
    sorter = M._deps.sorter({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function()
        actions.close()
        local selected = action_state.get_selected_entry()
        if selected then
          runner.run(selected.value)
        end
      end)
      return true
    end,
  }):find()
end

--- Main function: fetch tasks, parse, open picker
function M.task_picker()
  M.fetch_task_lines(function(ok, lines)
    if not ok then return end

    local tasks = M._deps.parser.parse_task_list(lines)
    local entries = M.build_picker_entries(tasks)

    M._deps.schedule(function()
      M.open_picker(entries)
    end)
  end)
end

return M
