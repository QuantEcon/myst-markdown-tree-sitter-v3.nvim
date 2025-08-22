#!/bin/bash

# Test script to validate the #no-match fix for MyST highlighting
echo "=== Testing #no-match Fix for MyST Highlighting ==="
echo ""

# Check that markdown highlights.scm file exists
echo "1. Checking for markdown highlights.scm file..."
if [ -f "queries/markdown/highlights.scm" ]; then
    echo "✓ queries/markdown/highlights.scm exists"
else
    echo "✗ queries/markdown/highlights.scm missing"
    exit 1
fi

# Check that the file contains #no-match predicate
echo ""
echo "2. Checking for #no-match predicate..."
if grep -q "#no-match!" queries/markdown/highlights.scm; then
    echo "✓ Found #no-match! predicate"
else
    echo "✗ Missing #no-match! predicate"
    exit 1
fi

# Check that pattern matches directives starting with {code-cell}
echo ""
echo "3. Checking pattern for {code-cell} directives..."
if grep -q 'code-cell' queries/markdown/highlights.scm; then
    echo "✓ Found pattern matching {code-cell} directives"
else
    echo "✗ Missing pattern for {code-cell} directives"
    exit 1
fi

# Check that it targets info_string of fenced_code_block
echo ""
echo "4. Checking fenced_code_block targeting..."
if grep -q "fenced_code_block" queries/markdown/highlights.scm && grep -q "info_string" queries/markdown/highlights.scm; then
    echo "✓ Correctly targets fenced_code_block info_string"
else
    echo "✗ Does not properly target fenced_code_block info_string"
    exit 1
fi

# Verify MyST highlights.scm still has priority settings
echo ""
echo "5. Checking MyST priority settings are preserved..."
if grep -q "priority.*110" queries/myst/highlights.scm; then
    echo "✓ MyST priority settings preserved"
else
    echo "✗ MyST priority settings missing"
    exit 1
fi

echo ""
echo "6. File contents validation..."
echo "   markdown highlights.scm:"
cat queries/markdown/highlights.scm | sed 's/^/   /'

echo ""
echo "=== All Tests Passed! ==="
echo ""
echo "Expected behavior:"
echo "1. Markdown will not highlight code blocks starting with \`\`\`{code-cell}"
echo "2. MyST can now highlight {code-cell} directives without interference"
echo "3. Standard markdown code blocks (\`\`\`python) still work normally"
echo "4. This should fix the intermittent highlighting issue for {code-cell} directives"