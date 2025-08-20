# LaTeX Test File

This file tests LaTeX syntax highlighting.

## Inline Math

Here is some inline math: $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$

## Block Math

$$
\int_a^b f(x) dx = F(b) - F(a)
$$

And another block:

$$
\label{eq1}
\int a = b - \gamma f(x) - 10
$$

## Code Cell Test

```{code-cell} python
import pandas as pd
df = pd.DataFrame()
print(df)
```

## Regular Code Block

```python
import numpy as np
print("Hello")
```