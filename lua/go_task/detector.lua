-- lua/go_task/detector.lua

local M = {}

-- Default dependencies
M._deps = {
  filereadable = function(name)
    return vim.fn.filereadable(name) == 1
  end,
  glob = function(pattern)
    return vim.fn.glob(pattern)
  end,
  notify = function(msg, level, opts)
    vim.notify(msg, level, opts)
  end,
  nvim_list_uis = vim.api.nvim_list_uis,
  env = vim.env,
  config = {
    debug = false
  }
}

-- Allow dependency injection
function M._with(deps)
  M._deps = vim.tbl_extend("force", M._deps, deps)
end

-- Check if file exists
local function file_exists(name)
  return M._deps.filereadable(name)
end

-- Check for go.mod or *.go files
function M.is_go_project()
  return file_exists("go.mod") or M._deps.glob("*.go") ~= ""
end

-- Check for Taskfile.{yml,yaml}
function M.has_taskfile()
  return file_exists("Taskfile.yml") or file_exists("Taskfile.yaml")
end

-- Check if in headless mode
local function in_headless()
  return #M._deps.nvim_list_uis() == 0
end

-- Compose a human-readable project description for debug notify
local function get_project_type_description(is_go, has_task)
  if is_go and has_task then
    return "Go + Taskfile"
  elseif is_go then
    return "Go"
  elseif has_task then
    return "Taskfile"
  end
  return ""
end

-- Emit debug info if allowed
local function maybe_notify(project_desc)
  local cfg = M._deps.config
  if cfg.debug and not in_headless() and not M._deps.env.CI then
    M._deps.notify(
      "go-task.nvim: Detected project (" .. project_desc .. ")",
      vim.log.levels.INFO,
      { title = "go-task.nvim" }
    )
  end
end

-- Final decision: should plugin load
function M.should_load()
  local is_go = M.is_go_project()
  local has_task = M.has_taskfile()
  local should = is_go or has_task

  if should then
    maybe_notify(get_project_type_description(is_go, has_task))
  end

  return should
end

return M
