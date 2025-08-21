# Test MyST File for Highlighting Fix

This file tests the improved MyST highlighting refresh functionality.

## Regular Markdown Code Block
```python
# This should get basic python highlighting
print("Regular markdown code block")
```

## MyST Code-Cell (should trigger MyST filetype detection)
```{code-cell} python
# This should get enhanced MyST highlighting with code-cell directive highlighting
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3], 'y': [4, 5, 6]})
print(df)
```

## Another MyST Code-Cell
```{code-cell} javascript
// This should also get proper highlighting
const data = [1, 2, 3];
console.log(data.map(x => x * 2));
```

## Code-Cell without language (should default to python)
```{code-cell}
# Should be highlighted as Python
result = sum([1, 2, 3, 4, 5])
print(f"Result: {result}")
```

This file should:
1. Be detected as MyST filetype due to {code-cell} directives
2. Show proper syntax highlighting within code cells
3. Respond correctly to :MystRefresh, :MystEnable, :MystDisable commands
4. Provide detailed debug info with :MystDebug command