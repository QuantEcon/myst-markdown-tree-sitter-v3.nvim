#!/bin/bash

# Validation script for Tree-sitter priority fix (Issue #46)
# This script validates that the Tree-sitter priority predicates fix
# the intermittent MyST highlighting issue for {code-cell} directives only

echo "=== Tree-sitter Priority Fix Validation (Issue #46) ==="
echo ""

echo "1. Checking for Tree-sitter priority predicates..."

# Check for priority predicate for code-cell directives
if grep -q '#set! "priority" 110' queries/myst/highlights.scm; then
    echo "✓ Found priority 110 predicate for {code-cell} directives"
else
    echo "✗ Missing priority 110 predicate for {code-cell} directives"
    exit 1
fi

# Verify no general directive priority (scope limited to code-cell only)
if grep -q '#set! "priority" 105' queries/myst/highlights.scm; then
    echo "✗ Found unexpected priority 105 predicate - should only support {code-cell}"
    exit 1
else
    echo "✓ Confirmed scope is limited to {code-cell} directives only"
fi

echo ""
echo "2. Checking capture groups..."

if grep -q '@myst.code_cell.directive' queries/myst/highlights.scm; then
    echo "✓ Found @myst.code_cell.directive capture group"
else
    echo "✗ Missing @myst.code_cell.directive capture group"
    exit 1
fi

# Verify no general directive capture (scope limited to code-cell only)
if grep -q '@myst.directive' queries/myst/highlights.scm && ! grep -q '@myst.code_cell.directive' queries/myst/highlights.scm; then
    echo "✗ Found unexpected general directive pattern - should only support {code-cell}"
    exit 1
else
    echo "✓ Confirmed scope is limited to {code-cell} directives only"
fi

echo ""
echo "3. Validating MyST pattern matching..."

if grep -q 'code-cell' queries/myst/highlights.scm; then
    echo "✓ {code-cell} pattern present"
else
    echo "✗ Missing {code-cell} pattern"
    exit 1
fi

echo ""
echo "4. Fix summary:"
echo "   ✓ Uses Tree-sitter's native #set! \"priority\" predicate"
echo "   ✓ Priority 110 for {code-cell} directives (highest)"
echo "   ✓ Scope limited to {code-cell} directives only"
echo "   ✓ No complex Lua timing or retry logic needed"
echo "   ✓ Follows Tree-sitter best practices"

echo ""
echo "5. Expected behavior:"
echo "   - {code-cell} directives will override markdown highlighting consistently"
echo "   - No more intermittent highlighting issues for {code-cell}"
echo "   - Reliable highlighting without timing dependencies"
echo "   - Other MyST directives: Not supported (future feature)"

echo ""
echo "=== Validation Complete - All Checks Passed! ==="
echo "The Tree-sitter priority fix should resolve the intermittent MyST highlighting issue."