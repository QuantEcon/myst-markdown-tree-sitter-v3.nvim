# Test MyST Code-Cell Syntax Highlighting

This file tests both regular markdown and MyST code-cell syntax highlighting.

## Regular Markdown (should work)

```python
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell (should now work too!)

```{code-cell} python
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## Different Languages

```{code-cell} javascript
const data = [1, 2, 3];
console.log(data.map(x => x * 2));
```

```{code-cell} bash
echo "Hello from MyST code-cell bash!"
ls -la
```

## Edge Cases

```{code-cell}
# This should NOT get syntax highlighting (no language specified)
import pandas as pd
print("No language specified, should not be highlighted")
```

```{code-cell}
# Another test - no syntax highlighting expected
def test_function():
    return "Hello from MyST code-cell with no language specified!"
print(test_function())
```