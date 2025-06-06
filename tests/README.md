# 🔪 go-task.nvim Test Suite

This directory contains unit and integration tests for the [`go-task.nvim`](https://github.com/jedi-knights/go-task.nvim) plugin, written using the [Plenary](https://github.com/nvim-lua/plenary.nvim) test harness.

## 🛡️ Directory Structure

```
tests/
├── minimal_init.lua         # Minimal Neovim setup for running headless tests
├── go-task/
│   ├── file_spec.lua        # Tests for file utility functions
│   ├── runner_spec.lua      # Tests for task runner logic
│   └── ...
```

## 📼 Prerequisites

* Neovim 0.8+ (with Lua support)
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (installed via Lazy.nvim or other)
* [`just`](https://github.com/casey/just) task runner (optional but recommended, see below)

---

## ✅ Running Tests

### Run All Tests

```sh
nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
```

### Run a Specific Test File

```sh
nvim --headless -c "PlenaryBustedFile tests/go-task/file_spec.lua { minimal_init = 'tests/minimal_init.lua' }"
```

---

## ⚙️ Optional: Use a `justfile` for Simpler Dev Workflow

We use [`just`](https://github.com/casey/just), a modern command runner (like `Make` but better) to automate and simplify common plugin tasks.

### 🔧 Installation

**macOS (Homebrew):**

```sh
brew install just
```

**Debian/Ubuntu:**

```sh
sudo apt install just
```

**Arch Linux:**

```sh
sudo pacman -S just
```

Or use a prebuilt binary from [GitHub Releases](https://github.com/casey/just/releases).

---

### 🚀 Usage

From the root of the repo:

```sh
just test
just test-file tests/go-task/runner_spec.lua
just debug-on
just debug-off
```

### 🔍 Sample `justfile` (at project root)

```make
# Run all tests
test:
  nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"

# Run a specific test file
test-file path:
  nvim --headless -c "PlenaryBustedFile {{path}} { minimal_init = 'tests/minimal_init.lua' }"

# Toggle debug logging in config
debug-on:
  sed -i '' 's/debug = false/debug = true/' lua/go_task/config.lua

debug-off:
  sed -i '' 's/debug = true/debug = false/' lua/go_task/config.lua
```

> 🔀 On Linux, change `sed -i ''` to `sed -i` in `debug-on`/`debug-off`.

---

### ✅ Benefits of Using `just`

* 🧠 Memorize less: `just test` is easier than remembering full Neovim test commands
* 🚀 Speed: Faster than clicking through files or copy-pasting commands
* 🤝 Team-friendly: Encourages consistent workflows across contributors
* 💡 Extensible: Add build, lint, release, docs tasks as needed

---

Happy hacking! 🔪🚀
