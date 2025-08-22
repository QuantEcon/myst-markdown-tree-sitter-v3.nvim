# Test File for Overly Broad Highlighting Issue

This file demonstrates the problem with PR #53 where highlighting is disabled too broadly.

## Regular Markdown Code Block
This should work fine:

```python
def hello():
    print("Hello, World!")
```

## MyST Code-Cell Directive 
This is what PR #53 was trying to fix:

```{code-cell} python
# This should have MyST highlighting
import numpy as np
data = np.array([1, 2, 3])
print(data.mean())
```

## Other MyST Directives
These are getting broken by the current fix:

```{note}
This is a note directive that should have some highlighting
but is getting disabled by the overly broad markdown highlights.scm
```

```{warning}
This warning directive is also affected by the highlighting disable
```

```{admonition} Custom Title
Custom admonition that should work but doesn't
```

## Regular Markdown Features
These should continue to work:

**Bold text** and *italic text*

- List item 1  
- List item 2

> Blockquote

## Expected Behavior

1. Regular markdown code blocks: Normal markdown highlighting
2. `{code-cell}` directives: MyST highlighting (no markdown interference)  
3. Other MyST directives (`{note}`, `{warning}`, etc.): Should NOT be disabled
4. Regular markdown features: Normal markdown highlighting

## Current Problem

The `queries/markdown/highlights.scm` file disables highlighting for ALL fenced code blocks, 
but MyST only provides highlighting for `{code-cell}` directives, leaving other directives without highlighting.