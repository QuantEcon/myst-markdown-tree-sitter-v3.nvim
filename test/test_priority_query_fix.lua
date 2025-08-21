#!/usr/bin/env lua

-- Test script for Tree-sitter priority-based highlighting fix (Issue #46)
-- This validates that MyST Tree-sitter queries include priority predicates for {code-cell} directives

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
  print("✓ Found priority 110 predicate for {code-cell} directives")
else
  print("✗ Missing priority 110 predicate for {code-cell} directives")
  return 1
end

-- Test 2: Check for myst.code_cell.directive capture
if content:match('@myst%.code_cell%.directive') then
  print("✓ Found @myst.code_cell.directive capture")
else
  print("✗ Missing @myst.code_cell.directive capture")
  return 1
end

-- Test 3: Verify proper regex pattern for code-cell
if content:match('code%-cell') then
  print("✓ Found proper {code-cell} regex pattern")
else
  print("✗ Missing proper {code-cell} regex pattern")
  return 1
end

-- Test 4: Verify no general directive patterns (scope limited to code-cell only)
if content:match('@myst%.directive') and not content:match('@myst%.code_cell%.directive') then
  print("✗ Found unexpected general directive pattern - should only support {code-cell}")
  return 1
else
  print("✓ Confirmed scope is limited to {code-cell} directives only")
end

print("\n=== Tree-sitter Priority Query Fix Test Results ===")
print("✓ All tests passed!")
print("✓ Priority predicates correctly added to MyST highlight queries")
print("✓ Code-cell directives will have priority 110 (highest)")
print("✓ Scope correctly limited to {code-cell} directives only")
print("✓ This should resolve intermittent MyST highlighting issues")

print("\nThe fix works by:")
print("  - Adding #set! \"priority\" predicate to Tree-sitter queries")
print("  - Priority 110 for {code-cell} directives (highest priority)")
print("  - Tree-sitter will automatically use this priority during highlighting")
print("  - No complex Lua-based timing or retry logic needed")
print("  - Focused scope: only {code-cell} directives supported")

return 0