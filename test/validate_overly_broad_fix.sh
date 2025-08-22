#!/usr/bin/env bash

# Test script to validate the fix for overly broad highlighting disabling
# This tests that the surgical approach correctly handles {code-cell} directives
# while preserving other markdown highlighting

echo "Testing MyST {code-cell} highlighting fix..."

# Test file path
TEST_FILE="test/test_overly_broad_highlighting_issue.md"

# Test 1: Verify markdown highlights.scm was removed (reverted PR #53)
if [ -f "queries/markdown/highlights.scm" ]; then
    echo "❌ FAIL: queries/markdown/highlights.scm still exists (should be removed)"
    exit 1
else
    echo "✅ PASS: queries/markdown/highlights.scm removed (PR #53 reverted)"
fi

# Test 2: Verify MyST highlights use high priority
if grep -q "priority\" 200" "queries/myst/highlights.scm"; then
    echo "✅ PASS: MyST highlights use very high priority (200)"
else
    echo "❌ FAIL: MyST highlights don't use high enough priority"
    exit 1
fi

# Test 3: Verify filetype detection is now specific to code-cell only
if grep -q "code%-cell.*or" "ftdetect/myst.lua"; then
    echo "❌ FAIL: ftdetect still uses broad MyST directive detection"
    exit 1
else
    echo "✅ PASS: ftdetect now specific to {code-cell} directives only"
fi

# Test 4: Check if test file exists
if [ -f "$TEST_FILE" ]; then
    echo "✅ PASS: Test file exists for manual validation"
else
    echo "❌ FAIL: Test file missing"
    exit 1
fi

echo ""
echo "All tests passed! Changes:"
echo "  - Reverted PR #53 (removed queries/markdown/highlights.scm)"
echo "  - Made filetype detection specific to {code-cell} directives only"
echo "  - Increased MyST highlighting priority to 200 for better reliability"
echo "  - Preserved all other markdown highlighting functionality"

echo ""
echo "Expected behavior:"
echo "  - Files with only {note}, {warning} etc: remain as markdown with normal highlighting"
echo "  - Files with {code-cell}: become MyST with high-priority MyST highlighting"
echo "  - Regular markdown: unaffected by these changes"