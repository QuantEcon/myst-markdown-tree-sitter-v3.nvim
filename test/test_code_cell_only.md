# Test Files with Different MyST Directives

This directory contains test files that demonstrate the surgical fix for PR #53.

## Files with {code-cell} directives only
These files should be detected as MyST and get MyST highlighting:

```{code-cell} python
# This should get MyST highlighting with priority 200
import numpy as np
data = np.array([1, 2, 3, 4, 5])
print(f"Mean: {data.mean()}")
```

## Files with other MyST directives only
If a file only contains other MyST directives like {note}, {warning}, {admonition}, etc.,
they should remain as markdown files with normal markdown highlighting.

This is the key improvement from the surgical fix.