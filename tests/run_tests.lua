-- Add lua/ to package.path so tests can find go_task modules
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Simple test runner for go-task.nvim
local M = {}

print("Initializing test runner...")

-- Mock vim if not available
if not _G.vim then
  _G.vim = {}
  print("Created mock vim")
end

-- Mock vim.log.levels if not available
if not vim.log then
  vim.log = {}
end
if not vim.log.levels then
  vim.log.levels = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4
  }
  print("Created mock vim.log.levels")
end

-- Mock vim.fn if not available
if not vim.fn then
  vim.fn = {}
end

-- Mock vim.fn.filereadable
if not vim.fn.filereadable then
  vim.fn.filereadable = function(name)
    -- Return 1 for common files, 0 for others
    if name == "go.mod" or name == "Taskfile.yml" or name == "Taskfile.yaml" then
      return 1
    end
    return 0
  end
end

-- Mock vim.fn.glob
if not vim.fn.glob then
  vim.fn.glob = function(pattern)
    if pattern == "*.go" then
      return "main.go test.go"
    end
    return ""
  end
end

-- Mock vim.fn.executable
if not vim.fn.executable then
  vim.fn.executable = function(cmd)
    if cmd == "task" then
      return 1
    end
    return 0
  end
end

-- Mock vim.fn.getcwd
if not vim.fn.getcwd then
  vim.fn.getcwd = function()
    return "/test/project"
  end
end

-- Mock vim.api if not available
if not vim.api then
  vim.api = {}
end

-- Mock vim.tbl_deep_extend
vim.tbl_deep_extend = vim.tbl_deep_extend or function(behavior, ...)
  local result = {}
  local args = {...}
  
  for _, tbl in ipairs(args) do
    if type(tbl) == "table" then
      for k, v in pairs(tbl) do
        if type(v) == "table" and type(result[k]) == "table" then
          result[k] = vim.tbl_deep_extend(behavior, result[k], v)
        else
          result[k] = v
        end
      end
    end
  end
  
  return result
end

-- Mock vim.wait if not available
if not vim.wait then
  vim.wait = function(ms)
    -- Simple sleep implementation
    local start = os.clock()
    while os.clock() - start < ms / 1000 do
      -- Busy wait
    end
  end
end

-- Mock vim.notify if not available
if not vim.notify then
  vim.notify = function(msg, level, opts)
    print(string.format("[%s] %s", level or "INFO", msg))
  end
end

-- Mock plenary.job if not available
if not package.loaded.plenary then
  package.loaded.plenary = {}
end
if not package.loaded.plenary.job then
  package.loaded.plenary.job = {
    new = function(opts)
      return {
        start = function()
          if opts.on_exit then
            opts.on_exit(nil, 0)
          end
        end
      }
    end
  }
  print("Created mock plenary.job")
end

-- Test results
local test_results = {
  passed = 0,
  failed = 0,
  total = 0
}

-- Simple expect function
local function expect(actual)
  return {
    toBe = function(expected)
      test_results.total = test_results.total + 1
      if actual == expected then
        test_results.passed = test_results.passed + 1
        print(string.format("✓ PASS: expected %s to be %s", tostring(actual), tostring(expected)))
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: expected %s to be %s, got %s", tostring(expected), tostring(expected), tostring(actual)))
      end
    end,
    toEqual = function(expected)
      test_results.total = test_results.total + 1
      if type(actual) == "table" and type(expected) == "table" then
        local equal = true
        for k, v in pairs(expected) do
          if actual[k] ~= v then
            equal = false
            break
          end
        end
        if equal then
          test_results.passed = test_results.passed + 1
          print(string.format("✓ PASS: tables are equal"))
        else
          test_results.failed = test_results.failed + 1
          print(string.format("✗ FAIL: tables are not equal"))
        end
      else
        if actual == expected then
          test_results.passed = test_results.passed + 1
          print(string.format("✓ PASS: expected %s to equal %s", tostring(actual), tostring(expected)))
        else
          test_results.failed = test_results.failed + 1
          print(string.format("✗ FAIL: expected %s to equal %s, got %s", tostring(expected), tostring(expected), tostring(actual)))
        end
      end
    end,
    toBeNil = function()
      test_results.total = test_results.total + 1
      if actual == nil then
        test_results.passed = test_results.passed + 1
        print("✓ PASS: value is nil")
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: expected nil, got %s", tostring(actual)))
      end
    end,
    toBeTruthy = function()
      test_results.total = test_results.total + 1
      if actual then
        test_results.passed = test_results.passed + 1
        print("✓ PASS: value is truthy")
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: expected truthy value, got %s", tostring(actual)))
      end
    end,
    toBeGreaterThan = function(expected)
      test_results.total = test_results.total + 1
      if actual > expected then
        test_results.passed = test_results.passed + 1
        print(string.format("✓ PASS: %s is greater than %s", tostring(actual), tostring(expected)))
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: expected %s to be greater than %s", tostring(actual), tostring(expected)))
      end
    end,
    toBeGreaterThanOrEqual = function(expected)
      test_results.total = test_results.total + 1
      if actual >= expected then
        test_results.passed = test_results.passed + 1
        print(string.format("✓ PASS: %s is greater than or equal to %s", tostring(actual), tostring(expected)))
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: expected %s to be greater than or equal to %s", tostring(actual), tostring(expected)))
      end
    end,
    toContain = function(expected)
      test_results.total = test_results.total + 1
      if type(actual) == "table" then
        local found = false
        for _, v in ipairs(actual) do
          if v == expected then
            found = true
            break
          end
        end
        if found then
          test_results.passed = test_results.passed + 1
          print(string.format("✓ PASS: table contains %s", tostring(expected)))
        else
          test_results.failed = test_results.failed + 1
          print(string.format("✗ FAIL: table does not contain %s", tostring(expected)))
        end
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: expected table, got %s", type(actual)))
      end
    end,
    toHaveProperty = function(property)
      test_results.total = test_results.total + 1
      if type(actual) == "table" and actual[property] ~= nil then
        test_results.passed = test_results.passed + 1
        print(string.format("✓ PASS: object has property %s", property))
      else
        test_results.failed = test_results.failed + 1
        print(string.format("✗ FAIL: object does not have property %s", property))
      end
    end
  }
end

-- Simple describe and it functions
local function describe(name, fn)
  print(string.format("\n=== %s ===", name))
  fn()
end

local function it(name, fn)
  print(string.format("\n  %s", name))
  fn()
end

-- Mock beforeEach and afterEach
local function beforeEach(fn)
  fn()
end

local function afterEach(fn)
  fn()
end

-- Make functions globally available
_G.expect = expect
_G.describe = describe
_G.it = it
_G.beforeEach = beforeEach
_G.afterEach = afterEach

print("Test runner initialized, functions available")

-- Run all tests
function M.run_all()
  print("Running go-task.nvim tests...")
  
  -- Run each test file
  local test_files = {
    "tests/config_spec.lua",
    "tests/detector_spec.lua", 
    "tests/logger_spec.lua",
    "tests/ui_spec.lua",
    "tests/init_spec.lua",
    "tests/runner_spec.lua",
    "tests/commands_spec.lua",
    "tests/constants_spec.lua",
    "tests/types_spec.lua",
    "tests/integration_spec.lua"
  }
  
  for _, file in ipairs(test_files) do
    print(string.format("Running %s...", file))
    local success, err = pcall(dofile, file)
    if not success then
      print(string.format("Error running %s: %s", file, err))
    end
  end
  
  -- Print summary
  print(string.format("\n=== Test Summary ==="))
  print(string.format("Total: %d", test_results.total))
  print(string.format("Passed: %d", test_results.passed))
  print(string.format("Failed: %d", test_results.failed))
  
  if test_results.failed == 0 then
    print("🎉 All tests passed!")
    return 0
  else
    print("❌ Some tests failed!")
    return 1
  end
end

-- Run tests if this file is executed directly
if arg and arg[0] and arg[0]:match("run_tests.lua$") then
  print("Executing tests directly...")
  M.run_all()
end

return M 