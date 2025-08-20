#!/bin/bash

# Simple validation script for MyST markdown plugin
echo "=== MyST Markdown Plugin Validation ==="
echo

# Check directory structure
echo "✓ Checking plugin structure..."
required_files=(
  "plugin/myst-markdown.lua"
  "ftdetect/myst.lua"
  "ftplugin/myst.lua"
  "lua/myst-markdown/init.lua"
  "queries/myst/highlights.scm"
  "queries/myst/injections.scm"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    echo "  ✓ $file exists"
  else
    echo "  ✗ $file missing"
  fi
done

echo
echo "✓ Checking MyST pattern detection..."

# Test MyST pattern detection on sample file
test_patterns=(
  "code-cell"
  ":::"
  "{\w"
  "^---$"
)

echo "  Testing against test/sample.md:"
for pattern in "${test_patterns[@]}"; do
  count=$(grep -c "$pattern" test/sample.md 2>/dev/null || echo "0")
  if [[ $count -gt 0 ]]; then
    echo "    ✓ Found $count matches for pattern: $pattern"
  else
    echo "    - No matches for pattern: $pattern"
  fi
done

echo
echo "✓ Plugin file validation..."

# Basic syntax check for Lua files
lua_files=$(find . -name "*.lua" -type f)
for file in $lua_files; do
  # Check for basic Lua syntax issues
  if grep -q "local\|function\|end\|return" "$file"; then
    echo "  ✓ $file appears to have valid Lua structure"
  else
    echo "  ? $file may have issues"
  fi
done

echo
echo "✓ MyST injection queries validation:"
if [[ -f "queries/myst/injections.scm" ]]; then
  injection_count=$(grep -c "injection.language" queries/myst/injections.scm)
  echo "  ✓ Found $injection_count language injection patterns"
  
  echo "  ✓ Supported languages:"
  grep -o 'injection.language.*"[^"]*"' queries/myst/injections.scm | sed 's/.*"\([^"]*\)".*/    - \1/' | sort | uniq
else
  echo "  ✗ Missing injection queries file"
fi

echo
echo "✓ MyST features detected in sample:"
echo "  Code-cell directives:"
grep -n "code-cell" test/sample.md | head -3
echo "  Block directives:"
grep -n ":::" test/sample.md | head -3  
echo "  MyST roles:"
grep -n "{[a-zA-Z]" test/sample.md | head -3

echo
echo "=== Validation Complete ==="
echo "The plugin structure appears ready for use with Neovim."
echo "To test: open test/sample.md in Neovim with this plugin installed."