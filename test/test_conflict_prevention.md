# MyST Code-Cell Highlighting Test

This file tests the MyST highlighting specifically for `{code-cell}` directives.

## Standard Markdown Heading (should highlight normally)

This is a regular heading that should get standard markdown highlighting.

```python
# Regular Python code block (should highlight normally)
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell Tests (should have MyST-specific highlighting)

```{code-cell} python
# This should get MyST code-cell directive highlighting
# The {code-cell} part should be highlighted as @myst.code_cell.directive
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print("MyST code-cell")
```

```{code-cell} javascript
// Another MyST code-cell with different language
// The {code-cell} should still be highlighted as @myst.code_cell.directive
const data = [1, 2, 3];
console.log(data);
```

## Expected Behavior

With MyST highlighting enabled:

1. **Standard markdown** elements (headings, code blocks, emphasis) should work normally
2. **MyST code-cell directives** should be highlighted with @myst.code_cell.directive 
3. **No conflicts** should occur between standard markdown and MyST code-cell highlighting