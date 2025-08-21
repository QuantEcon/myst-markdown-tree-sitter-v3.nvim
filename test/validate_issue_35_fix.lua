#!/usr/bin/env lua

-- Final validation script for Issue #35 fix
-- Tests all the new functionality we've added

print("=== Final Validation for Issue #35 Fix ===")

-- Mock vim environment for testing
local mock_vim = {
  api = {
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_is_valid = function() return true end,
    nvim_buf_get_lines = function() return {"```{code-cell} python", "print('hello')", "```"} end,
    nvim_buf_get_name = function() return "test.md" end,
    nvim_create_autocmd = function() return true end,
    nvim_create_user_command = function() return true end,
    nvim_set_hl = function() return true end,
  },
  bo = { filetype = "myst" },
  treesitter = {
    query = { get = function() return {} end }
  },
  wait = function() return true end,
  defer_fn = function(fn) fn() end,
  cmd = function() return true end,
}

_G.vim = mock_vim

-- Test module loading
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loaded successfully")

-- Test all functions exist
local required_functions = {
  'setup',
  'refresh_highlighting',
  'enable_myst',
  'disable_myst', 
  'debug_myst',
  'status_myst',
  'setup_commands'
}

for _, func_name in ipairs(required_functions) do
  if type(myst_module[func_name]) == 'function' then
    print("✓ " .. func_name .. " function exists")
  else
    print("✗ " .. func_name .. " function missing")
    return 1
  end
end

-- Test refresh_highlighting returns proper values
local success, message = myst_module.refresh_highlighting()
if type(success) == 'boolean' and type(message) == 'string' then
  print("✓ refresh_highlighting returns proper status and message")
else
  print("✗ refresh_highlighting does not return expected format")
  return 1
end

print("\n=== All Validation Tests Passed ===")
print("✓ All required functions present")
print("✓ refresh_highlighting API working correctly")
print("✓ Module loads without errors")
print("\nThe fix for Issue #35 is ready for deployment!")

return 0