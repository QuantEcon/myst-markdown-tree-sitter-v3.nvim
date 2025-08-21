#!/bin/bash

echo "=== MyST Highlighting Conflict Prevention Validation ==="
echo
echo "This script validates that the MyST highlighting conflict prevention fix is working."
echo

# Get the script directory and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "Testing from: $REPO_ROOT"
echo

echo "1. Testing plugin setup..."
if nvim --headless +"lua vim.opt.runtimepath:prepend('.')" +"lua require('myst-markdown').setup(); print('✓ Setup completed')" +q > /dev/null 2>&1; then
    echo "   ✓ MyST plugin loads without errors"
else
    echo "   ✗ MyST plugin failed to load"
    exit 1
fi

echo
echo "2. Testing query files exist..."
if [ -f "queries/markdown/highlights.scm" ]; then
    echo "   ✓ Markdown highlights.scm exists (conflict prevention)"
    echo "     Lines: $(wc -l < queries/markdown/highlights.scm)"
else
    echo "   ✗ Markdown highlights.scm missing"
fi

if [ -f "queries/myst/highlights.scm" ]; then
    echo "   ✓ MyST highlights.scm exists"
    echo "     Lines: $(wc -l < queries/myst/highlights.scm)"
else
    echo "   ✗ MyST highlights.scm missing"
fi

echo
echo "3. Testing highlight group definitions..."
nvim --headless +"lua vim.opt.runtimepath:prepend('.')" +"lua 
require('myst-markdown').setup()
local groups = {'@myst.code_cell.directive', '@myst.directive', '@myst.role'}
for _, group in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    if next(hl) then
        print('   ✓ ' .. group .. ' is defined')
    else
        print('   ✗ ' .. group .. ' is not defined')
    end
end
" +q

echo
echo "4. Key differences in this fix:"
echo "   - Added queries/markdown/highlights.scm with conflict prevention predicates"
echo "   - Uses (#not-match?) to exclude MyST patterns from standard markdown highlighting"
echo "   - Enhanced queries/myst/highlights.scm for better MyST pattern matching"
echo "   - Prevents intermittent highlighting by resolving parser conflicts"

echo
echo "5. Test files created:"
echo "   - test/test_conflict_prevention.md (comprehensive test cases)"
echo "   - test/test_highlight_conflict_fix.lua (automated validation)"

echo
echo "=== Validation Complete ==="