local shell = require("go_task.shell")
local Job = require("plenary.job")

describe("go_task.shell", function()
  local original_new

  before_each(function()
    original_new = Job.new
    vim._called_job = nil
    vim._job_result = nil
  end)

  after_each(function()
    Job.new = original_new
  end)

  it("spawns Job with correct args", function()
    Job.new = function(opts)
      vim._called_job = opts
      return {
        start = function() end
      }
    end

    shell.run("echo", { "hello" }, "/tmp")
    assert.is_not_nil(vim._called_job)
    assert.equals("echo", vim._called_job.command)
    assert.are.same({ "hello" }, vim._called_job.args)
    assert.equals("/tmp", vim._called_job.cwd)
  end)

  it("runs task and returns success", function()
    Job.new = function(opts)
      return {
        start = function()
          vim.schedule(function()
            if opts.on_stdout then opts.on_stdout(nil, "output") end
            if opts.on_exit then opts.on_exit(nil, 0) end
          end)
        end
      }
    end

    local ok, err = shell.run("echo", { "foo" }, "/somewhere")
    assert.is_true(ok)
    assert.is_nil(err)
  end)

  it("returns error if job fails", function()
    Job.new = function(opts)
      return {
        start = function()
          vim.schedule(function()
            if opts.on_stderr then opts.on_stderr(nil, "error") end
            if opts.on_exit then opts.on_exit(nil, 1) end
          end)
        end
      }
    end

    local ok, err = shell.run("fail", {}, "/somewhere")
    assert.is_false(ok)
    assert.matches("fail", err)
  end)

  it("handles nil args or cwd safely", function()
    Job.new = function(opts)
      return {
        start = function()
          if opts.on_exit then opts.on_exit(nil, 0) end
        end
      }
    end

    local ok, err = shell.run("noop")
    assert.is_true(ok)
    assert.is_nil(err)
  end)
end)
