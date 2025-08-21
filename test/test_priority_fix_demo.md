# Tree-sitter Priority Fix Demo (Issue #46)

This file demonstrates the Tree-sitter priority-based fix for intermittent MyST highlighting.

## Regular Markdown Code Block

```python
# This should have normal Python highlighting
def hello_world():
    print("Hello, World!")
```

## MyST Code-Cell Directives with Priority 110

```{code-cell} python
# The {code-cell} directive should have priority 110 highlighting
# This ensures it overrides standard markdown highlighting
import numpy as np
data = np.array([1, 2, 3, 4, 5])
print(f"Mean: {data.mean()}")
```

```{code-cell} javascript
// Another {code-cell} directive with priority 110
const numbers = [1, 2, 3, 4, 5];
const mean = numbers.reduce((a, b) => a + b) / numbers.length;
console.log(`Mean: ${mean}`);
```

## Other MyST Directives with Priority 105

```{note}
This note directive should be highlighted with priority 105.
Priority 105 is high enough to override markdown but lower than code-cell.
```

```{warning}
This warning directive should also be highlighted with priority 105.
```

```{tip}
This tip directive demonstrates the general MyST directive pattern.
```

## Expected Behavior

With the Tree-sitter priority predicates:

1. **{code-cell} directives**: Highlighted with priority 110 (highest)
2. **Other MyST directives**: Highlighted with priority 105 (high)
3. **Standard markdown**: Uses default priority (lower)

The `#set! "priority"` predicates in the Tree-sitter queries ensure MyST elements are always rendered with correct highlighting, eliminating the intermittent highlighting issues.

## Benefits of This Approach

- **Simpler**: Uses Tree-sitter's built-in priority system
- **More reliable**: No complex timing or retry logic needed
- **Standard**: Follows Tree-sitter best practices for highlight precedence
- **Maintainable**: Clear, declarative syntax in query files