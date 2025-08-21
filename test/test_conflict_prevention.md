# MyST Highlighting Conflict Prevention Test

This file tests the fix for intermittent MyST highlighting by ensuring MyST patterns are properly excluded from standard markdown highlighting.

## Standard Markdown Heading (should highlight normally)

This is a regular heading that should get standard markdown highlighting.

```python
# Regular Python code block (should highlight normally)
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df)
```

## MyST Code-Cell Tests (should have MyST-specific highlighting)

```{code-cell} python
# This should get MyST code-cell directive highlighting
# The {code-cell} part should be highlighted as @myst.code_cell.directive
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print("MyST code-cell")
```

```{code-cell} javascript
// Another MyST code-cell with different language
// The {code-cell} should still be highlighted as @myst.code_cell.directive
const data = [1, 2, 3];
console.log(data);
```

## MyST Directive Tests (should have MyST-specific highlighting)

```{note}
This is a MyST note directive.
The {note} part should be highlighted as @myst.directive (not @myst.code_cell.directive).
```

```{warning}
This is a MyST warning directive.
Should be highlighted as @myst.directive.
```

## MyST Role Tests (should have MyST-specific highlighting)

Here are some MyST roles that should be highlighted:
- {doc}`some_document` should be highlighted as @myst.role
- {ref}`some_reference` should be highlighted as @myst.role  
- {numref}`figure_1` should be highlighted as @myst.role

## Mixed Content (edge case testing)

### Heading with MyST-like content but not a directive
# This {is-not-a-directive} should get normal heading highlighting

### Inline code that looks like MyST but isn't
`{not-a-role}` should get normal inline code highlighting

### Actual MyST roles in text
Use {doc}`installation` to see the installation guide.
Reference {eq}`equation1` for the mathematical details.

## Expected Behavior

With the conflict prevention fix:

1. **Standard markdown** elements (headings, code blocks, emphasis) should work normally when they don't contain MyST patterns
2. **MyST code-cell directives** should be highlighted with @myst.code_cell.directive 
3. **Other MyST directives** should be highlighted with @myst.directive
4. **MyST roles** like {doc}`target` should be highlighted with @myst.role
5. **No conflicts** should occur where standard markdown highlighting interferes with MyST highlighting
6. **Intermittent highlighting issues** should be resolved by the predicate-based exclusions