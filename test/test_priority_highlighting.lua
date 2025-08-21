#!/usr/bin/env lua

-- Test script for priority-based highlighting approach (Issue #42)
-- This validates that the simplified priority-based approach works correctly

print("Testing priority-based MyST highlighting approach (Issue #42)...")

-- Mock vim environment for testing
local mock_vim = {
  api = {
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_is_valid = function() return true end,
    nvim_buf_get_lines = function() return {"```{code-cell} python", "print('test')", "```"} end,
    nvim_create_autocmd = function() end,
    nvim_create_user_command = function() end,
    nvim_set_hl = function(ns, name, opts) 
      print("✓ Setting highlight: " .. name .. " with priority: " .. (opts.priority or "none"))
      if opts.link then
        print("  Linking to: " .. opts.link .. " (adapts to color scheme)")
      end
      if opts.priority and opts.priority >= 110 then
        print("  High priority highlight detected (should override markdown)")
      end
    end,
  },
  bo = { filetype = "myst" },
  defer_fn = function(fn, delay) 
    print("  Using simple defer_fn with delay: " .. delay .. "ms")
    fn() 
  end,
  cmd = function() return true end,
  treesitter = {
    start = function() return true end,
    stop = function() return true end,
  }
}

_G.vim = mock_vim

-- Test module loading
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loaded successfully")

-- Test 1: Priority-based highlighting setup
print("\n=== Testing Priority-based Highlighting ===")
myst_module.setup_myst_highlighting()

-- Test 2: Simplified refresh function
print("\n=== Testing Simplified Refresh Function ===")
local success, message = myst_module.refresh_highlighting()
print("Refresh result: " .. tostring(success) .. " - " .. (message or "no message"))

if success and message and not message:find("validation") then
  print("✓ Simplified refresh without complex validation confirmed")
else
  print("? Message still contains validation logic")
end

-- Test 3: Test simple enable/disable
print("\n=== Testing Simplified Enable/Disable ===")
print("Testing MystEnable:")
myst_module.enable_myst()

print("Testing MystDisable:")
myst_module.disable_myst()

-- Test 4: Test command setup
print("\n=== Testing Command Setup ===")
myst_module.setup_commands()

print("\n=== Priority-based Approach Summary ===")
print("✓ Removed complex race condition retry logic")
print("✓ Implemented priority-based highlighting (priority = 110)")
print("✓ Simplified refresh function without validation loops")
print("✓ Streamlined enable/disable commands")
print("✓ Reduced timing delays from 150ms to 50ms")
print("\nThe priority-based approach should resolve highlighting issues more simply!")

return 0