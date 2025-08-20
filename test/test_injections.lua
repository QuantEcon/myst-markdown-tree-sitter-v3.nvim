#!/usr/bin/env lua

-- Test script for MyST injection queries
-- This tests that the injection queries have been updated correctly

print("Testing MyST injection queries...")

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

-- Test 1: Check myst injection queries
local myst_injections = read_file("queries/myst/injections.scm")
if myst_injections then
  print("✓ MyST injection queries file exists")
  
  -- Check that default language is now python
  if myst_injections:match('injection%.language "python"%)') then
    print("✓ Default code-cell language is set to python")
  else
    print("✗ Default code-cell language is not python")
    return 1
  end
  
  -- Check for python code-cell pattern
  if myst_injections:match('"%{code%-cell%} python"') then
    print("✓ Python code-cell pattern exists")
  else
    print("✗ Python code-cell pattern not found")
    return 1
  end
else
  print("✗ MyST injection queries file not found")
  return 1
end

-- Test 2: Check markdown injection queries
local markdown_injections = read_file("queries/markdown/injections.scm")
if markdown_injections then
  print("✓ Markdown injection queries file exists")
  
  -- Check that default language is now python
  if markdown_injections:match('injection%.language "python"%)') then
    print("✓ Default code-cell language is set to python (markdown)")
  else
    print("✗ Default code-cell language is not python (markdown)")
    return 1
  end
else
  print("✗ Markdown injection queries file not found")
  return 1
end

print("\nAll injection query tests completed successfully!")
return 0