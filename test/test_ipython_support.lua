#!/usr/bin/env lua

-- Test script for iPython synonym support
-- This tests that ipython and ipython3 are properly mapped to python syntax highlighting

print("Testing iPython synonym support...")

-- Function to read file content
local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

-- Test function to check if patterns exist in injection files
local function test_patterns(file_path, patterns)
  local content = read_file(file_path)
  if not content then
    print("✗ Could not read file: " .. file_path)
    return false
  end
  
  local all_found = true
  for _, pattern in ipairs(patterns) do
    if not content:find(pattern, 1, true) then  -- true for plain text search
      print("✗ Pattern not found in " .. file_path .. ": " .. pattern)
      all_found = false
    else
      print("✓ Pattern found in " .. file_path .. ": " .. pattern)
    end
  end
  
  return all_found
end

-- Expected patterns for MyST code-cell support
local myst_patterns = {
  '#eq? @_lang "{code-cell} ipython"',
  '#set! injection.language "python"',
  '#eq? @_lang "{code-cell} ipython3"'
}

-- Expected patterns for regular markdown support (only MyST code-cell, no regular ipython)
local markdown_patterns = {
  '#eq? @_lang "{code-cell} ipython"',
  '#set! injection.language "python"', 
  '#eq? @_lang "{code-cell} ipython3"'
}

print("\n=== Testing MyST injection patterns ===")
local myst_success = test_patterns("queries/myst/injections.scm", myst_patterns)

print("\n=== Testing Markdown injection patterns ===")  
local markdown_success = test_patterns("queries/markdown/injections.scm", markdown_patterns)

print("\n=== Test Summary ===")
if myst_success and markdown_success then
  print("✓ All iPython synonym patterns found!")
  return 0
else
  print("✗ Some iPython synonym patterns missing")
  return 1
end