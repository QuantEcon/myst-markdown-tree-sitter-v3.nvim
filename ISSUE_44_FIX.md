# Fix for Issue #44: Plugin Fails to Load with Priority Parameter Error

## Problem Summary

Users experienced plugin loading failures with the error:
```
Error executing lua callback: invalid key: priority
stack traceback:
        [C]: in function 'nvim_set_hl'
        ...yst-markdown-tree-sitter.nvim/lua/myst-markdown/init.lua:83: in function 'setup_myst_highlighting'
```

This occurred when using Neovim 0.11.3 and other versions where the `priority` parameter for `vim.api.nvim_set_hl()` is not supported.

## Root Cause

PR #43 introduced priority-based highlighting using the `priority = 110` parameter in `nvim_set_hl()` calls. However, this parameter is not available in all Neovim versions, causing the plugin to fail during initialization.

## Solution

### Code Changes

1. **Removed priority parameters** from `lua/myst-markdown/init.lua`:
   ```lua
   -- Before (causing errors):
   vim.api.nvim_set_hl(0, "@myst.code_cell.directive", { 
     link = "Special",
     priority = 110  -- This parameter is not supported in all versions
   })
   
   -- After (compatible):
   vim.api.nvim_set_hl(0, "@myst.code_cell.directive", { 
     link = "Special"
   })
   ```

2. **Updated comments** to reflect compatibility focus rather than priority-based approach

3. **Maintained functionality** by keeping the `link = "Special"` parameter for proper color scheme integration

### Testing Added

- `test/test_issue_44.md` - Manual test file for verification
- `test/validate_issue_44_fix.sh` - Validation instructions script  
- `test/test_issue_44_comprehensive.py` - Automated validation
- Updated `test/test_priority_highlighting.lua` for compatibility testing

## Impact

### ✅ What Works
- Plugin loads successfully in Neovim 0.11.3 and other versions
- MyST directive highlighting still functions correctly
- All manual commands (`:MystEnable`, `:MystRefresh`, etc.) work
- No breaking changes to existing functionality
- Compatible across different Neovim versions

### 📝 What Changed
- Removed unsupported `priority` parameter from highlight calls
- Updated documentation and comments to reflect compatibility focus
- Enhanced test suite to validate the fix

### 🔄 What Remains the Same
- All MyST highlighting functionality preserved
- Same highlight groups (`@myst.code_cell.directive`, `@myst.directive`)
- Same color scheme integration via `link = "Special"`
- Same user commands and API

## Testing the Fix

### Manual Testing
1. Open a MyST file: `nvim test/test_issue_44.md`
2. Plugin should load without errors
3. Run `:MystEnable` to verify highlighting works
4. Run `:MystStatus` to check plugin status

### Automated Testing
```bash
# Run comprehensive validation
python3 test/test_issue_44_comprehensive.py

# Run validation script
./test/validate_issue_44_fix.sh
```

## Version Compatibility

- **Before**: Required Neovim with priority parameter support
- **After**: Works with Neovim >= 0.8.0 (as documented in README)
- **Tested**: Confirmed to work with Neovim 0.11.3

## Future Considerations

If priority-based highlighting becomes essential in the future, the implementation could:

1. Check Neovim version and conditionally use priority
2. Use feature detection to test if priority is supported
3. Implement alternative methods for highlight precedence

However, the current fix provides stable functionality across all supported Neovim versions without complex version checking.

## Files Modified

- `lua/myst-markdown/init.lua` - Removed priority parameters
- `test/test_priority_highlighting.lua` - Updated for compatibility testing
- `test/test_issue_44.md` - New test file
- `test/validate_issue_44_fix.sh` - New validation script
- `test/test_issue_44_comprehensive.py` - New comprehensive test

This fix resolves Issue #44 by ensuring the MyST plugin loads successfully across different Neovim versions while maintaining all highlighting functionality.