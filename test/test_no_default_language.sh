#!/bin/bash

# Test script to validate that {code-cell} without language parameter 
# no longer gets default Python highlighting

echo "=== Testing Removal of Default Language for {code-cell} ===="

# Function to check if pattern exists in file
check_pattern_removed() {
    local file="$1"
    local pattern='#eq? @_directive "{code-cell}"'
    
    if grep -q "$pattern" "$file"; then
        echo "❌ ERROR: Default {code-cell} pattern still found in $file"
        return 1
    else
        echo "✅ Default {code-cell} pattern correctly removed from $file"
        return 0
    fi
}

# Test 1: Check that default pattern is removed from injection files
echo "Testing injection query files..."

check_pattern_removed "queries/markdown/injections.scm"
markdown_result=$?

check_pattern_removed "queries/myst/injections.scm"
myst_result=$?

# Test 2: Verify explicit language patterns still exist
echo ""
echo "Testing that explicit language patterns are preserved..."

if grep -q '{code-cell} python' queries/markdown/injections.scm; then
    echo "✅ Explicit Python code-cell pattern preserved in markdown injections"
else
    echo "❌ ERROR: Explicit Python code-cell pattern missing from markdown injections"
    exit 1
fi

if grep -q '{code-cell} python' queries/myst/injections.scm; then
    echo "✅ Explicit Python code-cell pattern preserved in myst injections"
else
    echo "❌ ERROR: Explicit Python code-cell pattern missing from myst injections"
    exit 1
fi

# Test 3: Check that other explicit languages are preserved
languages=("javascript" "bash" "r" "julia" "cpp" "c" "rust" "go" "typescript")

for lang in "${languages[@]}"; do
    if grep -q "{code-cell} $lang" queries/markdown/injections.scm && grep -q "{code-cell} $lang" queries/myst/injections.scm; then
        echo "✅ Explicit $lang code-cell pattern preserved"
    else
        echo "❌ ERROR: Explicit $lang code-cell pattern missing"
        exit 1
    fi
done

# Test 4: Verify ipython synonyms are preserved
if grep -q '{code-cell} ipython' queries/markdown/injections.scm && grep -q '{code-cell} ipython' queries/myst/injections.scm; then
    echo "✅ IPython synonym patterns preserved"
else
    echo "❌ ERROR: IPython synonym patterns missing"
    exit 1
fi

echo ""
echo "=== Test Results ==="

if [ $markdown_result -eq 0 ] && [ $myst_result -eq 0 ]; then
    echo "✅ SUCCESS: Default language pattern correctly removed from both injection files"
    echo "✅ All explicit language patterns preserved"
    echo "✅ {code-cell} without language will no longer get default Python highlighting"
    echo "✅ {code-cell} with explicit language will continue to work as expected"
    echo ""
    echo "This change resolves Issue #68 by ensuring that:"
    echo "  - {code-cell} without language gets no syntax highlighting"
    echo "  - Only {code-cell} with explicit language gets syntax highlighting"
    echo "  - No functional regression for explicit language specifications"
    exit 0
else
    echo "❌ FAILURE: Some tests failed"
    exit 1
fi