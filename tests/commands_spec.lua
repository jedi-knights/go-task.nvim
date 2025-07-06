require("tests/test_helper")
local commands = require("go_task.commands")
local config = require("go_task.config")

describe("commands", function()
  beforeEach(function()
    config.setup({ debug = false })
  end)

  describe("run_task", function()
    it("should validate task name is provided", function()
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      commands.run_task("")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name required")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should validate task name is a string", function()
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      commands.run_task(123)
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name must be a string")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should call runner.run with task name", function()
      local runner_calls = {}
      local original_run = require("go_task.runner").run
      require("go_task.runner").run = function(task_name, opts)
        table.insert(runner_calls, { task_name = task_name, opts = opts })
      end
      
      commands.run_task("test-task")
      
      expect(#runner_calls):toBe(1)
      expect(runner_calls[1].task_name):toBe("test-task")
      expect(runner_calls[1].opts):toBeNil()
      
      require("go_task.runner").run = original_run
    end)

    it("should pass options to runner.run", function()
      local runner_calls = {}
      local original_run = require("go_task.runner").run
      require("go_task.runner").run = function(task_name, opts)
        table.insert(runner_calls, { task_name = task_name, opts = opts })
      end
      
      local test_opts = { cwd = "/test/path" }
      commands.run_task("test-task", test_opts)
      
      expect(#runner_calls):toBe(1)
      expect(runner_calls[1].task_name):toBe("test-task")
      expect(runner_calls[1].opts.cwd):toBe("/test/path")
      
      require("go_task.runner").run = original_run
    end)
  end)

  describe("run_task_silent", function()
    it("should validate task name is provided", function()
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      commands.run_task_silent("")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name required")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should validate task name is a string", function()
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      commands.run_task_silent(123)
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name must be a string")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should call runner.run_silent with task name", function()
      local runner_calls = {}
      local original_run_silent = require("go_task.runner").run_silent
      require("go_task.runner").run_silent = function(task_name, opts)
        table.insert(runner_calls, { task_name = task_name, opts = opts })
        return true
      end
      
      local result = commands.run_task_silent("test-task")
      
      expect(#runner_calls):toBe(1)
      expect(runner_calls[1].task_name):toBe("test-task")
      expect(runner_calls[1].opts):toBeNil()
      expect(result):toBe(true)
      
      require("go_task.runner").run_silent = original_run_silent
    end)

    it("should pass options to runner.run_silent", function()
      local runner_calls = {}
      local original_run_silent = require("go_task.runner").run_silent
      require("go_task.runner").run_silent = function(task_name, opts)
        table.insert(runner_calls, { task_name = task_name, opts = opts })
        return true
      end
      
      local test_opts = { cwd = "/test/path" }
      local result = commands.run_task_silent("test-task", test_opts)
      
      expect(#runner_calls):toBe(1)
      expect(runner_calls[1].task_name):toBe("test-task")
      expect(runner_calls[1].opts.cwd):toBe("/test/path")
      expect(result):toBe(true)
      
      require("go_task.runner").run_silent = original_run_silent
    end)
  end)

  describe("task_picker", function()
    it("should call ui.task_picker", function()
      local ui_calls = 0
      local original_task_picker = require("go_task.ui").task_picker
      require("go_task.ui").task_picker = function()
        ui_calls = ui_calls + 1
      end
      
      commands.task_picker()
      
      expect(ui_calls):toBe(1)
      
      require("go_task.ui").task_picker = original_task_picker
    end)
  end)

  describe("toggle_debug", function()
    it("should call config.toggle_debug", function()
      local config_calls = 0
      local original_toggle_debug = require("go_task.config").toggle_debug
      require("go_task.config").toggle_debug = function()
        config_calls = config_calls + 1
      end
      
      commands.toggle_debug()
      
      expect(config_calls):toBe(1)
      
      require("go_task.config").toggle_debug = original_toggle_debug
    end)
  end)
end)
