local file_utils = require("go_task.utils.file")
local mock_vim_fn = require("tests.helpers.mock_vim_fn")

describe("file.lua (mocked)", function()
  local restore_fn

  after_each(function()
    if restore_fn then restore_fn() end
  end)

  describe("file_exists", function()
    it("returns true when filereadable is 1", function()
      restore_fn = mock_vim_fn({
        filereadable = function(name)
          assert.equals(name, "go.mod")
          return 1
        end,
      })

      assert.is_true(file_utils.file_exists("go.mod"))
    end)

    it("returns false when filereadable is 0", function()
      restore_fn = mock_vim_fn({
        filereadable = function(name)
          assert.equals(name, "missing.txt")
          return 0
        end,
      })

      assert.is_false(file_utils.file_exists("missing.txt"))
    end)
  end)

  describe("glob_exists", function()
    it("returns true if glob returns non-empty string", function()
      restore_fn = mock_vim_fn({
        glob = function(pattern)
          assert.equals("*.go", pattern)
          return "main.go"
        end,
      })

      assert.is_true(file_utils.glob_exists("*.go"))
    end)

    it("returns false if glob returns empty string", function()
      restore_fn = mock_vim_fn({
        glob = function(pattern)
          assert.equals("*.notfound", pattern)
          return ""
        end,
      })

      assert.is_false(file_utils.glob_exists("*.notfound"))
    end)
  end)
end)
