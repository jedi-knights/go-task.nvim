-- Mock plenary.job module for testing
local M = {}

-- Mock Job constructor
function M.new(opts)
  local job = {
    opts = opts or {},
    started = false,
    stdout = {},
    stderr = {},
    exit_code = 0
  }
  
  -- Mock start method
  function job:start()
    self.started = true
    -- Simulate immediate completion for testing
    if self.opts.on_exit then
      self.opts.on_exit(nil, self.exit_code)
    end
    return self
  end
  
  -- Mock stop method
  function job:stop()
    self.started = false
    return self
  end
  
  -- Mock is_shutdown method
  function job:is_shutdown()
    return not self.started
  end
  
  -- Mock wait method
  function job:wait()
    return self.exit_code
  end
  
  -- Mock result method
  function job:result()
    return self.stdout
  end
  
  return job
end

-- Mock sync method
function M.sync(opts)
  local job = M.new(opts)
  job:start()
  return job:result(), job.exit_code
end

return M 