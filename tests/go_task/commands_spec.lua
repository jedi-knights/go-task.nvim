local commands = require("go_task.commands")
local core = require("go_task.core") -- Assuming core.run_and_notify is used internally
local stub = require("luassert.stub") -- For stubbing functions
local mock = require("luassert.mock") -- For creating mocks

describe("go_task.commands", function()
  before_each(function()
    -- Reset any state before each test
    package.loaded["go_task.core"] = nil
  end)

  it("should call core.run_and_notify with the correct task name", function()
    -- Stub the run_and_notify function
    local run_and_notify_stub = stub(core, "run_and_notify")

    -- Call the function under test
    commands.run_task("build")

    -- Assert that run_and_notify was called with "build"
    assert.stub(run_and_notify_stub).was_called_with("build")

    -- Revert the stub
    run_and_notify_stub:revert()
  end)

  it("should register the GoTaskRun command", function()
    -- Setup the command
    commands.setup()

    -- Check if the command is registered
    local exists = vim.fn.exists(":GoTaskRun") == 2
    assert.is_true(exists)
  end)
end)
