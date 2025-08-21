#!/bin/bash

echo "=== MyST Code-Cell Highlighting Validation ==="
echo
echo "This script validates that MyST code-cell highlighting is working properly."
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
local groups = {'@myst.code_cell.directive'}
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
echo "4. Focus of this implementation:"
echo "   - Support for {code-cell} directive highlighting only"
echo "   - Simple and focused MyST pattern matching"
echo "   - Preserves standard markdown highlighting for other elements"

echo
echo "5. Test files:"
echo "   - test/test_conflict_prevention.md (code-cell test cases)"

echo
echo "=== Validation Complete ==="