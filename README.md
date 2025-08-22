# myst-markdown-tree-sitter.nvim

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
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  requires = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

### Testing from a Specific Branch

To test unreleased changes from a specific branch (useful for testing fixes before they're merged):

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  branch = 'branch-name',  -- Replace with the actual branch name
  requires = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

#### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  branch = 'branch-name',  -- Replace with the actual branch name
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

#### Testing Local Changes

For testing local modifications:

```lua
{
  dir = '/path/to/local/myst-markdown-tree-sitter.nvim',
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

**Note:** After changing branches or updating the plugin, you may need to:
1. Restart Neovim
2. Run `:PackerSync` (for packer) or `:Lazy sync` (for lazy.nvim)
3. Run `:TSUpdate` to ensure tree-sitter parsers are up to date

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
- `:MystRefresh` - Force refresh MyST highlighting for the current buffer

These commands are useful for debugging highlighting issues and testing MyST functionality. The `:MystRefresh` command is particularly helpful if syntax highlighting appears to be missing or incorrect.

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

The plugin works automatically without configuration:

```lua
require('myst-markdown').setup()
```

### Manual Commands

The plugin provides several commands for troubleshooting and manual control:

- `:MystEnable` - Force enable MyST highlighting for current buffer
- `:MystDisable` - Disable MyST highlighting (revert to markdown)
- `:MystRefresh` - Force refresh highlighting (useful if highlighting breaks)
- `:MystStatus` - Quick health check of MyST highlighting status
- `:MystDebug` - Detailed debugging information with diagnostic suggestions

### Troubleshooting

If MyST highlighting is not working:

1. Run `:MystStatus` for a quick health check
2. If file is not detected as MyST, try `:MystEnable`
3. If tree-sitter is not active, try `:MystRefresh`
4. For detailed diagnosis, run `:MystDebug`

## Testing

A sample MyST file is provided in `test/sample.md` for testing the plugin functionality.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
