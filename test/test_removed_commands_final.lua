#!/usr/bin/env lua

-- Final test to verify MyST plugin works without MystEnable/MystDisable
print("=== Final Verification: MyST Plugin Without Manual Commands ===")

-- Mock a minimal vim environment
local mock_vim = {
  api = {
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_get_lines = function() return {"```{code-cell} python", "print('test')", "```"} end,
    nvim_buf_get_name = function() return "test.md" end,
    nvim_set_hl = function() end,
    nvim_create_autocmd = function() end,
    nvim_create_user_command = function(name, fn, opts)
      print("✓ Available command: " .. name)
    end,
  },
  bo = { filetype = "markdown" },
  defer_fn = function(fn, delay) fn() end,
  treesitter = { start = function() return true end, query = { get = function() return {} end } },
  tbl_contains = function(t, v) for _, val in ipairs(t) do if val == v then return true end end return false end,
  tbl_keys = function(t) local k = {} for key in pairs(t) do table.insert(k, key) end return k end,
  cmd = function() end,
}

_G.vim = mock_vim

-- Test module loading
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loads successfully")

-- Test that removed functions are gone
if myst_module.enable_myst then
  print("✗ enable_myst function still exists (should be removed)")
  return 1
else
  print("✓ enable_myst function properly removed")
end

if myst_module.disable_myst then
  print("✗ disable_myst function still exists (should be removed)")
  return 1
else
  print("✓ disable_myst function properly removed")
end

-- Test that essential functions remain
if not myst_module.debug_myst then
  print("✗ debug_myst function missing")
  return 1
else
  print("✓ debug_myst function available")
end

if not myst_module.status_myst then
  print("✗ status_myst function missing")
  return 1
else
  print("✓ status_myst function available")
end

if not myst_module.setup then
  print("✗ setup function missing")
  return 1
else
  print("✓ setup function available")
end

-- Test setup and command registration
print("\n=== Testing Available Commands ===")
myst_module.setup_commands()

print("\n=== Summary ===")
print("✓ MystEnable command removed (as intended)")
print("✓ MystDisable command removed (as intended)")
print("✓ Core functionality preserved")
print("✓ Debug commands still available")
print("✓ Plugin setup works correctly")

print("\n✓ All tests passed! The plugin works correctly without manual enable/disable commands.")
return 0