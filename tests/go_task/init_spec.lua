local init = require("go_task")
local config = require("go_task.config")
local commands = require("go_task.commands")

describe("go_task.init", function()
  local original_override
  local original_setup

  before_each(function()
    -- Stub config.override
    original_override = config.override
    config.override = function(opts)
      vim._config_override = opts
    end

    -- Stub commands.setup
    original_setup = commands.setup
    commands.setup = function()
      vim._commands_setup_called = true
    end

    vim._config_override = nil
    vim._commands_setup_called = false
  end)

  after_each(function()
    -- Restore original functions
    config.override = original_override
    commands.setup = original_setup
  end)

  it("calls config.override with given options", function()
    local opts = { debug = true, task_bin = "custom-task" }
    init.setup(opts)
    assert.are.same(opts, vim._config_override)
  end)

  it("calls commands.setup during setup()", function()
    init.setup({})
    assert.is_true(vim._commands_setup_called)
  end)
end)
