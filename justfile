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
