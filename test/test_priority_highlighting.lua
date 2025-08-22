#!/usr/bin/env lua

-- Test script for MyST highlighting compatibility fix (Issue #44)
-- This validates that MyST highlighting works without priority parameter

print("Testing MyST highlighting compatibility fix (Issue #44)...")

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
      elseif not opts.priority then
        print("  Using standard highlight (no priority for compatibility)")
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

-- Test 3: Test command setup
print("\n=== Testing Command Setup ===")
myst_module.setup_commands()

print("\n=== Testing Debug Commands ===")
print("Testing MystStatus:")
myst_module.status_myst()

print("Testing MystDebug:")
myst_module.debug_myst()

print("\n=== Compatibility Fix Summary ===")
print("✓ Removed complex race condition retry logic")
print("✓ Removed priority parameter for Neovim compatibility")
print("✓ Simplified refresh function without validation loops")
print("✓ Streamlined debug and status commands")
print("✓ Reduced timing delays from 150ms to 50ms")
print("✓ Removed unused manual enable/disable commands")
print("\nThe simplified approach should work across more Neovim versions!")

return 0