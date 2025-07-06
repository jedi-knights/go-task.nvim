require("tests/test_helper")
local runner = require("go_task.runner")
local config = require("go_task.config")

describe("runner", function()
  beforeEach(function()
    config.setup({ debug = false })
  end)

  describe("run", function()
    it("should handle empty task name", function()
      -- Mock vim.notify to capture calls
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      runner.run("")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name required")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should handle nil task name", function()
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      runner.run(nil)
      
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
      
      runner.run(123)
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name must be a string")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should create terminal window and run task", function()
      -- Mock vim.api functions
      local api_calls = {}
      local original_create_buf = vim.api.nvim_create_buf
      local original_open_win = vim.api.nvim_open_win
      local original_buf_set_lines = vim.api.nvim_buf_set_lines
      
      vim.api.nvim_create_buf = function(_, _)
        api_calls.create_buf = true
        return 1
      end
      
      vim.api.nvim_open_win = function(buf, _, opts)
        api_calls.open_win = { buf = buf, opts = opts }
        return 1
      end
      
      vim.api.nvim_buf_set_lines = function(buf, start, end_, _, lines)
        table.insert(api_calls.buf_set_lines or {}, { buf = buf, start = start, end_ = end_, lines = lines })
      end
      
      -- Mock Job
      local job_calls = {}
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        job_calls.opts = opts
        return {
          start = function()
            job_calls.started = true
            -- Simulate stdout
            if opts.on_stdout then
              opts.on_stdout(nil, "Task output")
            end
            -- Simulate exit
            if opts.on_exit then
              opts.on_exit(nil, 0)
            end
          end
        }
      end
      
      runner.run("test-task")
      
      expect(api_calls.create_buf):toBe(true)
      expect(api_calls.open_win).toBeTruthy()
      expect(job_calls.started):toBe(true)
      expect(job_calls.opts.command):toBe("task")
      expect(job_calls.opts.args[1]):toBe("test-task")
      
      -- Restore original functions
      vim.api.nvim_create_buf = original_create_buf
      vim.api.nvim_open_win = original_open_win
      vim.api.nvim_buf_set_lines = original_buf_set_lines
      require("plenary.job").new = original_job.new
    end)

    it("should handle callbacks when provided", function()
      local callback_calls = {}
      local test_opts = {
        on_stdout = function(_, line)
          table.insert(callback_calls.stdout, line)
        end,
        on_stderr = function(_, line)
          table.insert(callback_calls.stderr, line)
        end,
        on_exit = function(_, code)
          callback_calls.exit_code = code
        end
      }
      
      callback_calls.stdout = {}
      callback_calls.stderr = {}
      
      -- Mock vim.api functions
      local original_create_buf = vim.api.nvim_create_buf
      local original_open_win = vim.api.nvim_open_win
      local original_buf_set_lines = vim.api.nvim_buf_set_lines
      
      vim.api.nvim_create_buf = function() return 1 end
      vim.api.nvim_open_win = function() return 1 end
      vim.api.nvim_buf_set_lines = function() end
      
      -- Mock Job
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        return {
          start = function()
            if opts.on_stdout then
              opts.on_stdout(nil, "stdout line")
            end
            if opts.on_stderr then
              opts.on_stderr(nil, "stderr line")
            end
            if opts.on_exit then
              opts.on_exit(nil, 42)
            end
          end
        }
      end
      
      runner.run("test-task", test_opts)
      
      expect(#callback_calls.stdout):toBe(1)
      expect(callback_calls.stdout[1]):toBe("stdout line")
      expect(#callback_calls.stderr):toBe(1)
      expect(callback_calls.stderr[1]):toBe("stderr line")
      expect(callback_calls.exit_code):toBe(42)
      
      -- Restore original functions
      vim.api.nvim_create_buf = original_create_buf
      vim.api.nvim_open_win = original_open_win
      vim.api.nvim_buf_set_lines = original_buf_set_lines
      require("plenary.job").new = original_job.new
    end)
  end)

  describe("run_silent", function()
    it("should handle empty task name", function()
      local notify_calls = {}
      _G.vim.notify = function(msg, level, opts)
        table.insert(notify_calls, { msg = msg, level = level, opts = opts })
      end
      _G.notify_calls = notify_calls
      
      runner.run_silent("")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task name required")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      
      _G.vim.notify = nil
      _G.notify_calls = nil
    end)

    it("should run task without UI", function()
      local job_calls = {}
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        job_calls.opts = opts
        return {
          start = function()
            job_calls.started = true
          end
        }
      end
      
      local result = runner.run_silent("test-task")
      
      expect(job_calls.started):toBe(true)
      expect(job_calls.opts.command):toBe("task")
      expect(job_calls.opts.args[1]):toBe("test-task")
      expect(result).toBeTruthy()
      
      require("plenary.job").new = original_job.new
    end)

    it("should use custom working directory when provided", function()
      local job_calls = {}
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        job_calls.opts = opts
        return {
          start = function()
            job_calls.started = true
          end
        }
      end
      
      runner.run_silent("test-task", { cwd = "/custom/path" })
      
      expect(job_calls.opts.cwd):toBe("/custom/path")
      
      require("plenary.job").new = original_job.new
    end)

    it("should handle callbacks when provided", function()
      local callback_calls = {}
      local test_opts = {
        on_stdout = function(_, line)
          table.insert(callback_calls.stdout, line)
        end,
        on_stderr = function(_, line)
          table.insert(callback_calls.stderr, line)
        end,
        on_exit = function(_, code)
          callback_calls.exit_code = code
        end
      }
      
      callback_calls.stdout = {}
      callback_calls.stderr = {}
      
      local original_job = require("plenary.job")
      require("plenary.job").new = function(opts)
        return {
          start = function()
            if opts.on_stdout then
              opts.on_stdout(nil, "silent stdout")
            end
            if opts.on_stderr then
              opts.on_stderr(nil, "silent stderr")
            end
            if opts.on_exit then
              opts.on_exit(nil, 99)
            end
          end
        }
      end
      
      runner.run_silent("test-task", test_opts)
      
      expect(#callback_calls.stdout):toBe(1)
      expect(callback_calls.stdout[1]):toBe("silent stdout")
      expect(#callback_calls.stderr):toBe(1)
      expect(callback_calls.stderr[1]):toBe("silent stderr")
      expect(callback_calls.exit_code):toBe(99)
      
      require("plenary.job").new = original_job.new
    end)
  end)
end)
