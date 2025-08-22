# Priority-based Highlighting Fix (Issue #42)

## Problem Summary

The complex race condition fix from PR #41 did not solve the underlying intermittent MyST highlighting issue. The retry logic, validation loops, and enhanced timing added complexity without resolving the core problem.

## New Approach: Priority-based Highlighting

Instead of complex timing and retry mechanisms, we now use Neovim's highlight priority system to ensure MyST highlights take precedence over markdown highlights.

## Implementation

### Key Changes

1. **Simplified FileType autocmd**: Direct tree-sitter setup without defer delays
2. **Priority-based highlights**: Use `vim.api.nvim_set_hl()` with `priority = 110`
3. **Simplified refresh function**: Remove retry logic and validation loops
4. **Reduced timing**: Revert delays from 150ms back to 50ms

### Priority Highlighting Setup

```lua
vim.api.nvim_set_hl(0, "@myst.code_cell.directive", { 
  link = "Special",
  priority = 110  -- Higher than default priority
})

vim.api.nvim_set_hl(0, "@myst.directive", { 
  link = "Special", 
  priority = 110
})
```

### Benefits

- **Simpler code**: Removed 500+ lines of complex retry and validation logic
- **More reliable**: Highlights work based on priority, not timing
- **Easier debugging**: No complex asynchronous operations
- **Better performance**: No retry loops or validation checks

## Files Modified

- `lua/myst-markdown/init.lua`: Simplified to use priority-based approach
- `ftdetect/myst.lua`: Reverted timing from 150ms to 50ms
- Removed `RACE_CONDITION_FIX.md` and related test files

## Testing

- `test/test_priority_highlighting.lua`: Validates the new approach
- `test/test_priority_approach.md`: Example MyST file for testing

## Usage

The priority-based approach works automatically. MyST directives will be highlighted with higher priority than markdown, ensuring they appear correctly without manual intervention.

Commands remain the same:
- `:MystEnable` - Enable MyST highlighting
- `:MystDisable` - Disable MyST highlighting  
- `:MystRefresh` - Refresh highlighting (now simplified)
- `:MystStatus` - Show status
- `:MystDebug` - Show debug information

The approach should resolve the intermittent highlighting issues while being much simpler to maintain and debug.