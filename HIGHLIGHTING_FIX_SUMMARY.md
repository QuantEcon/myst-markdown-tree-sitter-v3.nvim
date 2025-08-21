# Intermittent Highlighting Fix Summary

## Problem
After #26, there was an intermittent bug where MyST documents would sometimes show correct syntax highlighting for `{code-cell}` directives and sometimes not. Reopening the document could fix the issue.

## Root Cause
The issue was caused by a race condition between tree-sitter markdown highlighting and the plugin's filetype detection:

1. File loads and is initially detected as `markdown` filetype
2. Tree-sitter starts highlighting with markdown parser
3. Plugin detects MyST content and changes filetype to `myst`
4. Tree-sitter highlighting doesn't get properly refreshed with the new filetype context

## Solution
The fix implements explicit tree-sitter highlighting refresh when filetype changes:

### Key Changes

1. **Added `refresh_highlighting()` function**:
   - Properly stops current tree-sitter highlighting
   - Restarts with appropriate parser for the current filetype
   - Uses small delay to ensure clean stop before restart

2. **Enhanced filetype detection**:
   - When switching from `markdown` to `myst`, triggers highlighting refresh
   - Both in `ftdetect/myst.lua` and `lua/myst-markdown/init.lua`

3. **Added `:MystRefresh` command**:
   - Manual command to force refresh highlighting
   - Useful for debugging and fixing highlighting issues

4. **Enhanced manual commands**:
   - `:MystEnable` and `:MystDisable` now refresh highlighting
   - More reliable switching between filetypes

5. **Improved debugging**:
   - `:MystDebug` shows tree-sitter highlighter state
   - Better diagnostic information for troubleshooting

### Commands Available

- `:MystEnable` - Enable MyST highlighting (now with refresh)
- `:MystDisable` - Disable MyST highlighting (now with refresh) 
- `:MystRefresh` - Force refresh highlighting (new)
- `:MystDebug` - Show debugging information (enhanced)

## Testing
The fix has been tested with validation scripts and should resolve the intermittent highlighting issues. Users can now use `:MystRefresh` if they encounter highlighting problems.

## Files Modified
- `lua/myst-markdown/init.lua` - Main logic changes
- `ftdetect/myst.lua` - Enhanced filetype detection
- `README.md` - Updated documentation
- Added test files for validation