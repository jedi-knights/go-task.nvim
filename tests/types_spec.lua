require("tests/test_helper")
local types = require("go_task.types")

describe("types", function()
  describe("Config", function()
    it("should have all required fields", function()
      local config = types.Config()
      expect(config):toHaveProperty("task_bin")
      expect(config):toHaveProperty("taskfile")
      expect(config):toHaveProperty("debug")
      expect(config):toHaveProperty("log_level")
    end)

    it("should have correct default values", function()
      local config = types.Config()
      expect(config.task_bin):toBe("task")
      expect(config.taskfile):toBe("Taskfile.yml")
      expect(config.debug):toBe(false)
      expect(config.log_level):toBe(vim.log.levels.INFO)
    end)

    it("should accept custom values", function()
      local custom_config = types.Config({
        task_bin = "go-task",
        taskfile = "Taskfile.yaml",
        debug = true,
        log_level = vim.log.levels.DEBUG
      })
      
      expect(custom_config.task_bin):toBe("go-task")
      expect(custom_config.taskfile):toBe("Taskfile.yaml")
      expect(custom_config.debug):toBe(true)
      expect(custom_config.log_level):toBe(vim.log.levels.DEBUG)
    end)
  end)

  describe("Task", function()
    it("should have all required fields", function()
      local task = types.Task()
      expect(task):toHaveProperty("name")
      expect(task):toHaveProperty("desc")
    end)

    it("should have correct default values", function()
      local task = types.Task()
      expect(task.name):toBe("")
      expect(task.desc):toBe("")
    end)

    it("should accept custom values", function()
      local custom_task = types.Task({
        name = "build",
        desc = "Build the project"
      })
      
      expect(custom_task.name):toBe("build")
      expect(custom_task.desc):toBe("Build the project")
    end)
  end)

  describe("ProjectInfo", function()
    it("should have all required fields", function()
      local project_info = types.ProjectInfo()
      expect(project_info):toHaveProperty("is_go")
      expect(project_info):toHaveProperty("has_taskfile")
      expect(project_info):toHaveProperty("cwd")
    end)

    it("should have correct default values", function()
      local project_info = types.ProjectInfo()
      expect(project_info.is_go):toBe(false)
      expect(project_info.has_taskfile):toBe(false)
      expect(project_info.cwd):toBe("")
    end)

    it("should accept custom values", function()
      local custom_project_info = types.ProjectInfo({
        is_go = true,
        has_taskfile = true,
        cwd = "/test/path"
      })
      
      expect(custom_project_info.is_go):toBe(true)
      expect(custom_project_info.has_taskfile):toBe(true)
      expect(custom_project_info.cwd):toBe("/test/path")
    end)
  end)

  describe("RunnerOptions", function()
    it("should have all required fields", function()
      local options = types.RunnerOptions()
      expect(options):toHaveProperty("cwd")
      expect(options):toHaveProperty("on_stdout")
      expect(options):toHaveProperty("on_stderr")
      expect(options):toHaveProperty("on_exit")
    end)

    it("should have correct default values", function()
      local options = types.RunnerOptions()
      expect(options.cwd):toBe("")
      expect(options.on_stdout):toBeNil()
      expect(options.on_stderr):toBeNil()
      expect(options.on_exit):toBeNil()
    end)

    it("should accept custom values", function()
      local test_callback = function() end
      local custom_options = types.RunnerOptions({
        cwd = "/test/path",
        on_stdout = test_callback,
        on_stderr = test_callback,
        on_exit = test_callback
      })
      
      expect(custom_options.cwd):toBe("/test/path")
      expect(custom_options.on_stdout):toBe(test_callback)
      expect(custom_options.on_stderr):toBe(test_callback)
      expect(custom_options.on_exit):toBe(test_callback)
    end)
  end)

  describe("is_config", function()
    it("should return true for valid config", function()
      local config = types.Config()
      expect(types.is_config(config)):toBe(true)
    end)

    it("should return false for invalid config", function()
      expect(types.is_config({})):toBe(false)
      expect(types.is_config(nil)):toBe(false)
      expect(types.is_config("string")):toBe(false)
    end)
  end)

  describe("is_task", function()
    it("should return true for valid task", function()
      local task = types.Task()
      expect(types.is_task(task)):toBe(true)
    end)

    it("should return false for invalid task", function()
      expect(types.is_task({})):toBe(false)
      expect(types.is_task(nil)):toBe(false)
      expect(types.is_task("string")):toBe(false)
    end)
  end)

  describe("is_project_info", function()
    it("should return true for valid project info", function()
      local project_info = types.ProjectInfo()
      expect(types.is_project_info(project_info)):toBe(true)
    end)

    it("should return false for invalid project info", function()
      expect(types.is_project_info({})):toBe(false)
      expect(types.is_project_info(nil)):toBe(false)
      expect(types.is_project_info("string")):toBe(false)
    end)
  end)

  describe("is_runner_options", function()
    it("should return true for valid runner options", function()
      local options = types.RunnerOptions()
      expect(types.is_runner_options(options)):toBe(true)
    end)

    it("should return false for invalid runner options", function()
      expect(types.is_runner_options({})):toBe(false)
      expect(types.is_runner_options(nil)):toBe(false)
      expect(types.is_runner_options("string")):toBe(false)
    end)
  end)
end) 