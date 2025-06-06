describe("plugin/go-task.lua", function()
  local detector = require("go_task.detector")
  local init = require("go_task")
  local config = require("go_task.config")
  local ui = require("go_task.ui")
  local commands = require("go_task.commands")

  local original_detector
  local original_setup
  local original_ui
  local original_run_task
  local original_notify

  before_each(function()
    -- Stub everything that gets invoked
    original_detector = detector.should_load
    original_setup = init.setup
    original_ui = ui.task_picker
    original_run_task = commands.run_task
    original_notify = config.toggle_debug

    detector.should_load = function() vim._should_load_called = true return true end
    init.setup = function() vim._setup_called = true end
    ui.task_picker = function() vim._task_picker_called = true end
    commands.run_task = function(arg) vim._run_task_called = arg end
    config.toggle_debug = function() vim._debug_toggle_called = true end

    vim._should_load_called = false
    vim._setup_called = false
    vim._task_picker_called = false
    vim._run_task_called = false
    vim._debug_toggle_called = false

    -- Re-source plugin file to re-register commands/autocmds
    dofile(vim.fn.stdpath("config") .. "/plugin/go-task.lua")
  end)

  after_each(function()
    detector.should_load = original_detector
    init.setup = original_setup
    ui.task_picker = original_ui
    commands.run_task = original_run_task
    config.toggle_debug = original_notify
  end)

  it("registers GoTaskRun command and calls run_task", function()
    vim.cmd("GoTaskRun test")
    assert.equals("test", vim._run_task_called)
  end)

  it("registers GoTaskPick and calls task_picker", function()
    vim.cmd("GoTaskPick")
    assert.is_true(vim._task_picker_called)
  end)

  it("registers GoTaskDebugToggle and calls toggle_debug", function()
    vim.cmd("GoTaskDebugToggle")
    assert.is_true(vim._debug_toggle_called)
  end)

  it("runs setup() if detector.should_load() returns true", function()
    -- Trigger the BufReadPre autocmd manually
    vim.api.nvim_exec_autocmds("BufReadPre", { pattern = "some_file.go" })
    assert.is_true(vim._should_load_called)
    assert.is_true(vim._setup_called)
  end)
end)
