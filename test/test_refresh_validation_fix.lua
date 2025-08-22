#!/usr/bin/env lua

-- Test script for MyST highlighting refresh validation fix
-- This validates that the refresh function properly reports success/failure

print("=== Testing MyST Refresh Validation Fix ===")

-- Mock vim environment for testing
local mock_vim = {
  api = {
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_is_valid = function() return true end,
    nvim_buf_get_lines = function() return {"{code-cell} python", "print('hello')", "```"} end,
    nvim_buf_get_name = function() return "test.md" end,
    nvim_create_autocmd = function() return true end,
    nvim_create_user_command = function() return true end,
    nvim_set_hl = function() return true end,
  },
  bo = { filetype = "myst" },
  treesitter = {
    query = { get = function() return {} end },
    stop = function() return true end,
    start = function() return true end,
  },
  wait = function() return true end,
  defer_fn = function(fn) fn() end,
  cmd = function() return true end,
}

-- Mock tree-sitter modules with different scenarios
local function create_mock_treesitter(active_status)
  return {
    highlight = {
      active = active_status and { [1] = {} } or nil
    }
  }
end

-- Set up global vim mock
_G.vim = mock_vim

-- Test module loading
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loaded successfully")

-- Test 1: refresh_highlighting returns proper validation
print("\nTest 1: Testing refresh validation with active tree-sitter...")

-- Mock successful tree-sitter activation
_G.package.loaded["nvim-treesitter.configs"] = {}
_G.package.loaded["nvim-treesitter.highlight"] = create_mock_treesitter(true)

local success1, message1 = myst_module.refresh_highlighting()
if success1 and message1 == "Tree-sitter highlighting activated successfully" then
  print("✓ refresh_highlighting correctly reports successful activation")
else
  print("✗ refresh_highlighting incorrect response:", success1, message1)
  return 1
end

-- Test 2: refresh_highlighting detects failed activation
print("\nTest 2: Testing refresh validation with inactive tree-sitter...")

-- Mock failed tree-sitter activation
_G.package.loaded["nvim-treesitter.highlight"] = create_mock_treesitter(false)

local success2, message2 = myst_module.refresh_highlighting()
if not success2 and message2 == "Tree-sitter highlighting failed to activate" then
  print("✓ refresh_highlighting correctly reports failed activation")
else
  print("✗ refresh_highlighting incorrect response:", success2, message2)
  return 1
end

-- Test 3: Fallback behavior when nvim-treesitter not available
print("\nTest 3: Testing fallback when nvim-treesitter not available...")

-- Mock missing nvim-treesitter
_G.package.loaded["nvim-treesitter.configs"] = nil

local success3, message3 = myst_module.refresh_highlighting()
if success3 and message3 == "Using fallback syntax highlighting" then
  print("✓ refresh_highlighting correctly falls back when nvim-treesitter unavailable")
else
  print("✗ refresh_highlighting incorrect fallback response:", success3, message3)
  return 1
end

print("\n=== All Validation Tests Passed ===")
print("✓ refresh_highlighting now validates tree-sitter activation")
print("✓ Proper success/failure reporting implemented")
print("✓ Fallback behavior preserved")
print("\nThe refresh validation fix is working correctly!")

return 0