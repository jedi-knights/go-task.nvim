require("tests/test_helper")
local go_task = require("go_task")
local config = require("go_task.config")
local detector = require("go_task.detector")
local logger = require("go_task.logger")

describe("integration", function()
  describe("plugin initialization", function()
    it("should setup config and detect project correctly", function()
      -- Mock detector to return known state
      local original_should_load = detector.should_load
      local original_get_project_info = detector.get_project_info
      
      detector.should_load = function() return true end
      detector.get_project_info = function()
        return {
          is_go = true,
          has_taskfile = true,
          cwd = "/test/project"
        }
      end
      
      -- Mock logger to capture calls
      local log_calls = {}
      local original_log_project = logger.log_project_detection
      logger.log_project_detection = function(info)
        table.insert(log_calls, info)
      end
      
      -- Setup plugin
      go_task.setup({
        debug = true,
        task_bin = "go-task"
      })
      
      -- Verify config was set
      local current_config = go_task.get_config()
      expect(current_config.debug):toBe(true)
      expect(current_config.task_bin):toBe("go-task")
      
      -- Verify project detection was called
      expect(go_task.should_load()):toBe(true)
      
      local project_info = go_task.get_project_info()
      expect(project_info.is_go):toBe(true)
      expect(project_info.has_taskfile):toBe(true)
      expect(project_info.cwd):toBe("/test/project")
      
      -- Restore original functions
      detector.should_load = original_should_load
      detector.get_project_info = original_get_project_info
      logger.log_project_detection = original_log_project
    end)
  end)

  describe("task execution flow", function()
    it("should execute task through complete flow", function()
      -- Setup plugin
      go_task.setup({ debug = false })
      
      -- Mock runner to capture calls
      local runner_calls = {}
      local original_run = require("go_task.runner").run
      require("go_task.runner").run = function(task_name, opts)
        table.insert(runner_calls, { task_name = task_name, opts = opts })
      end
      
      -- Mock logger to capture calls
      local log_calls = {}
      local original_log_execution = logger.log_task_execution
      logger.log_task_execution = function(task_name, code)
        table.insert(log_calls, { task_name = task_name, code = code })
      end
      
      -- Execute task through commands
      local commands = require("go_task.commands")
      commands.run_task("test-task")
      
      -- Verify runner was called
      expect(#runner_calls):toBe(1)
      expect(runner_calls[1].task_name):toBe("test-task")
      
      -- Restore original functions
      require("go_task.runner").run = original_run
      logger.log_task_execution = original_log_execution
    end)
  end)

  describe("task listing flow", function()
    it("should list tasks through complete flow", function()
      -- Setup plugin
      go_task.setup({ debug = false })
      
      -- Mock UI to capture calls
      local ui_calls = {}
      local original_get_tasks = require("go_task.ui").get_tasks
      require("go_task.ui").get_tasks = function(callback)
        table.insert(ui_calls, callback)
        -- Simulate callback with test tasks
        callback({
          { name = "build", desc = "Build project" },
          { name = "test", desc = "Run tests" }
        })
      end
      
      -- Get tasks through main API
      local received_tasks = nil
      go_task.get_tasks(function(tasks)
        received_tasks = tasks
      end)
      
      -- Verify UI was called
      expect(#ui_calls):toBe(1)
      expect(type(ui_calls[1])):toBe("function")
      
      -- Verify tasks were received
      expect(#received_tasks):toBe(2)
      expect(received_tasks[1].name):toBe("build")
      expect(received_tasks[1].desc):toBe("Build project")
      expect(received_tasks[2].name):toBe("test")
      expect(received_tasks[2].desc):toBe("Run tests")
      
      -- Restore original function
      require("go_task.ui").get_tasks = original_get_tasks
    end)
  end)

  describe("error handling flow", function()
    it("should handle errors gracefully across modules", function()
      -- Setup plugin with debug enabled
      go_task.setup({ debug = true })
      
      -- Mock vim.notify to capture error messages
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      -- Mock runner to simulate error
      local original_run = require("go_task.runner").run
      require("go_task.runner").run = function(task_name, opts)
        if opts and opts.on_stderr then
          opts.on_stderr(nil, "Task execution failed")
        end
        if opts and opts.on_exit then
          opts.on_exit(nil, 1)
        end
      end
      
      -- Execute task that will fail
      local commands = require("go_task.commands")
      commands.run_task("failing-task")
      
      -- Verify error was handled
      expect(#_G.notify_calls):toBeGreaterThan(0)
      
      -- Restore original functions
      require("go_task.runner").run = original_run
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)
  end)

  describe("configuration flow", function()
    it("should handle configuration changes correctly", function()
      -- Initial setup
      go_task.setup({
        task_bin = "task",
        debug = false
      })
      
      local initial_config = go_task.get_config()
      expect(initial_config.task_bin):toBe("task")
      expect(initial_config.debug):toBe(false)
      
      -- Toggle debug
      local commands = require("go_task.commands")
      commands.toggle_debug()
      
      local updated_config = go_task.get_config()
      expect(updated_config.debug):toBe(true)
      
      -- Toggle debug again
      commands.toggle_debug()
      
      local final_config = go_task.get_config()
      expect(final_config.debug):toBe(false)
    end)
  end)

  describe("project detection integration", function()
    it("should integrate project detection with logging", function()
      -- Setup plugin with debug enabled
      go_task.setup({ debug = true })
      
      -- Mock detector to return known state
      local original_get_project_info = detector.get_project_info
      detector.get_project_info = function()
        return {
          is_go = true,
          has_taskfile = true,
          cwd = "/test/project"
        }
      end
      
      -- Mock logger to capture calls
      local log_calls = {}
      local original_log_project = logger.log_project_detection
      logger.log_project_detection = function(info)
        table.insert(log_calls, info)
      end
      
      -- Get project info (this should trigger logging)
      local project_info = go_task.get_project_info()
      
      -- Verify project info is correct
      expect(project_info.is_go):toBe(true)
      expect(project_info.has_taskfile):toBe(true)
      expect(project_info.cwd):toBe("/test/project")
      
      -- Verify logging was called
      expect(#log_calls):toBe(1)
      expect(log_calls[1].is_go):toBe(true)
      expect(log_calls[1].has_taskfile):toBe(true)
      
      -- Restore original functions
      detector.get_project_info = original_get_project_info
      logger.log_project_detection = original_log_project
    end)
  end)
end) 