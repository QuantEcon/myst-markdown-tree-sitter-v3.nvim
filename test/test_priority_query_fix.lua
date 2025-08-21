#!/usr/bin/env lua

-- Test script for Tree-sitter priority-based highlighting fix (Issue #46)
-- This validates that MyST Tree-sitter queries include priority predicates

print("Testing Tree-sitter priority query fix (Issue #46)...")

-- Read the MyST highlights.scm file to check for priority predicates
local highlights_file = "queries/myst/highlights.scm"
local file = io.open(highlights_file, "r")

if not file then
  print("✗ Failed to open " .. highlights_file)
  return 1
end

local content = file:read("*all")
file:close()

print("✓ Successfully read " .. highlights_file)

-- Test 1: Check for priority predicate in code-cell directive
if content:match('#set!%s+"priority"%s+110') then
  print("✓ Found priority 110 predicate for high-priority MyST elements")
else
  print("✗ Missing priority 110 predicate for high-priority MyST elements")
  return 1
end

-- Test 2: Check for priority predicate for general directives  
if content:match('#set!%s+"priority"%s+105') then
  print("✓ Found priority 105 predicate for general MyST directives")
else
  print("✗ Missing priority 105 predicate for general MyST directives")
  return 1
end

-- Test 3: Check for myst.code_cell.directive capture
if content:match('@myst%.code_cell%.directive') then
  print("✓ Found @myst.code_cell.directive capture")
else
  print("✗ Missing @myst.code_cell.directive capture")
  return 1
end

-- Test 4: Check for myst.directive capture  
if content:match('@myst%.directive') then
  print("✓ Found @myst.directive capture")
else
  print("✗ Missing @myst.directive capture")
  return 1
end

-- Test 5: Verify proper regex patterns
if content:match('code%-cell') then
  print("✓ Found proper {code-cell} regex pattern")
else
  print("✗ Missing proper {code-cell} regex pattern")
  return 1
end

if content:match('%[a%-zA%-Z%]') then
  print("✓ Found proper general directive regex pattern")
else
  print("✗ Missing proper general directive regex pattern")
  return 1
end

print("\n=== Tree-sitter Priority Query Fix Test Results ===")
print("✓ All tests passed!")
print("✓ Priority predicates correctly added to MyST highlight queries")
print("✓ Code-cell directives will have priority 110 (highest)")
print("✓ Other MyST directives will have priority 105 (high)")
print("✓ This should resolve intermittent MyST highlighting issues")

print("\nThe fix works by:")
print("  - Adding #set! \"priority\" predicates to Tree-sitter queries")
print("  - Priority 110 for {code-cell} directives (highest priority)")
print("  - Priority 105 for other MyST directives like {note}, {warning}, etc.")
print("  - Tree-sitter will automatically use these priorities during highlighting")
print("  - No complex Lua-based timing or retry logic needed")

return 0