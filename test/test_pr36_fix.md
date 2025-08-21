# Test MyST File for Validation

This is a test MyST markdown file to verify that highlighting still works after the PR #36 fix.

```{code-cell} python
print("Hello from MyST!")
import numpy as np
data = np.array([1, 2, 3, 4, 5])
print(f"Data: {data}")
```

Some regular markdown content to test mixed highlighting.

```{note}
This is a MyST note directive that should be highlighted properly.
```

More content with another code cell:

```{code-cell} python
def test_function():
    return "This should be highlighted as Python code"

result = test_function()
print(result)
```

This file should be detected as MyST and highlighted appropriately without causing Neovim to freeze.