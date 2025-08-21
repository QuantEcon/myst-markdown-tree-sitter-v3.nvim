# Fix for Plugin Update Issue

## Problem
Users were unable to update the MyST plugin via plugin managers (lazy.nvim, etc.) due to local git changes error:

```
Your local changes in .local/share/nvim/lazy/myst-markdown-tree-sitter-v3.nvim
   * queries/markdown/injections.scm
   * queries/myst/injections.scm
 Please remove them to update.
```

## Root Cause
The `setup_injection_queries()` function was dynamically writing injection query files at runtime to support configurable default languages. This created local modifications that git detected as uncommitted changes, preventing plugin updates.

## Solution
- Removed dynamic query file generation from `setup_injection_queries()`
- Function now does nothing to avoid file system writes
- Rely entirely on static query files already committed to the repository
- Static files provide the same functionality with Python as the default language

## Trade-offs
- **Fixed**: Plugin updates now work without conflicts
- **Preserved**: All core MyST highlighting functionality
- **Preserved**: All 14 supported language injections for code-cells
- **Preserved**: LaTeX math highlighting support
- **Limited**: `default_code_cell_language` configuration is no longer functional (defaults to Python)

## Changes Made
1. **lua/myst-markdown/init.lua**: Simplified `setup_injection_queries()` to remove file writes
2. **README.md**: Updated documentation to reflect configuration limitations
3. **test/test_no_local_changes.lua**: Added test to verify no git changes are created

## Testing
- ✅ Injection queries still work properly
- ✅ All language highlighting preserved  
- ✅ No files written during plugin operation
- ✅ Plugin setup completes without errors
- ✅ No local git changes created

## Future Considerations
The configurable default language feature could be restored in the future using:
- Runtime query registration via nvim-treesitter API
- Temporary file generation in non-tracked locations
- Dynamic query modification without file writes

This fix prioritizes plugin usability (updates) over configuration flexibility.