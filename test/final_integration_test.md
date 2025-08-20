# Test Both LaTeX and Multiple Code-Cells

This file tests that both LaTeX highlighting and multiple code-cell highlighting work correctly after the fix.

## LaTeX Math Testing

Inline math: $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$ should be highlighted.

Block math:
$$
\int_0^1 f(x) dx = F(1) - F(0)
$$

## Multiple Code-Cell Testing

First code-cell (Python):
```{code-cell} python
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print("First code-cell")
```

Second code-cell (JavaScript):
```{code-cell} javascript
const data = [1, 2, 3];
console.log("Second code-cell");
```

Third code-cell (Python, no explicit language):
```{code-cell}
# Should default to Python
import numpy as np
print("Third code-cell")
```

## Mixed Content

More inline math $\alpha + \beta = \gamma$ between code-cells.

Fourth code-cell (Bash):
```{code-cell} bash
echo "Fourth code-cell"
ls -la
```

Final math block:
$$
E = mc^2
$$

## Expected Results

- ✅ All four code-cells should have proper syntax highlighting
- ✅ All LaTeX math (inline and block) should have proper highlighting
- ✅ No interference between LaTeX and code-cell patterns