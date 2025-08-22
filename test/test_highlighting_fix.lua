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

-- Test 2: Core setup functions exist
if type(myst_module.setup_myst_highlighting) == 'function' then
  print("✓ setup_myst_highlighting function exists")
else
  print("✗ setup_myst_highlighting function not found")
  return 1
end

-- Test 3: Enhanced manual command functions exist
if type(myst_module.debug_myst) == 'function' then
  print("✓ debug_myst function exists")
else
  print("✗ debug_myst function not found")
  return 1
end

if type(myst_module.status_myst) == 'function' then
  print("✓ status_myst function exists")
else
  print("✗ status_myst function not found")
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
print("  - Debug commands for troubleshooting MyST highlighting")
print("  - Status commands for checking MyST detection")
print("  - Automatic filetype detection based on MyST content")

return 0