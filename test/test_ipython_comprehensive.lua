#!/usr/bin/env lua

-- Comprehensive test for iPython synonym functionality
-- This tests the actual injection patterns in detail

print("=== Comprehensive iPython Synonym Test ===")

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

-- Test function to validate injection patterns structure
local function test_injection_structure(file_path, test_name)
  local content = read_file(file_path)
  if not content then
    print("✗ Could not read " .. file_path)
    return false
  end
  
  print("\n--- Testing " .. test_name .. " ---")
  
  -- Test MyST code-cell ipython pattern
  local ipython_pattern = content:match('%(%(fenced_code_block.-%(#eq%? @_lang "%{code%-cell%} ipython"%).-%(#set! injection%.language "python"%%)')
  if ipython_pattern then
    print("✓ MyST code-cell ipython pattern correctly structured")
  else
    print("✗ MyST code-cell ipython pattern missing or malformed")
    return false
  end
  
  -- Test MyST code-cell ipython3 pattern
  local ipython3_pattern = content:match('%(%(fenced_code_block.-%(#eq%? @_lang "%{code%-cell%} ipython3"%).-%(#set! injection%.language "python"%%)')
  if ipython3_pattern then
    print("✓ MyST code-cell ipython3 pattern correctly structured")
  else
    print("✗ MyST code-cell ipython3 pattern missing or malformed")
    return false
  end
  
  -- Test regular markdown ipython pattern (only for markdown file)
  if test_name:match("Markdown") then
    local md_ipython_pattern = content:match('%(%(fenced_code_block.-%(#eq%? @_lang "ipython"%).-%(#set! injection%.language "python"%%)')
    if md_ipython_pattern then
      print("✓ Regular markdown ipython pattern correctly structured")
    else
      print("✗ Regular markdown ipython pattern missing or malformed")
      return false
    end
    
    local md_ipython3_pattern = content:match('%(%(fenced_code_block.-%(#eq%? @_lang "ipython3"%).-%(#set! injection%.language "python"%%)')
    if md_ipython3_pattern then
      print("✓ Regular markdown ipython3 pattern correctly structured")
    else
      print("✗ Regular markdown ipython3 pattern missing or malformed")
      return false
    end
  end
  
  -- Test that original python pattern still exists
  local python_pattern = content:match('%(%(fenced_code_block.-%(#eq%? @_lang "%{code%-cell%} python"%).-%(#set! injection%.language "python"%%)')
  if python_pattern then
    print("✓ Original python pattern preserved")
  else
    print("✗ Original python pattern missing")
    return false
  end
  
  return true
end

-- Test pattern ordering (ipython patterns should come after python but before javascript)
local function test_pattern_ordering(file_path, test_name)
  local content = read_file(file_path)
  if not content then
    return false
  end
  
  print("\n--- Testing " .. test_name .. " Pattern Ordering ---")
  
  -- Find positions of key patterns
  local python_pos = content:find('code%-cell%} python"', 1, false)
  local ipython_pos = content:find('code%-cell%} ipython"', 1, false) 
  local ipython3_pos = content:find('code%-cell%} ipython3"', 1, false)
  local javascript_pos = content:find('code%-cell%} javascript"', 1, false)
  
  if python_pos and ipython_pos and ipython3_pos and javascript_pos then
    if python_pos < ipython_pos and ipython_pos < ipython3_pos and ipython3_pos < javascript_pos then
      print("✓ Pattern ordering correct: python < ipython < ipython3 < javascript")
      return true
    else
      print("✗ Pattern ordering incorrect")
      return false
    end
  else
    print("✗ Could not find all required patterns for ordering test")
    return false
  end
end

-- Run the tests
local myst_success = test_injection_structure("queries/myst/injections.scm", "MyST")
local myst_ordering = test_pattern_ordering("queries/myst/injections.scm", "MyST")

local markdown_success = test_injection_structure("queries/markdown/injections.scm", "Markdown") 
local markdown_ordering = test_pattern_ordering("queries/markdown/injections.scm", "Markdown")

print("\n=== Final Test Results ===")
if myst_success and myst_ordering and markdown_success and markdown_ordering then
  print("✓ All iPython synonym tests passed!")
  print("✓ Code-cell patterns: {code-cell} ipython and {code-cell} ipython3 map to python")
  print("✓ Regular markdown patterns: ```ipython and ```ipython3 map to python")
  print("✓ Original functionality preserved")
  print("✓ Pattern ordering is correct")
  return 0
else
  print("✗ Some iPython synonym tests failed")
  return 1
end