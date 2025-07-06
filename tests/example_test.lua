-- Example test demonstrating how to test the refactored modules
local test_utils = require("tests.test_utils")

-- Example test for config module
local function test_config_setup()
  print("Testing config.setup with dependency injection...")
  
  local deps = test_utils.create_test_deps()
  local config = require("go_task.config")
  
  -- Clear any previous notifications
  test_utils.clear_notifications()
  
  -- Test setup with custom options
  config.setup({
    task_bin = "custom-task",
    debug = true
  }, deps)
  
  local current_config = config.get()
  assert(current_config.task_bin == "custom-task", "task_bin should be set to custom-task")
  assert(current_config.debug == true, "debug should be set to true")
  
  print("✓ Config setup test passed")
end

-- Example test for detector module
local function test_detector_go_project()
  print("Testing detector.is_go_project with dependency injection...")
  
  local deps = test_utils.create_test_deps()
  local detector = require("go_task.detector")
  
  -- Test Go project detection
  local is_go = detector.is_go_project(deps)
  assert(is_go == true, "Should detect Go project")
  
  -- Test with mock that returns no Go files
  local no_go_deps = test_utils.create_test_deps()
  no_go_deps.vim_fn.filereadable = function(name) return 0 end
  no_go_deps.vim_fn.glob = function(pattern) return "" end
  
  local is_go_no_files = detector.is_go_project(no_go_deps)
  assert(is_go_no_files == false, "Should not detect Go project when no files exist")
  
  print("✓ Detector Go project test passed")
end

-- Example test for parser module
local function test_parser_task_list()
  print("Testing parser.parse_task_list with dependency injection...")
  
  local deps = test_utils.create_test_deps()
  local parser = require("go_task.parser")
  
  -- Test parsing valid task list
  local lines = {
    "* build: Build the project",
    "* test: Run tests",
    "* clean: Clean build artifacts"
  }
  
  local tasks = parser.parse_task_list(lines, deps)
  assert(#tasks == 3, "Should parse 3 tasks")
  assert(tasks[1].name == "build", "First task should be 'build'")
  assert(tasks[1].desc == "Build the project", "First task description should match")
  
  -- Test parsing invalid input
  test_utils.clear_notifications()
  local invalid_tasks = parser.parse_task_list("not a table", deps)
  assert(#invalid_tasks == 0, "Should return empty array for invalid input")
  test_utils.assert_notification("Invalid input: lines must be a table", 1)
  
  print("✓ Parser task list test passed")
end

-- Example test for commands module
local function test_commands_validation()
  print("Testing commands validation with dependency injection...")
  
  local deps = test_utils.create_test_deps()
  local commands = require("go_task.commands")
  
  -- Test empty task name
  test_utils.clear_notifications()
  commands.run_task("", deps)
  test_utils.assert_notification("Task name cannot be empty", 1)
  
  -- Test nil task name
  test_utils.clear_notifications()
  commands.run_task(nil, deps)
  test_utils.assert_notification("Task name required", 1)
  
  -- Test non-string task name
  test_utils.clear_notifications()
  commands.run_task(123, deps)
  test_utils.assert_notification("Task name must be a string", 1)
  
  print("✓ Commands validation test passed")
end

-- Example test for logger module
local function test_logger_with_mock_config()
  print("Testing logger with mock config...")
  
  local deps = test_utils.create_test_deps()
  local logger = require("go_task.logger")
  
  -- Create mock config that enables debug
  deps.config = {
    debug = true
  }
  
  -- Test logging with debug enabled
  test_utils.clear_notifications()
  logger.info("Test message", nil, deps)
  test_utils.assert_notification("Test message", 3)
  
  -- Test logging with debug disabled
  deps.config.debug = false
  test_utils.clear_notifications()
  logger.info("Test message", nil, deps)
  assert(#test_utils.get_notifications() == 0, "Should not log when debug is disabled")
  
  print("✓ Logger test passed")
end

-- Run all example tests
local function run_example_tests()
  print("Running example tests for refactored modules...")
  print("=" .. string.rep("=", 50))
  
  local success, err = pcall(function()
    test_config_setup()
    test_detector_go_project()
    test_parser_task_list()
    test_commands_validation()
    test_logger_with_mock_config()
  end)
  
  if success then
    print("=" .. string.rep("=", 50))
    print("🎉 All example tests passed!")
  else
    print("❌ Test failed: " .. tostring(err))
  end
end

-- Export for use in other test files
return {
  run_example_tests = run_example_tests,
  test_config_setup = test_config_setup,
  test_detector_go_project = test_detector_go_project,
  test_parser_task_list = test_parser_task_list,
  test_commands_validation = test_commands_validation,
  test_logger_with_mock_config = test_logger_with_mock_config,
} 