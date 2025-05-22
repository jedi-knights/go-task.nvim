local parser = require("go_task.parser")

describe("parser", function()
  it("extracts task names and descriptions", function()
    local lines = {
      "* build: Build the binary",
      "* test:  Run tests",
    }
    local tasks = parser.parse_task_list(lines)
    assert.are.same(tasks[1].name, "build")
    assert.are.same(tasks[2].desc, "Run tests")
  end)
end)
