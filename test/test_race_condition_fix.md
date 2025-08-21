# MyST Test File for Race Condition Fix

This file tests the improved highlighting that should resolve intermittent issues.

## Code Cell Example

```{code-cell} python
import pandas as pd
import numpy as np

# Test data
data = {'x': [1, 2, 3], 'y': [4, 5, 6]}
df = pd.DataFrame(data)
print(df)
```

## Another Code Cell

```{code-cell} javascript
const data = [1, 2, 3, 4, 5];
const doubled = data.map(x => x * 2);
console.log(doubled);
```

## MyST Directive

```{note}
This is a MyST note directive that should be highlighted properly.
```

## Regular Markdown

This is regular markdown content that should also work normally.

```python
# Regular markdown code block
print("This should have Python highlighting")
```

## Edge Case

```{code-cell}
# Code cell without language specification
# Should default to Python highlighting
print("Testing default language highlighting")
```