# Mixed MyST and Markdown Test

This file tests that both MyST code-cells and regular markdown work together.

## Regular Python Code Block
```python
# This should get python syntax highlighting via standard markdown
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print("Regular markdown code block")
```

## MyST Python Code-Cell  
```{code-cell} python
# This should get python syntax highlighting via MyST injection
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print("MyST code-cell block")
```

## Regular JavaScript
```javascript
// Standard markdown JavaScript
const data = [1, 2, 3];
console.log(data);
```

## MyST JavaScript Code-Cell
```{code-cell} javascript
// MyST code-cell JavaScript  
const data = [1, 2, 3];
console.log(data);
```

## MyST Directive (should not get language injection)
```{note}
This is a MyST note directive.
It should not get any special language highlighting.
```

## MyST Role
Here's a MyST role: {doc}`some_document` - this should not interfere.