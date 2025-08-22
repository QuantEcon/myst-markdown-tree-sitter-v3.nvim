# Test Code-Cell Language Behavior After Fix

This file tests the fix for Issue #68 - removing default Python highlighting for `{code-cell}` without language parameter.

## Expected Behavior After Fix

### This should NOT get syntax highlighting (no language specified):
```{code-cell}
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print("This should have NO syntax highlighting")
```

### This SHOULD get Python syntax highlighting (explicit language):
```{code-cell} python
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print("This should have Python syntax highlighting")
```

### This SHOULD get JavaScript syntax highlighting (explicit language):
```{code-cell} javascript
const data = [1, 2, 3];
console.log(data.map(x => x * 2));
```

### This SHOULD get Bash syntax highlighting (explicit language):
```{code-cell} bash
echo "This should have bash syntax highlighting"
ls -la
```

## Regular Markdown Code Blocks (should still work):

### Python:
```python
import pandas as pd
print("Regular python block")
```

### JavaScript:
```javascript
console.log("Regular JavaScript block");
```

The fix ensures that only explicit language specifications receive syntax highlighting, preventing the inappropriate default Python highlighting for languageless code-cells.