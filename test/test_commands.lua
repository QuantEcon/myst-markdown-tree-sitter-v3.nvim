#!/usr/bin/env lua

-- Test script for MyST commands
-- This tests the new manual commands added for debugging and control

print("Testing MyST commands...")

-- Test 1: Module can be loaded
local success, myst_module = pcall(require, 'myst-markdown')
if success then
  print("✓ MyST module loads successfully")
else
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

-- Test 2: Manual command functions exist
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

if type(myst_module.setup_commands) == 'function' then
  print("✓ setup_commands function exists")
else
  print("✗ setup_commands function not found")
  return 1
end

print("\nAll command tests completed successfully!")
return 0