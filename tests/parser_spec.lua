local parser = require("go_task.parser")

describe("task list parser", function()
  it("extracts task names", function()
    local lines = {
      "task: Available tasks for this project:",
      "* build:     Build the project",
      "* test:      Run tests",
    }
    local tasks = parser.parse_task_list(lines)
    assert.are.same({ "build", "test" }, tasks)
  end)
end)

