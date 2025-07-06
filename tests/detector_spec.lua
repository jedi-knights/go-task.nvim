require("tests/test_helper")
local detector = require("go_task.detector")

describe("detector", function()
  describe("is_go_project", function()
    it("should return true when go.mod exists", function()
      -- Mock vim.fn.filereadable to return 1 for go.mod
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function(name)
        if name == "go.mod" then
          return 1
        end
        return original_filereadable(name)
      end
      
      expect(detector.is_go_project()):toBe(true)
      
      -- Restore original function
      vim.fn.filereadable = original_filereadable
    end)

    it("should return true when .go files exist", function()
      -- Mock vim.fn.glob to return non-empty string for *.go
      local original_glob = vim.fn.glob
      vim.fn.glob = function(pattern)
        if pattern == "*.go" then
          return "main.go"
        end
        return original_glob(pattern)
      end
      
      expect(detector.is_go_project()):toBe(true)
      
      -- Restore original function
      vim.fn.glob = original_glob
    end)

    it("should return false when neither go.mod nor .go files exist", function()
      -- Mock both functions to return false/empty
      local original_filereadable = vim.fn.filereadable
      local original_glob = vim.fn.glob
      
      vim.fn.filereadable = function(name)
        if name == "go.mod" then
          return 0
        end
        return original_filereadable(name)
      end
      
      vim.fn.glob = function(pattern)
        if pattern == "*.go" then
          return ""
        end
        return original_glob(pattern)
      end
      
      expect(detector.is_go_project()):toBe(false)
      
      -- Restore original functions
      vim.fn.filereadable = original_filereadable
      vim.fn.glob = original_glob
    end)
  end)

  describe("has_taskfile", function()
    it("should return true when Taskfile.yml exists", function()
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function(name)
        if name == "Taskfile.yml" then
          return 1
        end
        return original_filereadable(name)
      end
      
      expect(detector.has_taskfile()):toBe(true)
      
      vim.fn.filereadable = original_filereadable
    end)

    it("should return true when Taskfile.yaml exists", function()
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function(name)
        if name == "Taskfile.yaml" then
          return 1
        end
        return original_filereadable(name)
      end
      
      expect(detector.has_taskfile()):toBe(true)
      
      vim.fn.filereadable = original_filereadable
    end)

    it("should return false when no taskfile exists", function()
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function(name)
        if name == "Taskfile.yml" or name == "Taskfile.yaml" then
          return 0
        end
        return original_filereadable(name)
      end
      
      expect(detector.has_taskfile()):toBe(false)
      
      vim.fn.filereadable = original_filereadable
    end)
  end)

  describe("should_load", function()
    it("should return true when Go project is detected", function()
      -- Mock is_go_project to return true
      local original_is_go = detector.is_go_project
      detector.is_go_project = function() return true end
      
      expect(detector.should_load()):toBe(true)
      
      detector.is_go_project = original_is_go
    end)

    it("should return true when taskfile is detected", function()
      -- Mock has_taskfile to return true
      local original_has_task = detector.has_taskfile
      detector.has_taskfile = function() return true end
      
      expect(detector.should_load()):toBe(true)
      
      detector.has_taskfile = original_has_task
    end)

    it("should return false when neither Go project nor taskfile is detected", function()
      -- Mock both to return false
      local original_is_go = detector.is_go_project
      local original_has_task = detector.has_taskfile
      
      detector.is_go_project = function() return false end
      detector.has_taskfile = function() return false end
      
      expect(detector.should_load()):toBe(false)
      
      detector.is_go_project = original_is_go
      detector.has_taskfile = original_has_task
    end)
  end)

  describe("get_project_info", function()
    it("should return project information", function()
      local info = detector.get_project_info()
      expect(info):toHaveProperty("is_go")
      expect(info):toHaveProperty("has_taskfile")
      expect(info):toHaveProperty("cwd")
      expect(type(info.is_go)):toBe("boolean")
      expect(type(info.has_taskfile)):toBe("boolean")
      expect(type(info.cwd)):toBe("string")
    end)
  end)
end) 