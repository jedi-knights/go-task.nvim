local config = require("go_task.config")

describe("go_task.config", function()
  local original_notify

  before_each(function()
    -- Save and stub vim.notify to avoid actual notifications
    original_notify = vim.notify
    vim.notify = function(msg, level, opts)
      vim._last_notify = { msg = msg, level = level, opts = opts }
    end

    -- Reset config state between tests
    config.debug = false
    vim._last_notify = nil
  end)

  after_each(function()
    vim.notify = original_notify
  end)

  it("has the correct default values", function()
    assert.equals("task", config.task_bin)
    assert.equals("Taskfile.yml", config.taskfile)
    assert.is_false(config.debug)
    assert.equals(vim.log.levels.INFO, config.log_level)
  end)

  it("toggles debug from false to true", function()
    config.debug = false
    config.toggle_debug()
    assert.is_true(config.debug)
    assert.matches("Debug mode: true", vim._last_notify.msg)
  end)

  it("toggles debug from true to false", function()
    config.debug = true
    config.toggle_debug()
    assert.is_false(config.debug)
    assert.matches("Debug mode: false", vim._last_notify.msg)
  end)

  it("uses configured log level for notifications", function()
    config.log_level = vim.log.levels.WARN
    config.toggle_debug()
    assert.equals(vim.log.levels.WARN, vim._last_notify.level)
  end)

  it("includes correct title in notification", function()
    config.toggle_debug()
    assert.equals("go-task.nvim", vim._last_notify.opts.title)
  end)
end)
