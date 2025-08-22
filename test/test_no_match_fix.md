# Test MyST Tree-sitter Compatible Highlighting Fix

This test file validates that the tree-sitter compatible highlighting disable fix prevents markdown from highlighting MyST {code-cell} directives.

## Standard Markdown Code Block
This should still have normal markdown highlighting:

```python
# Standard markdown code block
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell Directive  
This should NOT be highlighted by markdown (due to #set! highlight.disable) and should be handled by MyST:

```{code-cell} python
# MyST code-cell directive
import numpy as np
arr = np.array([1, 2, 3])
print(arr.mean())
```

## Another MyST Code-Cell Directive
```{code-cell}
# Another code-cell without language specification
print("This should also be handled by MyST, not markdown")
```

## Validation Points
1. Standard markdown code blocks (```python) should still work
2. MyST {code-cell} directives should not get markdown highlighting
3. MyST highlighting should take precedence for {code-cell} directives starting with ```{code-cell}