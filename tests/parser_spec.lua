require("tests/test_helper")
local parser = require("go_task.parser")

describe("parser", function()
  it("extracts task names and descriptions", function()
    local lines = {
      "* build: Build the binary",
      "* test:  Run tests",
    }
    local tasks = parser.parse_task_list(lines)
    expect(tasks[1].name):toBe("build")
    expect(tasks[1].desc):toBe("Build the binary")
    expect(tasks[2].name):toBe("test")
    expect(tasks[2].desc):toBe("Run tests")
  end)

  it("handles empty input", function()
    local tasks = parser.parse_task_list({})
    expect(tasks):toEqual({})
  end)

  it("handles nil input", function()
    local tasks = parser.parse_task_list(nil)
    expect(tasks):toEqual({})
  end)

  it("handles invalid line types", function()
    local lines = {
      "* build: Build the binary",
      123, -- invalid type
      "* test: Run tests",
    }
    local tasks = parser.parse_task_list(lines)
    expect(tasks[1].name):toBe("build")
    expect(tasks[2].name):toBe("test")
  end)

  it("parses single task line", function()
    local task = parser.parse_task_line("* build: Build the binary")
    expect(task.name):toBe("build")
    expect(task.desc):toBe("Build the binary")
  end)

  it("handles invalid single line", function()
    local task = parser.parse_task_line("invalid line")
    expect(task).toBeNil()
  end)

  it("handles nil single line", function()
    local task = parser.parse_task_line(nil)
    expect(task).toBeNil()
  end)
end)
