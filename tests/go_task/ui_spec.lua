local ui = require("go_task.ui")
local shell = require("go_task.shell")
local parser = require("go_task.parser")
local runner = require("go_task.runner")
local pickers = require("telescope.pickers")

describe("go_task.ui", function()
  local original_shell_run
  local original_parser
  local original_runner
  local original_picker

  before_each(function()
    original_shell_run = shell.run
    original_parser = parser.parse_task_list
    original_runner = runner.run
    original_picker = pickers.new

    -- Default stubs
    shell.run = function() return true, {
      "* build: Compile project",
      "* test: Run tests",
    } end

    parser.parse_task_list = function(lines)
      vim._parsed_lines = lines
      return {
        { name = "build", desc = "Compile project" },
        { name = "test", desc = "Run tests" },
      }
    end

    runner.run = function(task)
      vim._runner_called = task
    end

    pickers.new = function(_, opts)
      vim._picker_opts = opts
      return {
        find = function()
          vim._picker_invoked = true
          -- Simulate selection
          if opts and opts.attach_mappings then
            opts.attach_mappings(nil, function(_, action)
              runner.run("build") -- simulate user selection
              return true
            end)
          end
        end
      }
    end

    vim._parsed_lines = nil
    vim._runner_called = nil
    vim._picker_opts = nil
    vim._picker_invoked = false
  end)

  after_each(function()
    shell.run = original_shell_run
    parser.parse_task_list = original_parser
    runner.run = original_runner
    pickers.new = original_picker
  end)

  it("calls task --list and parses output", function()
    ui.task_picker()
    assert.is_not_nil(vim._parsed_lines)
    assert.are.same({
      "* build: Compile project",
      "* test: Run tests"
    }, vim._parsed_lines)
  end)

  it("creates Telescope picker with entries", function()
    ui.task_picker()
    assert.is_true(vim._picker_invoked)
    assert.is_not_nil(vim._picker_opts.finder)
    assert.are.same("Go Task Picker", vim._picker_opts.prompt_title)
  end)

  it("runs selected task when chosen", function()
    ui.task_picker()
    assert.equals("build", vim._runner_called)
  end)
end)
