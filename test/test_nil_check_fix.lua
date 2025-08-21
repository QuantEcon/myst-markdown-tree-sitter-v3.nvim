#!/usr/bin/env lua

-- Test script to validate the ts_highlight.active nil check fix
-- This test specifically validates the fix for issue #33

print("Testing MyST ts_highlight.active nil check fix...")

-- Set up Lua path to find the module
local current_dir = debug.getinfo(1, "S").source:match("@(.*/)") or "./"
package.path = current_dir .. "../lua/?.lua;" .. current_dir .. "../lua/?/init.lua;" .. package.path

-- Mock vim API with problematic scenarios
local function create_mock_vim(active_value)
  return {
    api = {
      nvim_get_current_buf = function() return 1 end,
      nvim_buf_is_valid = function() return true end,
      nvim_create_autocmd = function() end,
      nvim_create_user_command = function() end,
      nvim_buf_get_lines = function() return {} end,
      nvim_buf_get_name = function() return "test.md" end,
      nvim_set_hl = function() end,
    },
    bo = { filetype = "myst" },
    defer_fn = function(fn, delay) fn() end, -- Execute immediately for testing
    treesitter = {
      query = {
        get = function() return {} end
      }
    },
    tbl_keys = function(t) 
      local keys = {}
      for k, _ in pairs(t) do
        table.insert(keys, k)
      end
      return keys
    end,
    cmd = function() end,
  }
end

-- Mock package system for different scenarios
local function create_mock_package(active_value)
  local original_require = require
  _G.require = function(name)
    if name == "nvim-treesitter.configs" then
      return {}
    elseif name == "nvim-treesitter.highlight" then
      return {
        active = active_value, -- This is what we're testing
        detach = function() end,
        attach = function() end,
      }
    elseif name == "nvim-treesitter.parsers" then
      return {
        get_buf_lang = function() return "markdown" end,
        get_parser_configs = function() return {} end,
        filetype_to_parsername = { myst = "markdown" }
      }
    else
      return original_require(name)
    end
  end
end

-- Test 1: ts_highlight.active is nil (the original bug scenario)
print("\n=== Test 1: ts_highlight.active is nil ===")
_G.vim = create_mock_vim()
create_mock_package(nil) -- This would cause the original error

local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

local test1_success, test1_error = pcall(function()
  myst_module.refresh_highlighting()
  myst_module.debug_myst()
end)

if test1_success then
  print("✓ Functions work correctly when ts_highlight.active is nil")
else
  print("✗ Functions failed when ts_highlight.active is nil:", test1_error)
  return 1
end

-- Test 2: ts_highlight.active is empty table (should work fine)
print("\n=== Test 2: ts_highlight.active is empty table ===")
create_mock_package({}) -- Empty table

local test2_success, test2_error = pcall(function()
  myst_module.refresh_highlighting()
  myst_module.debug_myst()
end)

if test2_success then
  print("✓ Functions work correctly when ts_highlight.active is empty")
else
  print("✗ Functions failed when ts_highlight.active is empty:", test2_error)
  return 1
end

-- Test 3: ts_highlight.active has buffer entry (normal case)
print("\n=== Test 3: ts_highlight.active has buffer entry ===")
create_mock_package({[1] = {tree = {}, parser = {}}}) -- Buffer 1 has highlighter

local test3_success, test3_error = pcall(function()
  myst_module.refresh_highlighting()
  myst_module.debug_myst()
end)

if test3_success then
  print("✓ Functions work correctly when ts_highlight.active has entries")
else
  print("✗ Functions failed when ts_highlight.active has entries:", test3_error)
  return 1
end

print("\n=== All tests passed! ===")
print("✓ The nil check fix prevents the 'attempt to index field 'active' (a nil value)' error")
print("✓ All three scenarios (nil, empty, populated) work correctly")
print("✓ Issue #33 is resolved")

return 0