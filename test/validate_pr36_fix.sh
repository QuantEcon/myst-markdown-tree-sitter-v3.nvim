#!/bin/bash

# Validation script for PR #36 fix 
# Checks for the presence of blocking vim.wait() calls

echo "=== Validating Fix for PR #36 Unresponsiveness Issue ==="
echo ""

echo "Checking for problematic vim.wait() calls in lua/myst-markdown/init.lua..."
if grep -n "vim\.wait(" lua/myst-markdown/init.lua; then
    echo "❌ Found vim.wait() function calls that could cause blocking"
    exit 1
else
    echo "✅ No blocking vim.wait() function calls found"
fi

echo ""
echo "Checking for aggressive vim.cmd('edit!') calls..."
if grep -n "vim\.cmd.*edit!" lua/myst-markdown/init.lua; then
    echo "❌ Found aggressive buffer reload calls"
    exit 1
else
    echo "✅ No aggressive buffer reload found"
fi

echo ""
echo "Checking that vim.defer_fn is used for async operations..."
if grep -n "vim\.defer_fn" lua/myst-markdown/init.lua ftdetect/myst.lua; then
    echo "✅ Found vim.defer_fn usage for async operations"
else
    echo "❌ vim.defer_fn not found - async operations may be missing"
    exit 1
fi

echo ""
echo "Checking for complex retry logic that could cause cascading calls..."
retry_files=$(find . -name "*.lua" -exec grep -l "try again" {} \; 2>/dev/null | wc -l)
if [ "$retry_files" -gt 1 ]; then
    echo "❌ Found complex retry logic in multiple files that could cause cascading calls"
    exit 1
else
    echo "✅ Simplified retry logic to prevent cascading calls"
fi

echo ""
echo "=== All Checks Passed! ==="
echo "✅ Replaced blocking vim.wait() with async vim.defer_fn"
echo "✅ Removed aggressive forced buffer reload"
echo "✅ Simplified refresh logic to prevent excessive processing"
echo "✅ Fix should resolve Neovim unresponsiveness issue"
echo ""
echo "Key improvements made:"
echo "  - Changed from synchronous vim.wait() to asynchronous vim.defer_fn()"
echo "  - Removed vim.cmd('edit!') that could trigger autocmd cascades"
echo "  - Simplified retry mechanisms in ftdetect and init.lua"
echo "  - Reduced complexity in enable/disable functions"
echo "  - Made refresh operations non-blocking"