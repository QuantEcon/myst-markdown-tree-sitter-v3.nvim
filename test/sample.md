---
title: MyST Markdown Test Document
author: Test Author
---

# MyST Markdown Test

This is a test document for MyST markdown syntax highlighting.

## Code Cell Example

Here's a Python code cell that should be highlighted:

```{code-cell} python
import pandas as pd
import numpy as np

# Create a simple DataFrame
df = pd.DataFrame({
    'x': np.random.randn(100),
    'y': np.random.randn(100)
})

print(df.head())
```

For comparison, here's a regular markdown code block:

```python
import pandas as pd
df = pd.DataFrame()
print(df)
```

Here's a JavaScript code-cell:

```{code-cell} javascript
const data = [1, 2, 3, 4, 5];
const doubled = data.map(x => x * 2);
console.log(doubled);
```

Here's a Bash code-cell:

```{code-cell} bash
#!/bin/bash
echo "Testing MyST code-cell syntax highlighting"
for i in {1..5}; do
    echo "Count: $i"
done
```

## Other MyST Features

Here's a MyST role: {doc}`some_document`

And here's a MyST directive:

```{note}
This is a note directive that should be highlighted differently.
```

Block directives also work:

:::{warning}
This is a warning block directive.
:::

## Math

MyST also supports math: $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$