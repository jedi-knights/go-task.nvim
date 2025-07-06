# Testing Guide for go-task.nvim

This document explains how to test the go-task.nvim plugin after the testability refactoring.

## Overview

All modules in go-task.nvim have been refactored to support dependency injection, making them highly testable. Each module accepts an optional `deps` parameter that allows you to inject mock dependencies for testing.

## Key Testability Improvements

### 1. Dependency Injection
All modules now accept a `deps` parameter that allows injection of:
- Vim API mocks (`vim_api`, `vim_fn`, `vim_o`, `vim_env`)
- External module mocks (`Job`, `Snacks`)
- Notification mocks (`notify`)
- Scheduler mocks (`schedule`)
- Module mocks (for testing module interactions)

### 2. Config Module Improvements
- Added `reset()` method for restoring defaults
- Added `new()` method for creating isolated instances
- All methods accept `deps` parameter

### 3. Logger Module Improvements
- All logging functions accept `deps` parameter
- Config dependency can be injected
- Vim API calls can be mocked

### 4. Detector Module Improvements
- File system operations can be mocked
- Vim API calls can be injected
- Environment variables can be mocked

### 5. Parser Module Improvements
- Error notifications can be mocked
- Input validation is testable

### 6. Commands Module Improvements
- Runner dependency can be injected
- Error notifications can be mocked

### 7. Runner Module Improvements
- Job creation can be mocked
- Vim API calls can be injected
- Terminal window creation can be mocked

### 8. UI Module Improvements
- Snacks picker can be mocked
- Job creation can be mocked
- All vim API calls can be injected

## Test Utilities

The `tests/test_utils.lua` module provides comprehensive testing utilities:

### Creating Test Dependencies
```lua
local test_utils = require("tests.test_utils")
local deps = test_utils.create_test_deps()
```

### Mock Vim API
```lua
local mock_vim = test_utils.create_mock_vim()
```

### Mock Job
```lua
local mock_job = test_utils.create_mock_job()
```

### Mock Snacks
```lua
local mock_snacks = test_utils.create_mock_snacks()
```

### Notification Testing
```lua
-- Clear notifications
test_utils.clear_notifications()

-- Assert notification was sent
test_utils.assert_notification("Expected message", expected_level)
```

## Example Tests

### Testing Config Module
```lua
local function test_config_setup()
  local deps = test_utils.create_test_deps()
  local config = require("go_task.config")
  
  config.setup({
    task_bin = "custom-task",
    debug = true
  }, deps)
  
  local current_config = config.get()
  assert(current_config.task_bin == "custom-task")
  assert(current_config.debug == true)
end
```

### Testing Detector Module
```lua
local function test_detector_go_project()
  local deps = test_utils.create_test_deps()
  local detector = require("go_task.detector")
  
  -- Test with default mocks (Go project detected)
  local is_go = detector.is_go_project(deps)
  assert(is_go == true)
  
  -- Test with custom mocks (no Go files)
  local no_go_deps = test_utils.create_test_deps()
  no_go_deps.vim_fn.filereadable = function(name) return 0 end
  no_go_deps.vim_fn.glob = function(pattern) return "" end
  
  local is_go_no_files = detector.is_go_project(no_go_deps)
  assert(is_go_no_files == false)
end
```

### Testing Parser Module
```lua
local function test_parser_task_list()
  local deps = test_utils.create_test_deps()
  local parser = require("go_task.parser")
  
  local lines = {
    "* build: Build the project",
    "* test: Run tests"
  }
  
  local tasks = parser.parse_task_list(lines, deps)
  assert(#tasks == 2)
  assert(tasks[1].name == "build")
end
```

### Testing Commands Module
```lua
local function test_commands_validation()
  local deps = test_utils.create_test_deps()
  local commands = require("go_task.commands")
  
  test_utils.clear_notifications()
  commands.run_task("", deps)
  test_utils.assert_notification("Task name cannot be empty", 1)
end
```

### Testing Logger Module
```lua
local function test_logger_with_mock_config()
  local deps = test_utils.create_test_deps()
  local logger = require("go_task.logger")
  
  -- Mock config to enable debug
  deps.config = { debug = true }
  
  test_utils.clear_notifications()
  logger.info("Test message", nil, deps)
  test_utils.assert_notification("Test message", 3)
end
```

## Running Tests

### Example Test Runner
```bash
lua tests/run_example_tests.lua
```

### Custom Test Setup
```lua
-- Set up Lua path
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Mock vim globally
vim = require("tests.test_utils").create_mock_vim()

-- Mock external modules
package.loaded["plenary.job"] = require("tests.test_utils").create_mock_job()
package.loaded["snacks"] = require("tests.test_utils").create_mock_snacks()

-- Run your tests
```

## Best Practices

### 1. Always Use Dependency Injection
```lua
-- Good
function my_function(param, deps)
  deps = deps or {}
  local notify = deps.notify or vim.notify
  notify("Message")
end

-- Bad
function my_function(param)
  vim.notify("Message") -- Hard to test
end
```

### 2. Provide Sensible Defaults
```lua
deps = deps or {}
local notify = deps.notify or vim.notify
local config = deps.config or require("go_task.config")
```

### 3. Test Error Conditions
```lua
-- Test invalid inputs
test_utils.clear_notifications()
module.function(nil, deps)
test_utils.assert_notification("Error message", 1)
```

### 4. Mock External Dependencies
```lua
-- Mock Job for testing
deps.Job = {
  new = function(opts)
    return {
      start = function() end,
      result = function() return {"mock", "output"} end
    }
  end
}
```

### 5. Test Module Interactions
```lua
-- Mock dependent modules
deps.runner = {
  run = function(task_name) 
    assert(task_name == "expected-task")
  end
}
```

## Module-Specific Testing Notes

### Config Module
- Test `setup()`, `get()`, `reset()`, `new()`, `toggle_debug()`
- Verify validation works correctly
- Test with various input combinations

### Detector Module
- Test `is_go_project()`, `has_taskfile()`, `should_load()`, `get_project_info()`
- Mock file system operations
- Test different project configurations

### Parser Module
- Test `parse_task_list()` and `parse_task_line()`
- Test with valid and invalid inputs
- Verify error handling

### Commands Module
- Test `run_task()` and `run_task_silent()`
- Test input validation
- Mock runner interactions

### Runner Module
- Test `run()` and `run_silent()`
- Mock Job creation and execution
- Test terminal window creation

### UI Module
- Test `task_picker()` and `get_tasks()`
- Mock Snacks picker
- Test error conditions

### Logger Module
- Test all log levels
- Test with debug enabled/disabled
- Verify notification capture

## Conclusion

The refactored go-task.nvim plugin is now highly testable with comprehensive dependency injection support. The test utilities provide everything needed to write effective unit tests for all modules.

Key benefits:
- Isolated testing of individual modules
- Easy mocking of external dependencies
- Comprehensive error condition testing
- Fast test execution without external dependencies
- Clear separation of concerns 