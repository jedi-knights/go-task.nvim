local runner = require("go_task.runner")

describe("go_task.runner", function()
  before_each(function()
    runner._with({
      config = {
        debug = false,
        task_bin = "task",
        log_level = vim.log.levels.INFO,
      },
      env = {},
      cwd = function() return "/mock/path" end,
      notify = function(msg, level, opts)
        vim._last_notify = { msg = msg, level = level, opts = opts }
      end,
      term = {
        open = function(opts)
          vim._last_term = opts
          return {
            send = function() vim._task_sent = true end,
            append = function(_, line) table.insert(vim._term_output, line) end,
            finish = function(_, code)
              vim._last_code = code
            end
          }
        end,
      },
      shell = {
        run = function(cmd, args, cwd)
          vim._last_cmd = cmd
          vim._last_args = args
          vim._last_cwd = cwd
          return true, nil
        end
      }
    })

    vim._last_term = nil
    vim._last_cmd = nil
    vim._last_args = nil
    vim._last_notify = nil
    vim._last_code = nil
    vim._term_output = {}
    vim._task_sent = false
  end)

  it("returns error if no task name provided", function()
    local ok, err = runner.run("")
    assert.is_false(ok)
    assert.matches("required", err)
  end)

  it("runs task and opens terminal", function()
    local ok, msg = runner.run("build")
    assert.is_true(ok)
    assert.matches("build", msg)
    assert.is_not_nil(vim._last_term)
    assert.is_true(vim._task_sent)
    assert.are.same({ "task", "build" }, { vim._last_cmd, vim._last_args[1] })
    assert.equals("/mock/path", vim._last_cwd)
  end)

  it("shows error message on shell failure", function()
    runner._with({
      shell = {
        run = function(_, _) return false, "some error" end
      }
    })
    local ok, msg = runner.run("fail")
    assert.is_false(ok)
    assert.matches("some error", msg)
  end)

  it("calls notify when debug is on and not headless", function()
    runner._with({
      config = {
        debug = true,
        log_level = vim.log.levels.INFO,
      },
      nvim_list_uis = function() return { {} } end,
    })
    runner.run("build")
    assert.is_not_nil(vim._last_notify)
    assert.matches("build", vim._last_notify.msg)
  end)
end)
