# Test File for Highlighting Fix

This file tests the fix for intermittent syntax highlighting issues.

## Code Cell Test

```{code-cell} python
import numpy as np
import matplotlib.pyplot as plt

# This should be highlighted as Python code
x = np.linspace(0, 2*np.pi, 100)
y = np.sin(x)

plt.plot(x, y)
plt.title('Sine Wave')
plt.show()
```

## Regular Markdown Code Block

```python
# This should also be highlighted as Python
print("Hello, World!")
```

## Another Code Cell

```{code-cell} javascript
// This should be highlighted as JavaScript
const greeting = "Hello from JavaScript!";
console.log(greeting);

function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

console.log(fibonacci(10));
```

## MyST Directive

```{note}
This is a MyST note directive that should trigger MyST filetype detection.
```

## Text Content

Regular markdown text should still work normally with proper highlighting.