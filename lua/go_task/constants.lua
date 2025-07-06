local M = {}

-- Plugin information
M.PLUGIN_NAME = "go-task.nvim"
M.PLUGIN_VERSION = "1.0.0"

-- Default configuration
M.DEFAULT_TASK_BIN = "task"
M.DEFAULT_TASKFILE = "Taskfile.yml"
M.DEFAULT_DEBUG = false
M.DEFAULT_LOG_LEVEL = vim.log.levels.INFO

-- Window configuration
M.DEFAULT_WINDOW_WIDTH = 0.8
M.DEFAULT_WINDOW_HEIGHT = 0.6

-- File patterns
M.GO_MOD_FILE = "go.mod"
M.GO_FILES_PATTERN = "*.go"
M.TASKFILE_PATTERNS = { "Taskfile.yml", "Taskfile.yaml" }

-- Task output patterns
M.TASK_LINE_PATTERN = "^%* ([^:%s]+):?%s*(.*)"

-- Error messages
M.ERRORS = {
  TASK_NAME_REQUIRED = "Task name required",
  TASK_NAME_STRING = "Task name must be a string",
  TASK_NAME_EMPTY = "Task name cannot be empty",
  TASK_BINARY_NOT_FOUND = "Task binary '%s' not found in PATH",
  NO_TASKS_FOUND = "No tasks found",
  CALLBACK_REQUIRED = "Callback function required",
  INVALID_INPUT = "Invalid input: lines must be a table",
  INVALID_LINE = "Invalid line %d: expected string, got %s",
  TASK_LIST_ERROR = "Task list error: %s",
}

-- Success messages
M.SUCCESS = {
  DEBUG_ENABLED = "go-task.nvim debug: enabled",
  DEBUG_DISABLED = "go-task.nvim debug: disabled",
  PROJECT_DETECTED = "go-task.nvim: Detected %s project",
}

return M 