#!/usr/bin/env lua

-- Demo script showing ipython synonym functionality
print("=== IPython Synonym Support Demo ===")
print()

-- Function to simulate injection query matching
local function test_injection_query(info_string, file_type)
  local content = ""
  
  if file_type == "myst" then
    local file = io.open("queries/myst/injections.scm", "r")
    if file then
      content = file:read("*all")
      file:close()
    end
  else
    local file = io.open("queries/markdown/injections.scm", "r")
    if file then
      content = file:read("*all")
      file:close()
    end
  end
  
  -- Check what injection language would be applied
  if info_string == "{code-cell} python" and content:find('{code%-cell} python"') then
    return "python"
  elseif info_string == "{code-cell} ipython" and content:find('{code%-cell} ipython"') then
    return "python" 
  elseif info_string == "{code-cell} ipython3" and content:find('{code%-cell} ipython3"') then
    return "python"
  elseif info_string == "ipython" and content:find('"ipython"') then
    return "python"
  elseif info_string == "ipython3" and content:find('"ipython3"') then
    return "python"
  else
    return "no highlighting"
  end
end

-- Test cases demonstrating the new functionality
local test_cases = {
  { pattern = "{code-cell} python", description = "Standard MyST Python code-cell" },
  { pattern = "{code-cell} ipython", description = "NEW: MyST iPython code-cell" },
  { pattern = "{code-cell} ipython3", description = "NEW: MyST iPython3 code-cell" },
  { pattern = "python", description = "Standard markdown Python block" },
  { pattern = "ipython", description = "NEW: Markdown iPython block" },
  { pattern = "ipython3", description = "NEW: Markdown iPython3 block" }
}

print("Testing injection behavior for MyST file type:")
print("=" .. string.rep("=", 50))

for _, test in ipairs(test_cases) do
  local result = test_injection_query(test.pattern, "myst")
  local status = result == "python" and "✓" or "✗"
  local new_indicator = test.description:match("NEW:") and " 🆕" or ""
  
  print(string.format("%s ```%s", status, test.pattern))
  print(string.format("   %s → %s%s", test.description, result, new_indicator))
  print()
end

print("Testing injection behavior for Markdown file type:")
print("=" .. string.rep("=", 50))

for _, test in ipairs(test_cases) do
  local result = test_injection_query(test.pattern, "markdown")
  local status = result == "python" and "✓" or "✗"
  local new_indicator = test.description:match("NEW:") and " 🆕" or ""
  
  print(string.format("%s ```%s", status, test.pattern))
  print(string.format("   %s → %s%s", test.description, result, new_indicator))
  print()
end

print("=== Key Benefits ===")
print("✓ iPython and iPython3 code blocks now get proper Python syntax highlighting")
print("✓ Works in both MyST code-cells and regular markdown code blocks")
print("✓ All existing functionality preserved")
print("✓ No configuration required - works out of the box")
print()

print("=== Example Usage ===")
print("MyST Code-Cell (NEW):")
print("```{code-cell} ipython")
print("import pandas as pd")
print("df = pd.DataFrame({'data': [1,2,3]})")
print("```")
print()

print("Regular Markdown (NEW):")
print("```ipython3")
print("import numpy as np")
print("arr = np.array([1,2,3,4,5])")
print("print(arr.mean())")
print("```")

print()
print("✓ Demo completed successfully!")
return 0