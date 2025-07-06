---@class go_task.Task
---@field name string The name of the task
---@field desc string The description of the task

---@class go_task.Config
---@field task_bin string Binary to run (default: "task")
---@field taskfile string Location of Taskfile (default: "Taskfile.yml")
---@field debug boolean Enable debug notifications (default: false)
---@field log_level number Log verbosity level (default: vim.log.levels.INFO)

---@class go_task.PickerItem
---@field value string The task name
---@field display string Formatted display string
---@field ordinal string Searchable text for fuzzy matching

---@class go_task.RunnerOptions
---@field task_name string The name of the task to run
---@field cwd? string Working directory (default: current directory)
---@field on_exit? fun(code: number) Callback when task exits
---@field on_stdout? fun(line: string) Callback for stdout lines
---@field on_stderr? fun(line: string) Callback for stderr lines

return {} 