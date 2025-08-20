#!/usr/bin/env lua

-- Test script for MyST configuration options
-- This tests that the configurable default language feature works correctly

print("Testing MyST configuration options...")

-- Set up Lua path to find the module
local current_dir = debug.getinfo(1, "S").source:match("@(.*/)") or "./"
package.path = current_dir .. "../?.lua;" .. current_dir .. "../?/init.lua;" .. package.path

-- Mock vim API for testing
local mock_vim = {
  api = {
    nvim_create_autocmd = function(events, opts) return true end,
    nvim_create_user_command = function(name, fn, opts) return true end,
    nvim_set_hl = function(ns, name, opts) return true end,
    nvim_buf_get_lines = function(buf, start, end_line, strict)
      return {"# Test file", "```{code-cell}", "print('test')", "```"}
    end,
    nvim_get_current_buf = function() return 1 end,
    nvim_list_runtime_paths = function() return {} end
  },
  bo = { filetype = "markdown" },
  wo = {},
  cmd = function(cmd_str) end,
  treesitter = {
    start = function(buf, lang) return true end,
    query = { get = function(lang, query_type) return {} end }
  },
  tbl_deep_extend = function(behavior, ...)
    local result = {}
    for _, tbl in ipairs({...}) do
      for k, v in pairs(tbl) do
        result[k] = v
      end
    end
    return result
  end,
  fn = {
    stdpath = function(what) return "/tmp" end,
    isdirectory = function(path) return 0 end,
    filewritable = function(path) return 0 end
  }
}

-- Set up the mock vim global
_G.vim = mock_vim

-- Test 1: Load the module
local success, myst_module = pcall(require, 'myst-markdown')
if not success then
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

print("✓ MyST module loaded successfully")

-- Test 2: Default configuration
local default_setup_success = pcall(function()
  myst_module.setup()
end)

if default_setup_success then
  print("✓ Default setup completed successfully")
  print("  Default language: " .. (myst_module.config.default_code_cell_language or "not set"))
  
  if myst_module.config.default_code_cell_language == "python" then
    print("✓ Default language is correctly set to 'python'")
  else
    print("✗ Default language is not 'python'")
    return 1
  end
else
  print("✗ Default setup failed")
  return 1
end

-- Test 3: Custom configuration - Julia
print("\nTesting custom configuration with Julia...")
local julia_setup_success = pcall(function()
  myst_module.setup({
    default_code_cell_language = "julia"
  })
end)

if julia_setup_success then
  print("✓ Julia setup completed successfully")
  print("  Configured language: " .. myst_module.config.default_code_cell_language)
  
  if myst_module.config.default_code_cell_language == "julia" then
    print("✓ Custom language is correctly set to 'julia'")
  else
    print("✗ Custom language is not 'julia'")
    return 1
  end
else
  print("✗ Julia setup failed")
  return 1
end

-- Test 4: Custom configuration - R
print("\nTesting custom configuration with R...")
local r_setup_success = pcall(function()
  myst_module.setup({
    default_code_cell_language = "r"
  })
end)

if r_setup_success then
  print("✓ R setup completed successfully")
  print("  Configured language: " .. myst_module.config.default_code_cell_language)
  
  if myst_module.config.default_code_cell_language == "r" then
    print("✓ Custom language is correctly set to 'r'")
  else
    print("✗ Custom language is not 'r'")
    return 1
  end
else
  print("✗ R setup failed")
  return 1
end

-- Test 5: Test debug function shows configuration
print("\nTesting debug function shows configuration...")
local debug_success = pcall(function()
  myst_module.debug_myst()
end)

if debug_success then
  print("✓ Debug function works and shows configuration")
else
  print("✗ Debug function failed")
  return 1
end

-- Test 6: Verify config persistence
print("\nTesting configuration persistence...")
if myst_module.config and myst_module.config.default_code_cell_language then
  print("✓ Configuration object exists and persists")
  print("  Current setting: " .. myst_module.config.default_code_cell_language)
else
  print("✗ Configuration object missing or incomplete")
  return 1
end

print("\n✓ All configuration tests passed!")
print("Configuration features working correctly:")
print("  • Default language configurable")
print("  • Multiple language options supported")
print("  • Configuration persists after setup")
print("  • Debug function shows current configuration")

return 0