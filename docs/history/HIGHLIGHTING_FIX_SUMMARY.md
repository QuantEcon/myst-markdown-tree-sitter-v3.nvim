# Intermittent Highlighting Fix Summary

## Problem
After #26, there was an intermittent bug where MyST documents would sometimes show correct syntax highlighting for `{code-cell}` directives and sometimes not. Reopening the document could fix the issue.

**Updated**: After #28, the issue persisted with additional symptoms:
- `:MystEnable` would report success but highlighting wouldn't actually appear
- `:MystRefresh` would say "refreshed" but wouldn't fix the highlighting  
- `markdown` was still taking priority sometimes despite filetype being set to `myst`

## Root Cause
The issue was caused by multiple factors:

1. **Incorrect Tree-sitter API Usage**: The original fix used `vim.treesitter.start()` and `vim.treesitter.stop()` which don't properly manage highlighter state
2. **Race Condition**: Multiple filetype detection mechanisms created conflicts
3. **Insufficient Timing**: 20ms delays were too short for reliable refresh
4. **Missing Error Handling**: Edge cases with invalid buffers weren't handled

## Enhanced Solution
The improved fix addresses all identified issues:

### Key Changes

1. **Proper Tree-sitter API Usage**:
   - Uses `nvim-treesitter.highlight.detach()` and `attach()` for reliable highlighting management
   - Falls back to `vim.treesitter` API if nvim-treesitter unavailable
   - Properly manages highlighter state transitions

2. **Improved Timing**:
   - Increased delays from 20ms to 50ms for more reliable refresh
   - Added buffer validation before operations
   - Better async handling of highlight transitions

3. **Eliminated Conflicts**:
   - Removed duplicate filetype detection in init.lua  
   - Consolidated detection logic in ftdetect/myst.lua
   - Conditional refresh only when filetype actually changes

4. **Enhanced Error Handling**:
   - All tree-sitter operations wrapped in pcall
   - Buffer validity checks before operations
   - Graceful fallback to vim syntax highlighting

5. **Better Debugging & Feedback**:
   - `:MystDebug` shows detailed tree-sitter state information
   - `:MystRefresh` provides real-time status updates
   - Enhanced parser configuration reporting

### Commands Available

- `:MystEnable` - Enable MyST highlighting (with conditional refresh)
- `:MystDisable` - Disable MyST highlighting (with conditional refresh) 
- `:MystRefresh` - Force refresh highlighting (with status feedback)
- `:MystDebug` - Show detailed debugging information (enhanced)

## Testing
The enhanced fix has been validated with:
- Improved test scripts for API validation
- Test MyST files for functionality verification
- Validation scripts demonstrating the fix

Users should no longer experience intermittent highlighting issues, and the manual commands should work reliably.

## Files Modified
- `lua/myst-markdown/init.lua` - Enhanced refresh logic and debugging
- `ftdetect/myst.lua` - Improved timing
- Added comprehensive test files for validation