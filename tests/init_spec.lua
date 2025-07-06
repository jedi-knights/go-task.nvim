require("tests/test_helper")
local go_task = require("go_task")

describe("go_task", function()
  describe("setup", function()
    it("should call config.setup with provided options", function()
      local test_config = {
        task_bin = "test-task",
        debug = true
      }
      
      -- Mock config.setup to capture calls
      local config_calls = {}
      local original_setup = require("go_task.config").setup
      require("go_task.config").setup = function(opts)
        table.insert(config_calls, opts)
      end
      
      go_task.setup(test_config)
      
      expect(#config_calls):toBe(1)
      expect(config_calls[1].task_bin):toBe("test-task")
      expect(config_calls[1].debug):toBe(true)
      
      -- Restore original function
      require("go_task.config").setup = original_setup
    end)

    it("should call config.setup with nil when no options provided", function()
      local config_calls = {}
      local original_setup = require("go_task.config").setup
      require("go_task.config").setup = function(opts)
        table.insert(config_calls, opts)
      end
      
      go_task.setup()
      
      expect(#config_calls):toBe(1)
      expect(config_calls[1]):toBeNil()
      
      -- Restore original function
      require("go_task.config").setup = original_setup
    end)
  end)

  describe("get_config", function()
    it("should return configuration from config.get", function()
      local test_config = {
        task_bin = "test-task",
        debug = true
      }
      
      -- Mock config.get to return test config
      local original_get = require("go_task.config").get
      require("go_task.config").get = function()
        return test_config
      end
      
      local result = go_task.get_config()
      
      expect(result.task_bin):toBe("test-task")
      expect(result.debug):toBe(true)
      
      -- Restore original function
      require("go_task.config").get = original_get
    end)
  end)

  describe("run_task", function()
    it("should call commands.run_task with provided task name", function()
      local commands_calls = {}
      local original_run_task = require("go_task.commands").run_task
      require("go_task.commands").run_task = function(task_name)
        table.insert(commands_calls, task_name)
      end
      
      go_task.run_task("test-task")
      
      expect(#commands_calls):toBe(1)
      expect(commands_calls[1]):toBe("test-task")
      
      -- Restore original function
      require("go_task.commands").run_task = original_run_task
    end)
  end)

  describe("run_task_silent", function()
    it("should call commands.run_task_silent with provided task name and options", function()
      local commands_calls = {}
      local original_run_task_silent = require("go_task.commands").run_task_silent
      require("go_task.commands").run_task_silent = function(task_name, opts)
        table.insert(commands_calls, { task_name = task_name, opts = opts })
      end
      
      local test_opts = { cwd = "/test/path" }
      go_task.run_task_silent("test-task", test_opts)
      
      expect(#commands_calls):toBe(1)
      expect(commands_calls[1].task_name):toBe("test-task")
      expect(commands_calls[1].opts.cwd):toBe("/test/path")
      
      -- Restore original function
      require("go_task.commands").run_task_silent = original_run_task_silent
    end)
  end)

  describe("get_tasks", function()
    it("should call ui.get_tasks with provided callback", function()
      local ui_calls = {}
      local original_get_tasks = require("go_task.ui").get_tasks
      require("go_task.ui").get_tasks = function(callback)
        table.insert(ui_calls, callback)
      end
      
      local test_callback = function() end
      go_task.get_tasks(test_callback)
      
      expect(#ui_calls):toBe(1)
      expect(ui_calls[1]):toBe(test_callback)
      
      -- Restore original function
      require("go_task.ui").get_tasks = original_get_tasks
    end)
  end)

  describe("should_load", function()
    it("should call detector.should_load", function()
      local detector_calls = 0
      local original_should_load = require("go_task.detector").should_load
      require("go_task.detector").should_load = function()
        detector_calls = detector_calls + 1
        return true
      end
      
      local result = go_task.should_load()
      
      expect(detector_calls):toBe(1)
      expect(result):toBe(true)
      
      -- Restore original function
      require("go_task.detector").should_load = original_should_load
    end)
  end)

  describe("get_project_info", function()
    it("should call detector.get_project_info", function()
      local test_info = {
        is_go = true,
        has_taskfile = true,
        cwd = "/test/path"
      }
      
      local detector_calls = 0
      local original_get_project_info = require("go_task.detector").get_project_info
      require("go_task.detector").get_project_info = function()
        detector_calls = detector_calls + 1
        return test_info
      end
      
      local result = go_task.get_project_info()
      
      expect(detector_calls):toBe(1)
      expect(result.is_go):toBe(true)
      expect(result.has_taskfile):toBe(true)
      expect(result.cwd):toBe("/test/path")
      
      -- Restore original function
      require("go_task.detector").get_project_info = original_get_project_info
    end)
  end)
end) 