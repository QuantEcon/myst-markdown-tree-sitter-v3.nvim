# MyST Highlighting Issue #35 - Fix Documentation

## Problem Summary

Users experienced intermittent syntax highlighting issues where MyST documents would sometimes show correct highlighting for `{code-cell}` directives and sometimes only show base markdown highlighting. The `:MystRefresh` command would report "Tree-sitter active: nil" instead of properly refreshing highlighting.

## Root Cause

The issue was caused by race conditions and insufficient validation in the tree-sitter attach/detach process. The original refresh logic used asynchronous operations that didn't properly validate whether the highlighting was actually activated.

## Solution Overview

This fix implements a more robust tree-sitter refresh mechanism with:

1. **Synchronous operations** using `vim.wait()` instead of `vim.defer_fn()`
2. **Better validation** that highlighter actually becomes active
3. **Multiple fallback mechanisms** including forced buffer reload
4. **Enhanced user feedback** with detailed status messages
5. **New diagnostic tools** for troubleshooting

## New Commands

### `:MystStatus`
Quick health check showing:
- File detection status (myst vs markdown)
- Tree-sitter highlighter status
- MyST content detection

Example output:
```
=== MyST Status ===
Filetype: myst
✓ File detected as MyST
✓ Tree-sitter highlighting active
✓ MyST content detected in buffer
==================
```

### Enhanced `:MystRefresh`
Now provides detailed feedback:
```
MyST highlighting refresh initiated...
Current filetype: myst
MyST highlighting refreshed successfully - Tree-sitter highlighting activated successfully
Tree-sitter highlighter status: active
```

### Enhanced `:MystDebug`
Includes diagnostic suggestions when issues are found:
```
=== MyST Debug Information ===
Current filetype: myst
Tree-sitter available: true
Active parser: myst
Tree-sitter highlighter: not active
Highlighter issues: no highlighter instance for buffer

Diagnostic suggestions:
  - Try :MystRefresh to force re-initialization
  - Try :MystDisable followed by :MystEnable
=== End Debug Info ===
```

## Usage Instructions

### If highlighting is not working:

1. **Quick diagnosis**: Run `:MystStatus`
2. **If file not detected as MyST**: Run `:MystEnable`
3. **If tree-sitter not active**: Run `:MystRefresh`
4. **If still not working**: Run `:MystDisable` then `:MystEnable`
5. **For detailed diagnosis**: Run `:MystDebug`

### Troubleshooting

**Issue**: File opens with markdown highlighting instead of MyST
- **Solution**: Run `:MystEnable` to force MyST filetype detection

**Issue**: `:MystRefresh` says "Tree-sitter active: false"
- **Solution**: This should now be fixed with the new synchronous refresh logic

**Issue**: Highlighting disappears randomly
- **Solution**: The new retry logic should prevent this, but you can run `:MystRefresh` if needed

## Technical Details

### Key Improvements

1. **Synchronous attach/detach**: Uses `vim.wait()` for timing instead of `vim.defer_fn()`
2. **Validation after attach**: Checks that `ts_highlight.active[buf]` is actually set
3. **Forced reload fallback**: Uses `vim.cmd("edit!")` as last resort
4. **Better error handling**: All operations wrapped in `pcall` with detailed error messages
5. **Return values**: Functions now return success/failure status with messages

### Files Modified

- `lua/myst-markdown/init.lua` - Main refresh logic improvements
- `ftdetect/myst.lua` - Updated to use new refresh function
- `test/test_issue_35.md` - Test file for validation
- `test/test_issue_35_fix.lua` - Validation script

## Testing

To test the fix:

1. Open a MyST file (like `test/test_issue_35.md`)
2. Run `:MystStatus` to check initial state
3. Try `:MystRefresh` and verify it reports success
4. Run `:MystDebug` for detailed information
5. Test `:MystDisable` and `:MystEnable` cycle

The fix should eliminate the intermittent highlighting issues and provide clear feedback about the state of MyST highlighting.