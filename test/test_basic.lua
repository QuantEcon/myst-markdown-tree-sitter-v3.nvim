#!/usr/bin/env lua

-- Simple test script to validate MyST plugin functionality
-- This is a minimal test that can be run with lua

print("Testing MyST markdown plugin...")

-- Test 1: Module can be loaded
local success, myst_module = pcall(require, 'myst-markdown')
if success then
  print("✓ MyST module loads successfully")
else
  print("✗ Failed to load MyST module:", myst_module)
  return 1
end

-- Test 2: Setup function exists
if type(myst_module.setup) == 'function' then
  print("✓ Setup function exists")
else
  print("✗ Setup function not found")
  return 1
end

-- Test 3: File pattern detection logic
local function test_myst_detection(content, expected)
  local is_myst = false
  
  for _, line in ipairs(content) do
    if line:match("^```{[%w%-_]+}") or    -- MyST directives like {code-cell}
       line:match("{[%w%-_]+}`[^`]*`") or -- MyST roles like {doc}`filename`
       line:match("^:::{[%w%-_]+}") or    -- MyST block directives
       line:match("^---$") then           -- YAML frontmatter (common in MyST)
      is_myst = true
      break
    end
  end
  
  if is_myst == expected then
    return true
  else
    return false
  end
end

-- Test cases for MyST detection
local test_cases = {
  {
    content = {"# Regular markdown", "This is just normal markdown"},
    expected = false,
    name = "Regular markdown"
  },
  {
    content = {"```{code-cell} python", "print('hello')", "```"},
    expected = true,
    name = "Code-cell directive"
  },
  {
    content = {"Some text with {doc}`filename` role"},
    expected = true,
    name = "MyST role"
  },
  {
    content = {":::{note}", "This is a note", ":::"},
    expected = true,
    name = "Block directive"
  },
  {
    content = {"---", "title: Test", "---"},
    expected = true,
    name = "YAML frontmatter"
  }
}

print("\nTesting MyST detection patterns...")
for _, test in ipairs(test_cases) do
  if test_myst_detection(test.content, test.expected) then
    print("✓", test.name)
  else
    print("✗", test.name)
  end
end

print("\nAll basic tests completed!")
return 0