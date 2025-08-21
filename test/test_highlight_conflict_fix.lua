-- Test script for MyST highlighting conflict prevention
-- This validates that the new query system works correctly

local function test_highlight_queries()
  print("=== Testing MyST Highlighting Conflict Prevention ===")
  
  -- Test if the new highlight groups are properly defined
  local highlight_groups = {
    "@myst.code_cell.directive",
    "@myst.directive", 
    "@myst.directive.block",
    "@myst.role",
    "@myst.cross_reference"
  }
  
  print("\n1. Testing highlight groups:")
  for _, group in ipairs(highlight_groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    if next(hl) then
      print("  ✓ " .. group .. " is defined")
    else
      print("  ✗ " .. group .. " is not defined")
    end
  end
  
  -- Test if queries are loaded
  print("\n2. Testing query availability:")
  local has_markdown_highlights = pcall(function()
    return vim.treesitter.query.get("markdown", "highlights")
  end)
  
  local has_myst_highlights = pcall(function()
    return vim.treesitter.query.get("myst", "highlights")
  end)
  
  if has_markdown_highlights then
    print("  ✓ Markdown highlight queries are available")
  else
    print("  ✗ Markdown highlight queries not found")
  end
  
  if has_myst_highlights then
    print("  ✓ MyST highlight queries are available")
  else
    print("  ✗ MyST highlight queries not found")
  end
  
  -- Test if filetype is properly detected
  print("\n3. Testing current buffer:")
  local filetype = vim.bo.filetype
  print("  Current filetype: " .. filetype)
  
  if filetype == "myst" then
    print("  ✓ Buffer detected as MyST")
  elseif filetype == "markdown" then
    print("  ~ Buffer detected as markdown (may need :MystEnable)")
  else
    print("  ? Buffer has unexpected filetype: " .. filetype)
  end
  
  print("\n=== Test Complete ===")
  print("If any items show ✗, there may be an issue with the setup.")
  print("Use :MystDebug for more detailed diagnostics.")
end

-- Run the test
test_highlight_queries()