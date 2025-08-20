# LaTeX Highlighting Fix Summary

## Problem
The MyST code-cell syntax highlighting was working, but LaTeX highlighting in `$$...$$` blocks was disabled due to missing injection queries.

## Root Cause
The custom injection queries in `queries/markdown/injections.scm` and `queries/myst/injections.scm` were replacing the default nvim-treesitter markdown injection queries entirely, but were missing the critical `markdown_inline` injection pattern.

## Solution
Added the missing `markdown_inline` injection pattern to both query files:

```tree-sitter
;; Critical: Inject markdown_inline parser for inline content (including LaTeX math)
;; This enables LaTeX highlighting in $$...$$ blocks and other inline markdown
([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
```

## How It Works
1. The `markdown_inline` parser is injected for all inline content and table cells
2. The `markdown_inline` parser includes its own injection query for LaTeX:
   ```tree-sitter
   ((latex_block) @injection.content
     (#set! injection.language "latex")
     (#set! injection.include-children))
   ```
3. This enables LaTeX syntax highlighting in `$$...$$` blocks while preserving all MyST code-cell functionality

## Testing
- ✅ LaTeX highlighting in `$$...$$` blocks restored
- ✅ Code-cell highlighting preserved (all 14 languages)
- ✅ Mixed content (math + code-cells) works correctly
- ✅ Both inline (`$...$`) and block (`$$...$$`) math supported
- ✅ All existing functionality maintained

## Files Changed
- `queries/markdown/injections.scm`: Added markdown_inline injection
- `queries/myst/injections.scm`: Added markdown_inline injection  
- Test files enhanced with math examples for validation

The fix is minimal (5 lines per file) and surgical - it only adds the missing functionality without changing any existing behavior.