-- tests/minimal_init.lua

-- Add your plugin's path to the runtime
vim.cmd("set runtimepath+=" .. vim.fn.getcwd())

-- Add plenary's path via Lazy.nvim
vim.cmd("set runtimepath+=~/.local/share/nvim/lazy/plenary.nvim")

-- Optional: disable backup files during test runs
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.backup = false
