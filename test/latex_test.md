# LaTeX and Code-Cell Test File

This file tests both LaTeX syntax highlighting and MyST code-cell functionality.

## Inline Math

Here is some inline math: $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$

And some more: $\int_0^1 f(x) dx$

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
import numpy as np
df = pd.DataFrame()
print(df)
```

## More Math

Between code cells, we should still have working math:

$$
E = mc^2
$$

## Regular Code Block

```python
import numpy as np
print("Hello")
```

## Mixed Content

Here's inline math $\alpha + \beta = \gamma$ followed by a code cell:

```{code-cell} javascript
const x = 42;
console.log(x);
```

And then more math:

$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$