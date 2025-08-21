# Race Condition Fix for Intermittent MyST Highlighting (Issue #40)

## Problem Summary

Users reported intermittent MyST syntax highlighting where documents would sometimes show correct highlighting for `{code-cell}` directives and sometimes only show base markdown highlighting. The issue occurred randomly and required reopening files multiple times until MyST highlighting would appear.

The core issue was identified as a race condition between:
1. Markdown tree-sitter parser initialization
2. MyST highlighting activation
3. Filetype detection timing

## Root Cause Analysis

The intermittent behavior was caused by:

1. **Race Condition**: MyST highlighting sometimes initialized before markdown tree-sitter was ready, and sometimes after
2. **Insufficient Timing**: Short delays (20-50ms) were not reliable for consistent initialization order
3. **Missing Validation**: No verification that highlighting actually became active after refresh attempts
4. **No Retry Logic**: Failed highlighting activation had no fallback mechanisms

## Solution Implementation

### 1. Enhanced Tree-sitter Initialization Order

**Before**: MyST highlighting attempted to start immediately when filetype was set
**After**: MyST highlighting defers initialization by 100ms to ensure markdown tree-sitter establishes first

```lua
-- In FileType autocmd for myst
vim.defer_fn(function()
  -- MyST initialization after markdown is ready
  M.refresh_highlighting()
end, 100) -- Longer delay ensures proper order
```

### 2. Improved Refresh Logic with Validation

**Before**: Asynchronous detach/attach with no validation
**After**: Multi-stage refresh with validation and retry logic

```lua
-- Enhanced refresh with validation
local function attempt_refresh(retry_count)
  -- 1. Detach existing highlighter
  -- 2. Wait for clean detach
  -- 3. Attach new highlighter  
  -- 4. Validate highlighting is actually active
  -- 5. Retry if failed (up to 3 attempts)
  -- 6. Fallback to buffer reload as last resort
end
```

### 3. Enhanced User Feedback

**Before**: Simple "refresh initiated" message
**After**: Multi-stage status reporting showing actual progress

```lua
-- MystRefresh now provides detailed feedback:
-- "MyST highlighting refresh initiated with enhanced reliability..."
-- "Tree-sitter highlighter status (check 1): active"
-- "✓ MyST highlighting successfully activated!"
```

### 4. Increased Timing Delays

- **ftdetect timing**: 50ms → 150ms for more reliable filetype detection
- **refresh timing**: 20ms → 50ms with validation delays
- **priority timing**: Added 100ms defer in FileType autocmd

## Files Modified

1. **`lua/myst-markdown/init.lua`**:
   - Enhanced `refresh_highlighting()` with retry logic and validation
   - Improved FileType autocmd with deferred initialization
   - Enhanced `:MystRefresh` command with detailed feedback

2. **`ftdetect/myst.lua`**:
   - Increased timing delay from 50ms to 150ms
   - Updated comments to reflect improved timing strategy

## Testing and Validation

Added comprehensive test files:
- `test/test_race_condition_fix.md` - Sample MyST file for testing
- `test/test_race_condition_fix.lua` - Automated test for fix validation
- `test/validate_race_condition_fix.lua` - Final validation script

## Expected Results

With this fix, users should experience:

1. **Consistent highlighting**: MyST syntax highlighting should activate reliably on file open
2. **Effective refresh**: `:MystRefresh` should consistently restore highlighting when needed
3. **Better feedback**: Clear indication of highlighting status and any issues
4. **Reduced manual intervention**: Less need to reopen files or manually enable MyST

## Usage Instructions

If highlighting issues persist:
1. Run `:MystStatus` for quick diagnosis
2. Use `:MystRefresh` for enhanced refresh with status feedback
3. Try `:MystDisable` followed by `:MystEnable` for full reset
4. Use `:MystDebug` for detailed troubleshooting information

The enhanced refresh logic should resolve the race condition and provide reliable MyST highlighting activation.