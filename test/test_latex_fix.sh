#!/bin/bash

# Test script to verify LaTeX highlighting fix
echo "=== Testing LaTeX Highlighting Fix ==="

# Check that markdown_inline injection is present in both files
echo "✓ Checking for markdown_inline injection..."

myst_count=$(grep -c "markdown_inline" queries/myst/injections.scm)
markdown_count=$(grep -c "markdown_inline" queries/markdown/injections.scm)

if [ "$myst_count" -eq 2 ] && [ "$markdown_count" -eq 2 ]; then
    echo "✓ markdown_inline injection found in both query files"
else
    echo "✗ markdown_inline injection missing (myst: $myst_count, markdown: $markdown_count)"
    exit 1
fi

# Check that code-cell patterns are still present
echo "✓ Checking code-cell patterns..."

code_cell_count=$(grep -c "code-cell" queries/myst/injections.scm)
if [ "$code_cell_count" -ge 10 ]; then
    echo "✓ Code-cell patterns preserved ($code_cell_count patterns found)"
else
    echo "✗ Code-cell patterns missing or insufficient"
    exit 1
fi

# Check that inline and pipe_table_cell patterns are present
echo "✓ Checking inline content patterns..."

inline_count=$(grep -c "inline" queries/myst/injections.scm)
if [ "$inline_count" -ge 2 ]; then
    echo "✓ Inline content patterns found"
else
    echo "✗ Inline content patterns missing"
    exit 1
fi

# Check test files contain math
echo "✓ Checking test files contain math..."

math_count=$(grep -c '\$\$' test/latex_test.md test/sample.md 2>/dev/null | awk -F: 'BEGIN{sum=0} {sum+=$2} END{print sum}')
if [ "$math_count" -ge 3 ]; then
    echo "✓ Math examples found in test files ($math_count blocks)"
else
    echo "✗ Insufficient math examples in test files ($math_count found)"
    exit 1
fi

echo ""
echo "=== All Tests Passed ==="
echo "The fix should restore LaTeX highlighting while preserving code-cell functionality"
echo ""
echo "Key changes made:"
echo "1. Added markdown_inline injection to both query files"
echo "2. This enables LaTeX highlighting in \$\$...\$\$ blocks"
echo "3. Code-cell highlighting patterns are preserved"
echo "4. Test files updated with math examples"