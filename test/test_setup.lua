#!/usr/bin/env lua

-- Test script for MyST basic functionality
-- This tests that the plugin loads and works correctly without configuration

print("Testing MyST basic functionality...")

-- Set up Lua path to find the module
local current_dir = debug.getinfo(1, "S").source:match("@(.*/)")  or "./"
package.path = current_dir .. "../?.lua;" .. current_dir .. "../?/init.lua;" .. package.path

-- Mock vim API for testing
local mock_vim = {
  api = {
    nvim_create_autocmd = function(events, opts) return true end,
    nvim_create_user_command = function(name, fn, opts) return true end,
    nvim_set_hl = function(ns, name, opts) return true end,
    nvim_buf_get_lines = function(buf, start, end_line, strict)
      return {"# Test file", "```{code-cell}", "print('test')", "```"}
    end,
    nvim_get_current_buf = function() return 1 end,
    nvim_list_runtime_paths = function() return {} end
  },
  bo = { filetype = "markdown" },
  wo = {},
  cmd = function(cmd_str) end,
  treesitter = {
    start = function(buf, lang) return true end,
    query = { get = function(lang, query_type) return {} end }
  },
  fn = {
    stdpath = function(what) return "/tmp" end,
    isdirectory = function(path) return 0 end,
    filewritable = function(path) return 0 end
  }
}

-- Set up the mock vim global
_G.vim = mock_vim

-- Test 1: Load the module
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loaded successfully")

-- Test 2: Basic setup
local setup_success = pcall(function()
  myst_module.setup()
end)

if setup_success then
  print("✓ Setup completed successfully")
else
  print("✗ Setup failed")
  return 1
end

-- Test 3: Setup with empty options (should not fail)
local empty_setup_success = pcall(function()
  myst_module.setup({})
end)

if empty_setup_success then
  print("✓ Setup with empty options completed successfully")
else
  print("✗ Setup with empty options failed")
  return 1
end

-- Test 4: Test debug function works
local debug_success = pcall(function()
  myst_module.debug_myst()
end)

if debug_success then
  print("✓ Debug function works")
else
  print("✗ Debug function failed")
  return 1
end

print("\n✓ All basic functionality tests passed!")
print("MyST plugin works correctly:")
print("  • Module loads successfully")
print("  • Setup runs without errors")  
print("  • Debug function shows current state")
print("  • No configuration required")

return 0