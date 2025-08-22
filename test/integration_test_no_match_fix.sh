#!/bin/bash

# Comprehensive integration test for the tree-sitter compatible MyST highlighting fix
echo "=== Comprehensive Integration Test for Tree-sitter Compatible MyST Fix ==="
echo ""

# Test 1: Validate core functionality is preserved
echo "1. Testing that existing functionality is preserved..."

if ./test/validate_priority_query_fix.sh > /dev/null 2>&1; then
    echo "✓ Priority query fix still works"
else
    echo "✗ Priority query fix broken"
    exit 1
fi

if ./test/validate.sh > /dev/null 2>&1; then
    echo "✓ General plugin validation passes"
else
    echo "✗ General plugin validation failed"
    exit 1
fi

# Test 2: Validate the new tree-sitter compatible fix
echo ""
echo "2. Testing new tree-sitter compatible functionality..."

if ./test/validate_no_match_fix.sh > /dev/null 2>&1; then
    echo "✓ tree-sitter compatible fix validation passes"
else
    echo "✗ tree-sitter compatible fix validation failed"
    exit 1
fi

# Test 3: Verify query file structure
echo ""
echo "3. Verifying query file structure..."

# Check that we have the right query files
expected_files=(
    "queries/markdown/highlights.scm"
    "queries/markdown/injections.scm"
    "queries/myst/highlights.scm"
    "queries/myst/injections.scm"
)

for file in "${expected_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Test 4: Validate that markdown and MyST patterns work together
echo ""
echo "4. Testing pattern coexistence..."

# Check that standard markdown patterns are preserved
markdown_patterns=$(grep -c "language.*injection" queries/markdown/injections.scm)
if [ "$markdown_patterns" -ge 1 ]; then
    echo "✓ Standard markdown language injection preserved ($markdown_patterns patterns)"
else
    echo "✗ Standard markdown language injection missing"
    exit 1
fi

# Check that MyST patterns are preserved
myst_patterns=$(grep -c "code-cell" queries/myst/injections.scm)
if [ "$myst_patterns" -ge 10 ]; then
    echo "✓ MyST code-cell patterns preserved ($myst_patterns patterns)"
else
    echo "✗ MyST code-cell patterns insufficient ($myst_patterns found)"
    exit 1
fi

# Check that our new highlight disable pattern exists
highlight_disable_patterns=$(grep -c "#set!.*highlight.disable" queries/markdown/highlights.scm)
if [ "$highlight_disable_patterns" -eq 1 ]; then
    echo "✓ highlight.disable pattern correctly implemented"
else
    echo "✗ highlight.disable pattern count incorrect ($highlight_disable_patterns found, expected 1)"
    exit 1
fi

# Test 5: Verify test files are comprehensive
echo ""
echo "5. Validating test coverage..."

test_files=(
    "test/test_no_match_fix.md"
    "test/validate_no_match_fix.sh"
    "test/mixed_syntax_test.md"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Check that our test file has both standard and MyST patterns
if grep -q "^\`\`\`python" test/test_no_match_fix.md && grep -q "^\`\`\`{code-cell}" test/test_no_match_fix.md; then
    echo "✓ Test file contains both standard markdown and MyST patterns"
else
    echo "✗ Test file missing required patterns"
    exit 1
fi

echo ""
echo "=== All Integration Tests Passed! ==="
echo ""
echo "Summary of the fix:"
echo "1. ✓ Added queries/markdown/highlights.scm with #set! highlight.disable for {code-cell} patterns"
echo "2. ✓ Preserved all existing priority-based highlighting"
echo "3. ✓ Maintained compatibility with standard markdown code blocks"
echo "4. ✓ Created comprehensive test suite"
echo "5. ✓ All existing functionality validated"
echo ""
echo "Expected behavior:"
echo "• Standard markdown: \`\`\`python blocks → normal markdown highlighting"
echo "• MyST directives: \`\`\`{code-cell} blocks → MyST highlighting (no markdown interference)"
echo "• No more intermittent highlighting issues for MyST {code-cell} directives"