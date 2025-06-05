# go-task.nvim

A focused Neovim plugin for integrating the [`go-task`](https://taskfile.dev) task runner into your Go projects.

`go-task.nvim` makes it easy to discover, run, and manage tasks defined in your `Taskfile.yml`, all from within Neovim. With seamless Telescope integration, floating terminal output, and optional lazy-loading, this plugin is ideal for test-driven Go development workflows.

---

## ✨ Features

* 🔍 **Telescope Picker** for fuzzy-finding tasks (`:GoTaskPick`)
* 🚀 **Run tasks** via `:GoTaskRun <task>` or UI
* 🪟 **Floating window output** for interactive feedback
* 🧠 **Auto-loads** in Go projects or when a `Taskfile.yml` is present
* 🧪 **Test-driven** plugin design using [Plenary](https://github.com/nvim-lua/plenary.nvim)
* ⚙️ **Runtime logging control** with `:GoTaskDebugToggle`
* 📉 **Configurable log level** (e.g., `INFO`, `WARN`, `ERROR`)

---

## 📦 Requirements

* Neovim >= 0.8
* [`go-task`](https://taskfile.dev) installed and accessible in `$PATH`
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

---

## 🔧 Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jedi-knights/go-task.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  event = { "BufReadPre Taskfile.yml", "BufReadPre *.go" },
  config = function()
    require("go_task").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "jedi-knights/go-task.nvim",
  requires = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("go_task").setup()
  end,
})
```

---

## 🚀 Usage

### Run a task directly

```vim
:GoTaskRun test
```

### Pick a task using Telescope

```vim
:GoTaskPick
```

### Toggle debug logging

```vim
:GoTaskDebugToggle
```

---

## 🎯 Autoload Behavior

`go-task.nvim` automatically loads when:

* You open a `.go` file
* You open a `Taskfile.yml`
* You manually invoke `:GoTaskRun` or `:GoTaskPick`
* Detection is controlled by `require("go_task.detector").should_load()`

---

## 🔍 Telescope Preview

If `telescope.nvim` is installed, you get a fuzzy-searchable interface for all your tasks with descriptions parsed from `task --list`.

---

## 🛠 Configuration

Use `setup()` to override defaults:

```lua
require("go_task").setup({
  task_bin = "task",            -- binary to run (can be "task", "go-task", etc.)
  taskfile = "Taskfile.yml",    -- location of your Taskfile
  debug = false,                -- enable debug notifications
  log_level = vim.log.levels.INFO, -- log verbosity (INFO, WARN, ERROR)
})
```

### Log Level Options

| Level Constant         | Meaning                |
| ---------------------- | ---------------------- |
| `vim.log.levels.ERROR` | Critical issues        |
| `vim.log.levels.WARN`  | Warnings               |
| `vim.log.levels.INFO`  | General info (default) |
| `vim.log.levels.DEBUG` | Verbose debug info     |
| `vim.log.levels.TRACE` | Very fine-grained logs |

---

## 🧪 Running Tests

```bash
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init}"
```

Tests are written using [`plenary.busted`](https://github.com/nvim-lua/plenary.nvim).

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### 🔧 Setup for Development

1. Fork and clone the repo
2. Run `:PackerInstall` or `:Lazy sync` (depending on your plugin manager)
3. Make your changes in `lua/go_task/`
4. Write tests in `tests/`
5. Run them with `nvim --headless ...` as above

### ✅ Guidelines

* Write clear, modular Lua
* Document public methods
* Use `vim.notify()` or floating windows for user feedback
* Test using Plenary (every PR should include tests)
* Avoid noisy logs in CI/headless mode (handled by default)

---

## 📘 Example `Taskfile.yml`

```yaml
version: '3'

tasks:
  test:
    cmds:
      - go test ./...
    desc: Run Go tests

  build:
    cmds:
      - go build -o bin/myapp
    desc: Build the binary
```

---

## 💡 Roadmap

* [x] Run tasks by name
* [x] Telescope picker integration
* [x] Floating terminal output
* [x] Runtime debug toggle
* [x] Log level configuration
* [ ] Inline preview of task commands
* [ ] Autocompletion for `:GoTaskRun`

---

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.

---

## 🙏 Acknowledgments

* [go-task](https://taskfile.dev)
* [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* [Plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
* [Plenary Tests](https://github.com/nvim-lua/plenary.nvim/blob/master/TESTS_README.md)
* [Neovim Plugin From Scratch: Testing + CI (Part 5)](https://www.youtube.com/watch?v=zwEZJIXYnwI)
