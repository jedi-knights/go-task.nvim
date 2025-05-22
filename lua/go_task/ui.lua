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
      local tasks = parser.parse_task_list(j:result())
      vim.schedule(function()
        pickers.new({}, {
          prompt_title = "Go Task",
          finder = finders.new_table({ results = tasks }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(_, map)
            actions.select_default:replace(function()
              actions.close()
              local selection = action_state.get_selected_entry()
              if selection then
                runner.run(selection[1], function(output, code)
                  vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
                end)
              end
            end)
            return true
          end,
        }):find()
      end)
    end,
  }):start()
end

return M
