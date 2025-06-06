local core = require("go_task.core")

describe("go_task.core", function()
  before_each(function()
    -- Reset injected dependencies before each test
    core._with({
      shell = {
        run = function(cmd, args, cwd)
          return args[1] ~= "fail", args[1] == "fail" and "failed to run" or nil
        end,
        capture = function(cmd, args)
          if args[1] == "--list" then
            return true, { "* test: Run tests", "* build: Build binary" }
          else
            return false, "unknown command"
          end
        end
      },
      notify = function() end,
      cwd = function() return "/mock/path" end,
      findfile = function() return "Taskfile.yml" end,
      config = { debug = false },
      env = {}
    })
  end)

  describe("find_taskfile", function()
    it("returns path if Taskfile found", function()
      assert.equals("Taskfile.yml", core.find_taskfile())
    end)

    it("returns nil if Taskfile not found", function()
      core._with({ findfile = function() return "" end })
      assert.is_nil(core.find_taskfile())
    end)
  end)

  describe("run", function()
    it("fails when no task name is given", function()
      local ok, msg = core.run("")
      assert.is_false(ok)
      assert.matches("required", msg)
    end)

    it("returns success when task runs", function()
      local ok, msg = core.run("test")
      assert.is_true(ok)
      assert.matches("completed", msg)
    end)

    it("returns failure if task errors", function()
      local ok, msg = core.run("fail")
      assert.is_false(ok)
      assert.matches("failed", msg)
    end)
  end)

  describe("list", function()
    it("returns list of tasks", function()
      local ok, result = core.list()
      assert.is_true(ok)
      assert.are.same({ "* test: Run tests", "* build: Build binary" }, result)
    end)

    it("returns error if shell fails", function()
      core._with({
        shell = {
          capture = function() return false, "failed to list" end
        }
      })
      local ok, result = core.list()
      assert.is_false(ok)
      assert.equals("failed to list", result)
    end)
  end)

  describe("reload", function()
    it("returns stubbed reload message", function()
      local ok, msg = core.reload()
      assert.is_true(ok)
      assert.equals("Reload is not implemented yet", msg)
    end)
  end)
end)
