# MyST Priority-based Highlighting Test

This file tests the new priority-based highlighting approach that replaces the complex race condition fix.

## Regular Markdown Code Block

```python
# This should have normal Python highlighting
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell with Priority Highlighting

```{code-cell} python
# This should have MyST priority highlighting for the directive
# The code inside should still have Python highlighting
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## Another MyST Code-Cell

```{code-cell} javascript
// The {code-cell} directive should be highlighted with priority = 110
const data = [1, 2, 3];
console.log(data.map(x => x * 2));
```

## MyST Note Directive

```{note}
This note directive should also be highlighted with priority-based highlighting.
```

## Expected Behavior

With the priority-based approach:

1. MyST directives like `{code-cell}` should be highlighted with `fg = "#ff6b6b"` and `priority = 110`
2. This should override any markdown highlighting for these elements
3. No complex timing or retry logic should be needed
4. Highlighting should be more reliable and simpler to debug

The approach is much simpler than the race condition fix that was reverted.