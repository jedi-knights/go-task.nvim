require("tests/test_helper")
local logger = require("go_task.logger")
local config = require("go_task.config")

describe("logger", function()
  beforeEach(function()
    -- Reset config to known state
    config.setup({ debug = false })
    
    -- Mock vim.notify to capture calls
    local notify_calls = {}
    _G.vim.notify = function(msg, level, opts)
      table.insert(notify_calls, { msg = msg, level = level, opts = opts })
    end
    _G.notify_calls = notify_calls
  end)

  afterEach(function()
    -- Restore original vim.notify
    _G.vim.notify = nil
    _G.notify_calls = nil
  end)

  describe("error", function()
    it("should log error messages when debug is enabled", function()
      config.setup({ debug = true })
      logger.error("Test error message")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Test error message")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.ERROR)
      expect(_G.notify_calls[1].opts.title):toBe("go-task.nvim")
    end)

    it("should not log when debug is disabled", function()
      config.setup({ debug = false })
      logger.error("Test error message")
      
      expect(#_G.notify_calls):toBe(0)
    end)
  end)

  describe("warn", function()
    it("should log warning messages when debug is enabled", function()
      config.setup({ debug = true })
      logger.warn("Test warning message")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Test warning message")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.WARN)
      expect(_G.notify_calls[1].opts.title):toBe("go-task.nvim")
    end)

    it("should not log when debug is disabled", function()
      config.setup({ debug = false })
      logger.warn("Test warning message")
      
      expect(#_G.notify_calls):toBe(0)
    end)
  end)

  describe("info", function()
    it("should log info messages when debug is enabled", function()
      config.setup({ debug = true })
      logger.info("Test info message")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Test info message")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.INFO)
      expect(_G.notify_calls[1].opts.title):toBe("go-task.nvim")
    end)

    it("should not log when debug is disabled", function()
      config.setup({ debug = false })
      logger.info("Test info message")
      
      expect(#_G.notify_calls):toBe(0)
    end)
  end)

  describe("debug", function()
    it("should log debug messages when debug is enabled", function()
      config.setup({ debug = true })
      logger.debug("Test debug message")
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Test debug message")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.DEBUG)
      expect(_G.notify_calls[1].opts.title):toBe("go-task.nvim")
    end)

    it("should not log when debug is disabled", function()
      config.setup({ debug = false })
      logger.debug("Test debug message")
      
      expect(#_G.notify_calls):toBe(0)
    end)
  end)

  describe("log_project_detection", function()
    it("should log Go + Taskfile project detection", function()
      config.setup({ debug = true })
      logger.log_project_detection({
        is_go = true,
        has_taskfile = true
      })
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Detected Go + Taskfile project")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.INFO)
    end)

    it("should log Go project detection", function()
      config.setup({ debug = true })
      logger.log_project_detection({
        is_go = true,
        has_taskfile = false
      })
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Detected Go project")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.INFO)
    end)

    it("should log Taskfile project detection", function()
      config.setup({ debug = true })
      logger.log_project_detection({
        is_go = false,
        has_taskfile = true
      })
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Detected Taskfile project")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.INFO)
    end)

    it("should not log when debug is disabled", function()
      config.setup({ debug = false })
      logger.log_project_detection({
        is_go = true,
        has_taskfile = true
      })
      
      expect(#_G.notify_calls):toBe(0)
    end)
  end)

  describe("log_task_execution", function()
    it("should log successful task execution", function()
      config.setup({ debug = true })
      logger.log_task_execution("test-task", 0)
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task 'test-task' completed successfully with code 0")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.INFO)
    end)

    it("should log failed task execution", function()
      config.setup({ debug = true })
      logger.log_task_execution("test-task", 1)
      
      expect(#_G.notify_calls):toBe(1)
      expect(_G.notify_calls[1].msg):toBe("Task 'test-task' failed with code 1")
      expect(_G.notify_calls[1].level):toBe(vim.log.levels.INFO)
    end)

    it("should not log when debug is disabled", function()
      config.setup({ debug = false })
      logger.log_task_execution("test-task", 0)
      
      expect(#_G.notify_calls):toBe(0)
    end)
  end)
end) 