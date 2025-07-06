-- Test utilities for go-task.nvim
local M = {}

---Create mock vim API for testing
---@return table mock_vim
function M.create_mock_vim()
  local mock_vim = {
    api = {
      nvim_list_uis = function() return { {} } end, -- Non-headless by default
      nvim_create_buf = function() return 1 end,
      nvim_open_win = function() end,
      nvim_buf_set_lines = function() end,
    },
    fn = {
      executable = function(cmd) return cmd == "task" and 1 or 0 end,
      getcwd = function() return "/test/project" end,
      filereadable = function(name) 
        if name == "go.mod" or name:match("%.go$") or name:match("Taskfile%.ya?ml$") then
          return 1
        end
        return 0
      end,
      glob = function(pattern)
        if pattern == "*.go" then
          return "main.go"
        end
        return ""
      end,
    },
    o = {
      columns = 80,
      lines = 24,
    },
    env = {
      CI = nil,
    },
    log = {
      levels = {
        ERROR = 1,
        WARN = 2,
        INFO = 3,
        DEBUG = 4,
      },
    },
    notify = function(msg, level, opts) 
      -- Capture notifications for testing
      if not _G.test_notifications then
        _G.test_notifications = {}
      end
      table.insert(_G.test_notifications, { msg = msg, level = level, opts = opts })
    end,
    schedule = function(fn) fn() end, -- Execute immediately for testing
    tbl_map = function(fn, tbl)
      local result = {}
      for i, v in ipairs(tbl) do
        result[i] = fn(v)
      end
      return result
    end,
    tbl_extend = function(behavior, ...)
      local result = {}
      local args = {...}
      for _, tbl in ipairs(args) do
        if type(tbl) == "table" then
          for k, v in pairs(tbl) do
            result[k] = v
          end
        end
      end
      return result
    end,
    tbl_deep_extend = function(behavior, ...)
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
    end,
  }
  
  return mock_vim
end

---Create mock Job for testing
---@return table mock_job
function M.create_mock_job()
  local mock_job = {
    new = function(opts)
      local job = {
        opts = opts or {},
        started = false,
        stdout = {},
        stderr = {},
        exit_code = 0,
        result_called = false,
      }
      
      function job:start()
        self.started = true
        -- Simulate immediate completion for testing
        if self.opts.on_exit then
          self.opts.on_exit(nil, self.exit_code)
        end
        return self
      end
      
      function job:stop()
        self.started = false
        return self
      end
      
      function job:is_shutdown()
        return not self.started
      end
      
      function job:wait()
        return self.exit_code
      end
      
      function job:result()
        if not self.result_called then
          self.result_called = true
          -- Return mock task list
          return {
            "* build: Build the project",
            "* test: Run tests",
            "* clean: Clean build artifacts",
          }
        end
        return self.stdout
      end
      
      return job
    end
  }
  
  return mock_job
end

---Create mock Snacks for testing
---@return table mock_snacks
function M.create_mock_snacks()
  local mock_snacks = {
    picker = function(opts)
      local picker_instance = {
        opts = opts or {},
        shown = false,
        selected_items = {},
      }
      
      function picker_instance:show()
        self.shown = true
        -- Simulate selection if callback provided
        if self.opts.actions and self.opts.actions.item_action and #self.opts.items > 0 then
          self.opts.actions.item_action(self, self.opts.items[1])
        end
        return self
      end
      
      function picker_instance:close()
        self.shown = false
        return self
      end
      
      return picker_instance
    end
  }
  
  return mock_snacks
end

---Create test dependencies object
---@return table deps
function M.create_test_deps()
  local mock_vim = M.create_mock_vim()
  local mock_job = M.create_mock_job()
  local mock_snacks = M.create_mock_snacks()
  
  return {
    -- Vim API mocks
    vim_api = mock_vim.api,
    vim_fn = mock_vim.fn,
    vim_o = mock_vim.o,
    vim_env = mock_vim.env,
    notify = mock_vim.notify,
    schedule = mock_vim.schedule,
    vim_tbl_map = mock_vim.tbl_map,
    vim_tbl_extend = mock_vim.tbl_extend,
    tbl_extend = mock_vim.tbl_deep_extend,
    
    -- External module mocks
    Job = mock_job,
    Snacks = mock_snacks,
    
    -- Module mocks (can be overridden)
    config = nil, -- Will use real config by default
    runner = nil, -- Will use real runner by default
    ui = nil, -- Will use real ui by default
    commands = nil, -- Will use real commands by default
    detector = nil, -- Will use real detector by default
    parser = nil, -- Will use real parser by default
  }
end

---Clear test notifications
function M.clear_notifications()
  _G.test_notifications = {}
end

---Get test notifications
---@return table notifications
function M.get_notifications()
  return _G.test_notifications or {}
end

---Assert that a notification was sent
---@param expected_msg string Expected message
---@param expected_level? number Expected level
function M.assert_notification(expected_msg, expected_level)
  local notifications = M.get_notifications()
  for _, notification in ipairs(notifications) do
    if notification.msg == expected_msg then
      if expected_level and notification.level == expected_level then
        return true
      elseif not expected_level then
        return true
      end
    end
  end
  error(string.format("Expected notification not found: %s", expected_msg))
end

return M 