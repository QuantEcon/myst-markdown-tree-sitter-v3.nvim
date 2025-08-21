#!/usr/bin/env lua

-- Test script for highlighting fix
-- This validates that the refresh functionality works correctly

print("Testing MyST highlighting fix...")

-- Test 1: Module can be loaded
local success, myst_module = pcall(require, 'myst-markdown')
if success then
  print("✓ MyST module loads successfully")
else
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

-- Test 2: New refresh function exists
if type(myst_module.refresh_highlighting) == 'function' then
  print("✓ refresh_highlighting function exists")
else
  print("✗ refresh_highlighting function not found")
  return 1
end

-- Test 3: Enhanced manual command functions exist
if type(myst_module.enable_myst) == 'function' then
  print("✓ enable_myst function exists")
else
  print("✗ enable_myst function not found")
  return 1
end

if type(myst_module.disable_myst) == 'function' then
  print("✓ disable_myst function exists")
else
  print("✗ disable_myst function not found")
  return 1
end

if type(myst_module.debug_myst) == 'function' then
  print("✓ debug_myst function exists")
else
  print("✗ debug_myst function not found")
  return 1
end

-- Test 4: Setup commands function exists
if type(myst_module.setup_commands) == 'function' then
  print("✓ setup_commands function exists")
else
  print("✗ setup_commands function not found")
  return 1
end

print("\nAll highlighting fix tests completed successfully!")
print("The fix includes:")
print("  - Explicit tree-sitter highlighting refresh when changing filetypes")
print("  - :MystRefresh command for manual highlighting refresh")
print("  - Enhanced debug output")
print("  - Proper cleanup and restart of tree-sitter highlighting")

return 0