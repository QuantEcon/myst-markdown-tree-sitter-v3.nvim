# Test MyST No-Match Fix

This test file validates that the `#no-match` fix prevents markdown from highlighting MyST directives.

## Standard Markdown Code Block
This should still have normal markdown highlighting:

```python
# Standard markdown code block
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell Directive  
This should NOT be highlighted by markdown (due to #no-match) and should be handled by MyST:

```{code-cell} python
# MyST code-cell directive
import numpy as np
arr = np.array([1, 2, 3])
print(arr.mean())
```

## MyST Note Directive
This should also NOT be highlighted by markdown:

```{note}
This is a MyST note directive that should not get markdown highlighting.
```

## Another MyST Directive
```{warning}
This warning directive should also be handled by MyST, not markdown.
```

## Validation Points
1. Standard markdown code blocks (```python) should still work
2. MyST directives (```{code-cell}, ```{note}, etc.) should not get markdown highlighting
3. MyST highlighting should take precedence for directives starting with ```{