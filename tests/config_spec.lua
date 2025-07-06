require("tests/test_helper")
local config = require("go_task.config")

describe("config", function()
  describe("setup", function()
    it("should set default values when no options provided", function()
      config.setup()
      local current_config = config.get()
      expect(current_config.task_bin):toBe("task")
      expect(current_config.taskfile):toBe("Taskfile.yml")
      expect(current_config.debug):toBe(false)
      expect(current_config.log_level):toBe(vim.log.levels.INFO)
    end)

    it("should override default values with provided options", function()
      config.setup({
        task_bin = "go-task",
        taskfile = "Taskfile.yaml",
        debug = true,
        log_level = vim.log.levels.DEBUG
      })
      local current_config = config.get()
      expect(current_config.task_bin):toBe("go-task")
      expect(current_config.taskfile):toBe("Taskfile.yaml")
      expect(current_config.debug):toBe(true)
      expect(current_config.log_level):toBe(vim.log.levels.DEBUG)
    end)

    it("should validate task_bin is a non-empty string", function()
      expect(function()
        config.setup({ task_bin = "" })
      end).toThrow()
      
      expect(function()
        config.setup({ task_bin = nil })
      end).toThrow()
      
      expect(function()
        config.setup({ task_bin = 123 })
      end).toThrow()
    end)

    it("should validate taskfile is a non-empty string", function()
      expect(function()
        config.setup({ taskfile = "" })
      end).toThrow()
      
      expect(function()
        config.setup({ taskfile = nil })
      end).toThrow()
      
      expect(function()
        config.setup({ taskfile = 123 })
      end).toThrow()
    end)

    it("should validate debug is a boolean", function()
      expect(function()
        config.setup({ debug = "true" })
      end).toThrow()
      
      expect(function()
        config.setup({ debug = 1 })
      end).toThrow()
    end)

    it("should validate log_level is a number", function()
      expect(function()
        config.setup({ log_level = "INFO" })
      end).toThrow()
      
      expect(function()
        config.setup({ log_level = true })
      end).toThrow()
    end)
  end)

  describe("toggle_debug", function()
    it("should toggle debug from false to true", function()
      config.setup({ debug = false })
      config.toggle_debug()
      expect(config.get().debug):toBe(true)
    end)

    it("should toggle debug from true to false", function()
      config.setup({ debug = true })
      config.toggle_debug()
      expect(config.get().debug):toBe(false)
    end)
  end)

  describe("get", function()
    it("should return the current configuration", function()
      local test_config = {
        task_bin = "test-task",
        taskfile = "test.yml",
        debug = true,
        log_level = vim.log.levels.WARN
      }
      config.setup(test_config)
      local current_config = config.get()
      expect(current_config.task_bin):toBe(test_config.task_bin)
      expect(current_config.taskfile):toBe(test_config.taskfile)
      expect(current_config.debug):toBe(test_config.debug)
      expect(current_config.log_level):toBe(test_config.log_level)
    end)
  end)
end) 