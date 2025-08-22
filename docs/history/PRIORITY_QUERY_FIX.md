# Tree-sitter Priority Fix for Issue #46

## Problem

The issue reported intermittent MyST highlighting when MyST files are loaded. Previous attempts using `vim.api.nvim_set_hl()` with `priority = 110` in Lua code didn't work reliably due to misinformed documentation about how priority works in Neovim.

## Solution

The fix implements the suggested approach from the issue to use `#set! "priority"` predicates directly in Tree-sitter query files (.scm files), which is the correct way to set priority for Tree-sitter highlighting.

## Changes Made

### Core Fix

**File: `queries/myst/highlights.scm`**
- Added `(#set! "priority" 110)` to `{code-cell}` directive queries (highest priority)
- Added `(#set! "priority" 105)` to other MyST directive queries (high priority)
- Extended pattern matching to capture general MyST directives like `{note}`, `{warning}`, etc.

### Testing & Validation

Added comprehensive test files:
- `test/test_priority_query_fix.lua` - Basic validation of priority predicates
- `test/test_comprehensive_priority_fix.lua` - Comprehensive validation test
- `test/test_priority_fix_demo.md` - Demo file showing different MyST directives
- `test/validate_priority_query_fix.sh` - Shell script for easy validation

## How It Works

1. **Tree-sitter Priority System**: Uses Tree-sitter's native `#set! "priority"` predicate
2. **Priority Levels**:
   - `{code-cell}` directives: Priority 110 (highest)
   - Other MyST directives: Priority 105 (high)
   - Standard markdown: Default priority (lower)
3. **Automatic Application**: Tree-sitter automatically applies these priorities during highlighting

## Benefits

- **Reliable**: Uses Tree-sitter's built-in priority system instead of Lua-based approaches
- **Standard**: Follows Tree-sitter best practices for highlight precedence
- **Minimal**: Only modified Tree-sitter queries, no complex logic changes
- **No Timing Issues**: Eliminates race conditions and timing-based problems
- **Consistent**: MyST elements will always override markdown highlighting

## Expected Behavior

With this fix:
- MyST directives like `{code-cell}`, `{note}`, `{warning}` will be highlighted consistently
- No more intermittent highlighting failures
- MyST highlighting takes precedence over standard markdown without timing dependencies
- Simpler, more maintainable code

## Validation

Run the included test scripts to validate the fix:

```bash
# Lua validation
lua test/test_priority_query_fix.lua
lua test/test_comprehensive_priority_fix.lua

# Shell validation  
./test/validate_priority_query_fix.sh
```

All tests should pass, confirming that the Tree-sitter priority predicates are correctly implemented.

## Summary

This fix directly addresses the issue #46 by implementing the suggested `#set! "priority"` approach in Tree-sitter query files. It's a minimal, standards-compliant solution that should resolve the intermittent MyST highlighting issue reliably.