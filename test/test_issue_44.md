# Test MyST Document for Issue #44

This document can be used to test that the MyST plugin loads correctly after fixing the priority parameter issue.

## Regular Markdown Code Block

```python
# This should have normal Python highlighting
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell Directive

```{code-cell} python
# This should be highlighted as a MyST directive
# The code inside should still have Python highlighting
import numpy as np
arr = np.array([1, 2, 3])
print(arr.mean())
```

## Another MyST Code-Cell

```{code-cell} javascript
// This should work without priority parameter errors
const data = [1, 2, 3];
console.log(data.map(x => x * 2));
```

## MyST Note Directive

```{note}
This note directive should be highlighted correctly without requiring priority parameters.
```

## Expected Behavior

After the fix:

1. The plugin should load without "invalid key: priority" errors
2. MyST directives like `{code-cell}` should still be highlighted
3. The syntax highlighting should work in Neovim 0.11.3 and other versions
4. No priority-based highlighting conflicts should occur

## Testing Commands

To test this file in Neovim:

1. Open this file: `:e test_issue_44.md`
2. Enable MyST: `:MystEnable`
3. Check status: `:MystStatus`
4. Refresh if needed: `:MystRefresh`
5. Debug info: `:MystDebug`

All commands should work without priority parameter errors.