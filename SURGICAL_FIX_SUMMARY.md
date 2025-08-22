# Surgical Fix for Overly Broad Highlighting Disable (Issue #58)

## Problem Statement

The fix in PR #53 was too broad and caused several issues:
1. **Still intermittent** MyST highlighting for `{code-cell}` directives  
2. **Disabled highlighting** for many non-code-cell directives in core markdown
3. Used a broad `(#set! "highlight.disable")` approach that affected more than intended

## Root Cause Analysis

The issue was a mismatch between filetype detection and highlighting coverage:

1. **Broad filetype detection**: `ftdetect/myst.lua` detected ANY MyST directive (`{note}`, `{warning}`, `{admonition}`, etc.) and set filetype to "myst"
2. **Broad highlighting disable**: `queries/markdown/highlights.scm` disabled markdown highlighting for fenced code blocks  
3. **Limited MyST coverage**: `queries/myst/highlights.scm` only provided highlighting for `{code-cell}` directives
4. **Result**: Files with `{note}`, `{warning}`, etc. lost highlighting entirely

## Surgical Solution

### 1. Reverted PR #53
- **Removed** `queries/markdown/highlights.scm` entirely
- No more broad highlighting disabling

### 2. Focused Filetype Detection  
- **Modified** `ftdetect/myst.lua` to only detect files as MyST if they contain `{code-cell}` directives
- Files with only `{note}`, `{warning}`, etc. remain as markdown files

### 3. Enhanced MyST Priority
- **Increased** MyST highlighting priority from 110 to 200
- **Added** comprehensive block-level priority for `{code-cell}` directives
- Better reliability for MyST vs markdown highlighting competition

## Behavioral Changes

| File Content | Before Fix | After Fix |
|--------------|------------|-----------|
| `{code-cell}` only | MyST filetype, intermittent highlighting | MyST filetype, priority 200 highlighting ✅ |
| `{note}`, `{warning}`, etc. only | MyST filetype, no highlighting ❌ | Markdown filetype, normal highlighting ✅ |
| Mixed `{code-cell}` + others | MyST filetype, intermittent highlighting | MyST filetype, priority 200 highlighting ✅ |
| Regular markdown | Markdown filetype, normal highlighting | Markdown filetype, normal highlighting ✅ |

## Technical Implementation

### Modified Files

1. **`ftdetect/myst.lua`**
   ```lua
   -- Before: Detected any MyST directive
   if line:match("^```{code%-cell}") or line:match("^```{[%w%-_]+}") or line:match("^{[%w%-_]+}") then
   
   -- After: Only detect {code-cell} directives  
   if line:match("^```{code%-cell}") then
   ```

2. **`queries/markdown/highlights.scm`**
   ```
   -- Before: Existed with broad disable
   (fenced_code_block ... (#set! "highlight.disable"))
   
   -- After: Removed entirely
   (File deleted)
   ```

3. **`queries/myst/highlights.scm`**
   ```tree-sitter
   -- Before: Priority 110
   (#set! "priority" 110)
   
   -- After: Priority 200 + comprehensive coverage
   (#set! "priority" 200)
   ```

### Test Coverage

- **`test/validate_overly_broad_fix.sh`**: Automated validation script
- **`test/test_code_cell_only.md`**: Test file with only `{code-cell}` directives
- **`test/test_other_myst_directives.md`**: Test file with non-code-cell directives
- **`test/test_overly_broad_highlighting_issue.md`**: Comprehensive test cases

## Validation Results

✅ All tests pass  
✅ Markdown highlights.scm removed (PR #53 reverted)  
✅ MyST highlights use very high priority (200)  
✅ Filetype detection specific to `{code-cell}` directives only  
✅ Regex patterns correctly distinguish directive types  

## Expected Behavior

1. **Files with `{code-cell}` directives**: MyST filetype with high-priority MyST highlighting
2. **Files with other MyST directives only**: Markdown filetype with normal markdown highlighting  
3. **Regular markdown files**: Unchanged behavior
4. **Mixed content**: MyST filetype with MyST highlighting for `{code-cell}`, markdown highlighting for others

This surgical approach addresses the core issue without the broad side effects of the previous fix.