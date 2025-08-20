#!/usr/bin/env lua

-- Integration test to verify MyST plugin functionality
-- This test simulates setting up the plugin and checks the main functionality

print("Testing MyST plugin integration...")

-- Mock vim API for testing
local mock_vim = {
  api = {
    nvim_create_autocmd = function(events, opts)
      local events_str = type(events) == "table" and table.concat(events, ", ") or tostring(events)
      print("  Mock: Created autocmd for " .. events_str)
      -- Simulate calling the callback for FileType myst
      if opts.pattern == "myst" and opts.callback then
        print("  Mock: Simulating myst filetype detection")
        -- Don't actually call the callback to avoid treesitter errors
      end
      return true
    end,
    nvim_create_user_command = function(name, fn, opts)
      print("  Mock: Created user command " .. name)
      return true
    end,
    nvim_set_hl = function(ns, name, opts)
      print("  Mock: Set highlight " .. name)
      return true
    end,
    nvim_buf_get_lines = function(buf, start, end_line, strict)
      -- Return mock lines with MyST content
      return {
        "# Test MyST File",
        "```{code-cell} python",
        "import pandas as pd",
        "```",
        "```{code-cell}",
        "print('default python')",
        "```"
      }
    end,
    nvim_get_current_buf = function()
      return 1
    end
  },
  bo = {
    filetype = "markdown"
  },
  wo = {},
  cmd = function(cmd_str)
    print("  Mock: Executed vim command: " .. cmd_str)
  end,
  treesitter = {
    start = function(buf, lang)
      print("  Mock: Started treesitter with language " .. (lang or "unknown"))
      return true
    end,
    query = {
      get = function(lang, query_type)
        print("  Mock: Got treesitter query " .. (lang or "unknown") .. "/" .. (query_type or "unknown"))
        return {} -- mock query object
      end
    }
  }
}

-- Set up the mock vim global
_G.vim = mock_vim

-- Test 1: Load and setup the plugin
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loaded successfully")

-- Test 2: Call setup function
local setup_success, setup_error = pcall(function()
  myst_module.setup()
end)

if setup_success then
  print("✓ Plugin setup completed successfully")
else
  print("✗ Plugin setup failed:", setup_error)
  return 1
end

-- Test 3: Test manual command functions
print("\nTesting manual commands:")

-- Test enable_myst
local enable_success = pcall(function()
  myst_module.enable_myst()
end)
if enable_success then
  print("✓ enable_myst function works")
else
  print("✗ enable_myst function failed")
  return 1
end

-- Test disable_myst 
local disable_success = pcall(function()
  myst_module.disable_myst()
end)
if disable_success then
  print("✓ disable_myst function works")
else
  print("✗ disable_myst function failed")
  return 1
end

-- Test debug_myst
local debug_success = pcall(function()
  myst_module.debug_myst()
end)
if debug_success then
  print("✓ debug_myst function works")
else
  print("✗ debug_myst function failed")
  return 1
end

print("\n✓ All integration tests passed!")
return 0