-- Mock snacks module for testing
local M = {}

-- Mock picker function
function M.picker(opts)
  local picker_instance = {
    opts = opts or {},
    shown = false,
    selected_items = {}
  }
  
  -- Mock show method
  function picker_instance:show()
    self.shown = true
    -- Simulate selection if callback provided
    if self.opts.on_select and #self.opts.items > 0 then
      self.opts.on_select(self.opts.items[1])
    end
    return self
  end
  
  -- Mock close method
  function picker_instance:close()
    self.shown = false
    return self
  end
  
  return picker_instance
end

-- Mock test module
M.test = {
  describe = function(name, fn)
    print("=== " .. name .. " ===")
    fn()
  end,
  
  it = function(name, fn)
    print("  " .. name)
    local success, err = pcall(fn)
    if success then
      print("✓ PASS: " .. name)
    else
      print("✗ FAIL: " .. name .. " - " .. tostring(err))
    end
  end,
  
  beforeEach = function(fn)
    fn()
  end,
  
  afterEach = function(fn)
    fn()
  end
}

-- Mock expect function
M.expect = function(actual)
  return {
    toBe = function(expected)
      if actual ~= expected then
        error(string.format("expected %s to be %s", tostring(actual), tostring(expected)))
      end
    end,
    
    toEqual = function(expected)
      if actual ~= expected then
        error(string.format("expected %s to equal %s", tostring(actual), tostring(expected)))
      end
    end,
    
    toBeTruthy = function()
      if not actual then
        error(string.format("expected %s to be truthy", tostring(actual)))
      end
    end,
    
    toBeNil = function()
      if actual ~= nil then
        error(string.format("expected %s to be nil", tostring(actual)))
      end
    end,
    
    toBeGreaterThan = function(expected)
      if actual <= expected then
        error(string.format("expected %s to be greater than %s", tostring(actual), tostring(expected)))
      end
    end
  }
end

return M 