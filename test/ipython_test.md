# IPython Support Test

This file tests support for ipython and ipython3 as synonyms for python.

## MyST Code-Cell with ipython (should map to python highlighting)
```{code-cell} ipython
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3]})
print("IPython code-cell should be highlighted as Python")
```

## MyST Code-Cell with ipython3 (should map to python highlighting)
```{code-cell} ipython3
import numpy as np
arr = np.array([1, 2, 3, 4, 5])
print("IPython3 code-cell should be highlighted as Python")
```

## Regular Markdown Code Block with ipython (should map to python highlighting)
```ipython
# Regular ipython block
import matplotlib.pyplot as plt
plt.plot([1, 2, 3], [4, 5, 6])
print("Regular ipython block should be highlighted as Python")
```

## Regular Markdown Code Block with ipython3 (should map to python highlighting)
```ipython3
# Regular ipython3 block
def hello_world():
    print("Hello from ipython3!")
    
hello_world()
```

## Existing python blocks should continue to work
```{code-cell} python
# This should still work as before
import sys
print("Standard python code-cell")
```

```python
# Regular python markdown block
print("Standard python markdown block")
```