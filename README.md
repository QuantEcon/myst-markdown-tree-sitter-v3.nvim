# myst-markdown-tree-sitter-v3.nvim

A MyST Markdown plugin for neovim with tree-sitter backend support.

This plugin provides syntax highlighting and filetype detection for [MyST (Markedly Structured Text)](https://mystmd.org/) markdown files in Neovim. It extends the standard markdown highlighting with MyST-specific features like directives and roles.

## Features

- **Automatic filetype detection** for MyST markdown files
- **Code-cell directive highlighting** with language-specific syntax highlighting
- **MyST directive and role highlighting** 
- **Tree-sitter integration** for robust parsing
- **Markdown compatibility** - works alongside existing markdown features

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'QuantEcon/myst-markdown-tree-sitter-v3.nvim',
  requires = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'QuantEcon/myst-markdown-tree-sitter-v3.nvim',
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

## Requirements

- Neovim >= 0.8.0
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Tree-sitter markdown parser (`TSInstall markdown markdown_inline`)

## Usage

The plugin automatically detects MyST markdown files based on content patterns and applies appropriate syntax highlighting.

### Manual Commands

For debugging and manual control, the plugin provides these commands:

- `:MystEnable` - Enable MyST highlighting for the current buffer
- `:MystDisable` - Disable MyST highlighting for the current buffer (reverts to markdown)
- `:MystDebug` - Show debugging information about MyST state and tree-sitter queries

These commands are useful for debugging highlighting issues and testing MyST functionality.

### Code Cells

MyST code-cell directives like this:

```markdown
```{code-cell} python
import pandas as pd
df = pd.DataFrame()
print(df)
```
```

Will be highlighted with language-specific syntax highlighting, similar to standard markdown code blocks.

**Code-cell blocks without explicit language will default to Python highlighting:**

```markdown
```{code-cell}
import pandas as pd  # This gets Python syntax highlighting
print("Default language is Python")
```
```

**Supported Languages in Code Cells:**
- Python (`python`)
- JavaScript (`javascript`) 
- TypeScript (`typescript`)
- Bash (`bash`)
- R (`r`)
- Julia (`julia`)
- C (`c`)
- C++ (`cpp`)
- Rust (`rust`)
- Go (`go`)

For other languages, ensure you have the corresponding tree-sitter parser installed with `:TSInstall <language>`.

### MyST Directives and Roles

The plugin also highlights MyST-specific syntax:

- Directives: `{note}`, `{warning}`, etc.
- Roles: `{doc}`, `{ref}`, etc.
- Block directives: `:::{directive_name}`

## Configuration

The plugin can be configured with various options:

```lua
require('myst-markdown').setup({
  -- Note: Configuration options are currently limited to prevent plugin update issues
  -- The plugin uses static injection queries that default to Python for code-cell blocks
})
```

### Configuration Options

**Note**: As of the current version, configuration options are limited to prevent plugin update conflicts. The `default_code_cell_language` option is not currently functional.

- `default_code_cell_language` (string, **currently non-functional**) - This option was temporarily disabled to fix plugin update issues where dynamic query generation caused local git changes. The plugin now uses static injection queries that default to Python for `{code-cell}` blocks without explicit language specification.

**Current behavior:**
```markdown
```{code-cell}
# This code will be highlighted with Python syntax (hardcoded default)
print("Hello world")
```
```

**Example setup (configuration currently ignored):**
```lua
require('myst-markdown').setup({
  -- This setting currently has no effect, but the setup call is still required
})
```

**Future plans**: We plan to restore configurable default languages in a future update using a method that doesn't cause plugin update conflicts.

## Testing

A sample MyST file is provided in `test/sample.md` for testing the plugin functionality.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
