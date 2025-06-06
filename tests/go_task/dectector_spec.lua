local detector = require("go_task.detector")

describe("go_task.detector", function()
  local notified = nil

  before_each(function()
    notified = nil
    detector._with({
      filereadable = function(path)
        return path == "go.mod" or path == "Taskfile.yml"
      end,
      glob = function(pattern)
        return pattern == "*.go" and ""
      end,
      notify = function(msg, level, opts)
        notified = { msg = msg, level = level, opts = opts }
      end,
      nvim_list_uis = function() return { {} } end,
      env = {},
      config = { debug = false }
    })
  end)

  describe("is_go_project", function()
    it("returns true if go.mod is present", function()
      assert.is_true(detector.is_go_project())
    end)

    it("returns true if any *.go file is present", function()
      detector._with({
        filereadable = function() return false end,
        glob = function() return "main.go" end,
      })
      assert.is_true(detector.is_go_project())
    end)

    it("returns false if no go.mod or .go files", function()
      detector._with({
        filereadable = function() return false end,
        glob = function() return "" end,
      })
      assert.is_false(detector.is_go_project())
    end)
  end)

  describe("has_taskfile", function()
    it("returns true if Taskfile.yml is present", function()
      assert.is_true(detector.has_taskfile())
    end)

    it("returns true if Taskfile.yaml is present", function()
      detector._with({
        filereadable = function(path)
          return path == "Taskfile.yaml"
        end,
      })
      assert.is_true(detector.has_taskfile())
    end)

    it("returns false if no Taskfile is present", function()
      detector._with({
        filereadable = function() return false end
      })
      assert.is_false(detector.has_taskfile())
    end)
  end)

  describe("should_load", function()
    it("returns true if Go project", function()
      detector._with({
        filereadable = function(path) return path == "go.mod" end,
        glob = function() return "" end
      })
      assert.is_true(detector.should_load())
    end)

    it("returns true if Taskfile is present", function()
      detector._with({
        filereadable = function(path) return path == "Taskfile.yml" end,
      })
      assert.is_true(detector.should_load())
    end)

    it("returns false if neither Go project nor Taskfile", function()
      detector._with({
        filereadable = function() return false end,
        glob = function() return "" end
      })
      assert.is_false(detector.should_load())
    end)

    it("notifies when debug is on and match is found", function()
      detector._with({
        config = { debug = true },
        env = {},
        nvim_list_uis = function() return { {} } end,
        filereadable = function(path) return path == "go.mod" end,
        glob = function() return "" end,
        notify = function(msg, level, opts)
          notified = { msg = msg, level = level, opts = opts }
        end,
      })
      local result = detector.should_load()
      assert.is_true(result)
      assert.is_not_nil(notified)
      assert.matches("Detected project", notified.msg)
      assert.equals("go-task.nvim", notified.opts.title)
    end)

    it("does not notify in headless mode", function()
      detector._with({
        config = { debug = true },
        env = {},
        nvim_list_uis = function() return {} end,
        filereadable = function(path) return path == "go.mod" end,
        glob = function() return "" end,
        notify = function(msg, level, opts)
          notified = { msg = msg, level = level, opts = opts }
        end,
      })
      local result = detector.should_load()
      assert.is_true(result)
      assert.is_nil(notified) -- no notify in headless mode
    end)
  end)
end)
