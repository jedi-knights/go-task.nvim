local parser = require("go_task.parser")

describe("go_task.parser", function()
  describe("extract_task_parts", function()
    it("parses task with description", function()
      local name, desc = parser.extract_task_parts("* build: Build the binary")
      assert.equals("build", name)
      assert.equals("Build the binary", desc)
    end)

    it("parses task with no description", function()
      local name, desc = parser.extract_task_parts("* test:")
      assert.equals("test", name)
      assert.equals("", desc)
    end)

    it("returns nil for non-task line", function()
      local name, desc = parser.extract_task_parts("invalid line")
      assert.is_nil(name)
      assert.is_nil(desc)
    end)
  end)

  describe("parse_task_list", function()
    it("returns parsed table of tasks", function()
      local lines = {
        "* build: Build the binary",
        "* test: Run unit tests",
        "* lint:",
        "garbage line",
      }

      local result = parser.parse_task_list(lines)
      assert.are.same({
        { name = "build", desc = "Build the binary" },
        { name = "test", desc = "Run unit tests" },
        { name = "lint", desc = "" },
      }, result)
    end)

    it("returns empty list when no valid lines", function()
      local result = parser.parse_task_list({
        "not a task line",
        "another bad line"
      })
      assert.are.same({}, result)
    end)
  end)
end)
