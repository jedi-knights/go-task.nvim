-- Test runner for example tests
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Mock vim globally for testing
vim = require("tests.test_utils").create_mock_vim()

-- Mock plenary.job
package.loaded["plenary.job"] = require("tests.test_utils").create_mock_job()

-- Mock snacks
package.loaded["snacks"] = require("tests.test_utils").create_mock_snacks()

-- Run the example tests
local example_tests = require("tests.example_test")
example_tests.run_example_tests() 