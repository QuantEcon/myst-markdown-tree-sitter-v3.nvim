#!/bin/bash

# Manual test for MyST highlighting conflict prevention
# This opens a test file and shows the expected behavior

echo "=== MyST Highlighting Manual Test ==="
echo
echo "This will open test/test_conflict_prevention.md in Neovim."
echo "You should see consistent highlighting of MyST directives."
echo
echo "Instructions once Neovim opens:"
echo "1. The file should automatically be detected as MyST or markdown"
echo "2. Run :MystEnable to ensure MyST highlighting is active"
echo "3. Check that:"
echo "   - {code-cell} directives are highlighted consistently"
echo "   - {note}, {warning} directives are highlighted"
echo "   - MyST roles like {doc}\`target\` are highlighted"
echo "   - Regular markdown content still works"
echo "4. Use :MystDebug to check the highlighting status"
echo "5. Close with :q when done"
echo
echo "Press Enter to continue..."
read

# Check if we're in the right directory
if [ ! -f "test/test_conflict_prevention.md" ]; then
    echo "Error: test file not found. Run from repository root."
    exit 1
fi

# Try to start neovim with our plugin
if command -v nvim >/dev/null 2>&1; then
    echo "Starting Neovim with MyST plugin..."
    nvim -c "lua vim.opt.runtimepath:prepend('.')" \
         -c "lua require('myst-markdown').setup()" \
         -c "MystEnable" \
         test/test_conflict_prevention.md
else
    echo "Neovim not found. Please install neovim to run this test."
    exit 1
fi

echo "Manual test completed."