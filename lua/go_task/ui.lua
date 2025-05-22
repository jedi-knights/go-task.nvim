local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local parser = require("go_task.parser")
local runner = require("go_task.runner")

local M = {}

function M.task_picker()
  Job:new({
    command = "task",
    args = { "--list" },
    on_exit = function(j)
      local lines = j:result()
      local tasks = parser.parse_task_list(lines)
      local entries = vim.tbl_map(function(t)
        return {
          value = t.name,
          display = string.format("%-15s %s", t.name, t.desc),
          ordinal = t.name .. " " .. t.desc,
        }
      end, tasks)

      vim.schedule(function()
        pickers.new({}, {
          prompt_title = "Go Task Picker",
          finder = finders.new_table({ results = entries }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(_, map)
            actions.select_default:replace(function()
              actions.close()
              local task = action_state.get_selected_entry().value
              runner.run(task)
            end)
            return true
          end,
        }):find()
      end)
    end,
  }):start()
end

return M
