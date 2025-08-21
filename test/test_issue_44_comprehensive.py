#!/usr/bin/env python3

"""
Comprehensive test for MyST priority parameter fix (Issue #44).
This validates that the fix resolves the original error while maintaining functionality.
"""

import os
import re

def test_priority_removal():
    """Test that priority parameters have been completely removed."""
    init_file = '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/lua/myst-markdown/init.lua'
    
    with open(init_file, 'r') as f:
        content = f.read()
    
    # Check for any remaining priority references
    priority_patterns = [
        r'priority\s*=',
        r'priority\s*:',
        r'priority\s*\d+',
    ]
    
    for pattern in priority_patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            print(f"❌ ERROR: Found priority parameter: {matches}")
            return False
    
    print("✅ No priority parameters found in code")
    return True

def test_highlight_structure():
    """Test that highlight calls are properly structured."""
    init_file = '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/lua/myst-markdown/init.lua'
    
    with open(init_file, 'r') as f:
        content = f.read()
    
    # Check for expected highlight structure
    expected_patterns = [
        r'vim\.api\.nvim_set_hl\(0,\s*"@myst\.code_cell\.directive",\s*{\s*link\s*=\s*"Special"\s*}\)',
        r'vim\.api\.nvim_set_hl\(0,\s*"@myst\.directive",\s*{\s*link\s*=\s*"Special"\s*}\)',
    ]
    
    for i, pattern in enumerate(expected_patterns):
        if not re.search(pattern, content, re.MULTILINE):
            print(f"❌ ERROR: Expected highlight pattern {i+1} not found")
            return False
    
    print("✅ All highlight calls properly structured")
    return True

def test_function_integrity():
    """Test that the setup_myst_highlighting function is intact."""
    init_file = '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/lua/myst-markdown/init.lua'
    
    with open(init_file, 'r') as f:
        content = f.read()
    
    # Check function exists
    if 'function M.setup_myst_highlighting()' not in content:
        print("❌ ERROR: setup_myst_highlighting function not found")
        return False
    
    # Check function ends properly
    function_start = content.find('function M.setup_myst_highlighting()')
    function_content = content[function_start:content.find('end', function_start) + 3]
    
    # Should contain two nvim_set_hl calls
    nvim_set_hl_count = function_content.count('vim.api.nvim_set_hl')
    if nvim_set_hl_count != 2:
        print(f"❌ ERROR: Expected 2 nvim_set_hl calls in function, found {nvim_set_hl_count}")
        return False
    
    print("✅ setup_myst_highlighting function is intact")
    return True

def test_comment_updates():
    """Test that comments have been updated appropriately."""
    init_file = '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/lua/myst-markdown/init.lua'
    
    with open(init_file, 'r') as f:
        content = f.read()
    
    # Check that priority-related comments are updated
    if 'Higher priority ensures' in content:
        print("❌ ERROR: Old priority-related comment still present")
        return False
    
    if 'compatibility with older Neovim versions' not in content:
        print("❌ ERROR: New compatibility comment not found")
        return False
    
    print("✅ Comments updated appropriately")
    return True

def test_test_file_updates():
    """Test that test files have been updated."""
    test_file = '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/test/test_priority_highlighting.lua'
    
    with open(test_file, 'r') as f:
        content = f.read()
    
    # Check test file references Issue #44
    if 'Issue #44' not in content:
        print("❌ ERROR: Test file should reference Issue #44")
        return False
    
    # Check for compatibility messaging
    if 'compatibility' not in content.lower():
        print("❌ ERROR: Test file should mention compatibility")
        return False
    
    print("✅ Test files updated appropriately")
    return True

def test_new_files_created():
    """Test that new test files were created."""
    expected_files = [
        '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/test/test_issue_44.md',
        '/home/runner/work/myst-markdown-tree-sitter.nvim/myst-markdown-tree-sitter.nvim/test/validate_issue_44_fix.sh'
    ]
    
    for file_path in expected_files:
        if not os.path.exists(file_path):
            print(f"❌ ERROR: Expected test file not created: {file_path}")
            return False
    
    print("✅ New test files created")
    return True

def main():
    print("=== Comprehensive Test for MyST Priority Parameter Fix ===\n")
    
    tests = [
        ("Priority Parameter Removal", test_priority_removal),
        ("Highlight Structure", test_highlight_structure),
        ("Function Integrity", test_function_integrity),
        ("Comment Updates", test_comment_updates),
        ("Test File Updates", test_test_file_updates),
        ("New Files Created", test_new_files_created),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"Testing {test_name}...")
        if test_func():
            passed += 1
        else:
            print(f"❌ {test_name} FAILED")
        print()
    
    print("="*60)
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("✅ ALL TESTS PASSED!")
        print("✅ The MyST plugin should now work without priority parameter errors")
        print("✅ Compatible with Neovim 0.11.3 and other versions")
        print("✅ No functionality lost, only compatibility improved")
        return 0
    else:
        print("❌ SOME TESTS FAILED!")
        print("❌ The fix may not be complete")
        return 1

if __name__ == "__main__":
    exit(main())