# Test Cases for Code Highlighting

## Regular Markdown Code Block (should work)
```python
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print(df)
```

## MyST Code-Cell with Python (main issue)
```{code-cell} python
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print(df)
```

## MyST Code-Cell with JavaScript
```{code-cell} javascript
const data = [1, 2, 3];
console.log(data.map(x => x * 2));
```

## MyST Code-Cell without Language (should NOT get syntax highlighting)
```{code-cell}
import pandas as pd
print("This should NOT be highlighted as any language")
```

## Test other languages
```{code-cell} bash
echo "Testing bash highlighting"
ls -la
```

```{code-cell} r
data <- c(1, 2, 3, 4, 5)
mean(data)
```