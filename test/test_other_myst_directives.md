# Test File with Non-Code-Cell MyST Directives

This file contains MyST directives other than {code-cell}.
With the surgical fix, this should remain as a markdown file.

```{note}
This is a note directive. With the surgical fix, this file should:
- Remain as markdown filetype (not detected as MyST)
- Keep normal markdown highlighting for this directive
- Not be affected by any MyST highlighting overrides
```

```{warning}
This is a warning directive that should also work normally.
```

```{admonition} Custom Title
Custom admonition that should work with markdown highlighting.
```

## Regular Markdown Features

These should work normally:

**Bold text** and *italic text*

- List item 1
- List item 2

> Blockquote

```python
# Regular markdown code block
def hello():
    print("Hello, World!")
```

This demonstrates that the surgical fix correctly preserves normal markdown
functionality for files that don't contain {code-cell} directives.