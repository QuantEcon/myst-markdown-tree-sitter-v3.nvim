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