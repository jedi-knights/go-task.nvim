require("tests/test_helper")
local ui = require("go_task.ui")
local config = require("go_task.config")

describe("ui", function()
  beforeEach(function()
    config.setup({ debug = false })
  end)

  describe("task_picker", function()
    it("should check if task binary is available", function()
      -- Mock vim.fn.executable to return 0 (not found)
      local original_executable = vim.fn.executable
      vim.fn.executable = function(cmd)
        if cmd == "task" then
          return 0
        end
        return original_executable(cmd)
      end
      
      -- Mock vim.notify to capture calls
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      ui.task_picker()
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task binary 'task' not found in PATH")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      -- Restore original functions
      vim.fn.executable = original_executable
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should handle task list errors", function()
      -- Mock vim.fn.executable to return 1 (found)
      local original_executable = vim.fn.executable
      vim.fn.executable = function(cmd)
        if cmd == "task" then
          return 1
        end
        return original_executable(cmd)
      end
      
      -- Mock vim.notify to capture calls
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      -- Mock Job to simulate error
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        return {
          start = function()
            if opts.on_stderr then
              opts.on_stderr(nil, "task command not found")
            end
          end
        }
      end
      
      ui.task_picker()
      
      -- Wait a bit for async operations
      vim.wait(100)
      
      expect(#_G.notify_calls):toBeGreaterThan(0)
      
      -- Restore original functions
      vim.fn.executable = original_executable
      require("plenary.job").new = original_job.new
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)
  end)

  describe("get_tasks", function()
    it("should require callback function", function()
      -- Mock vim.notify to capture calls
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      ui.get_tasks(nil)
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Callback function required")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should handle task list errors in get_tasks", function()
      -- Mock vim.notify to capture calls
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      local callback_called = false
      local callback_tasks = nil
      
      -- Mock Job to simulate error
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        return {
          start = function()
            if opts.on_stderr then
              opts.on_stderr(nil, "task command not found")
            end
          end
        }
      end
      
      ui.get_tasks(function(tasks)
        callback_called = true
        callback_tasks = tasks
      end)
      
      -- Wait a bit for async operations
      vim.wait(100)
      
      expect(callback_called):toBe(true)
      expect(callback_tasks):toEqual({})
      expect(#_G.notify_calls):toBeGreaterThan(0)
      
      -- Restore original functions
      require("plenary.job").new = original_job.new
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should call callback with parsed tasks", function()
      local callback_called = false
      local callback_tasks = nil
      
      -- Mock Job to simulate success
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        return {
          start = function()
            if opts.on_exit then
              -- Simulate task --list output
              local lines = {
                "* build: Build the binary",
                "* test: Run tests"
              }
              opts.on_exit({ result = function() return lines end })
            end
          end
        }
      end
      
      ui.get_tasks(function(tasks)
        callback_called = true
        callback_tasks = tasks
      end)
      
      -- Wait a bit for async operations
      vim.wait(100)
      
      expect(callback_called):toBe(true)
      expect(#callback_tasks):toBe(2)
      expect(callback_tasks[1].name):toBe("build")
      expect(callback_tasks[1].desc):toBe("Build the binary")
      expect(callback_tasks[2].name):toBe("test")
      expect(callback_tasks[2].desc):toBe("Run tests")
      
      -- Restore original functions
      require("plenary.job").new = original_job.new
    end)
  end)
end) 