# Final Verification: MyST Core Functionality Test

This file verifies that removing MystEnable/MystDisable commands doesn't impact core MyST functionality.

## MyST Code-Cell Directives (Primary Feature)

These should be automatically detected and highlighted:

```{code-cell} python
# This should have Python syntax highlighting
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 2*np.pi, 100)
y = np.sin(x)

plt.plot(x, y)
plt.title("Sine Wave")
plt.show()
```

```{code-cell} javascript
// This should have JavaScript syntax highlighting
const data = [1, 2, 3, 4, 5];
const doubled = data.map(x => x * 2);
console.log("Doubled:", doubled);
```

```{code-cell}
# Default language should be Python
def hello_world():
    return "Hello from MyST code-cell!"

print(hello_world())
```

## Other MyST Directives (For Detection)

These help with filetype detection but don't have special highlighting:

```{note}
This is a MyST note directive. It should help the plugin detect this as a MyST file.
```

```{warning}
This is a warning directive - another MyST-specific element.
```

## Regular Markdown (Should Still Work)

```python
# Regular markdown code block
def regular_function():
    return "This should also have Python highlighting"
```

## Expected Behavior

1. **Automatic Detection**: File should be detected as MyST based on {code-cell} and other directives
2. **Syntax Highlighting**: Code-cell blocks should have proper language-specific highlighting
3. **No Manual Commands Needed**: Everything should work without :MystEnable/:MystDisable
4. **Debug Commands Available**: :MystStatus and :MystDebug should still work for troubleshooting

## Test Commands

If you open this file in Neovim with the plugin installed:

1. `:MystStatus` - Should show file detected as MyST with highlighting active
2. `:MystDebug` - Should show detailed information about MyST detection and tree-sitter state
3. `:MystEnable` and `:MystDisable` - Should no longer exist (commands removed)