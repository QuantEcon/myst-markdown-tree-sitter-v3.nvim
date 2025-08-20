# MyST Markdown Tree-sitter Plugin for Neovim

## Developer Guide

This guide explains how to contribute to and modify the MyST markdown plugin for Neovim.

### Architecture

The plugin is structured as follows:

```
├── ftdetect/myst.lua          # Filetype detection logic
├── ftplugin/myst.lua          # Filetype-specific settings
├── lua/myst-markdown/init.lua # Main plugin logic
├── plugin/myst-markdown.lua   # Plugin initialization
├── queries/myst/highlights.scm # Tree-sitter highlight queries
└── test/                      # Test files and examples
```

### Key Components

#### 1. Filetype Detection (`ftdetect/myst.lua`)

Automatically detects MyST files by scanning for MyST-specific patterns:
- Code-cell directives: `{code-cell}`
- MyST roles: `{role}`content``
- Block directives: `:::{directive}`
- YAML frontmatter

#### 2. Main Module (`lua/myst-markdown/init.lua`)

Provides:
- Plugin setup and configuration
- Tree-sitter integration with markdown parser
- Custom highlighting for MyST elements
- Extmark-based syntax highlighting

#### 3. Tree-sitter Queries (`queries/myst/highlights.scm`)

Defines highlighting patterns for:
- MyST directives in fenced code blocks
- YAML frontmatter
- Code-cell blocks

### Extending the Plugin

#### Adding New MyST Elements

1. **Update the detection pattern** in `ftdetect/myst.lua`
2. **Add highlighting logic** in `lua/myst-markdown/init.lua`
3. **Create tree-sitter queries** in `queries/myst/highlights.scm`
4. **Add highlight groups** as needed

#### Example: Adding Support for MyST Admonitions

```lua
-- In highlight_myst_elements() function
local admonition = line:match("^:::{(note|warning|tip|caution|important)}")
if admonition then
  vim.api.nvim_buf_set_extmark(0, ns_id, i-1, 0, {
    end_col = #line,
    hl_group = "MystAdmonition"
  })
end
```

### Testing

#### Manual Testing

1. Open `test/sample.md` in Neovim with the plugin installed
2. Check that filetype is detected as `myst`
3. Verify that MyST elements are highlighted appropriately

#### Automated Testing

The `test/test_basic.lua` script provides basic validation of plugin structure.

### Development Workflow

1. Make changes to plugin files
2. Test with sample MyST files
3. Verify compatibility with various Neovim configurations
4. Update documentation as needed

### Troubleshooting

#### Tree-sitter Issues

- Ensure `markdown` and `markdown_inline` parsers are installed
- Check `:TSInstall markdown markdown_inline`
- Verify tree-sitter is working: `:checkhealth nvim-treesitter`

#### Highlighting Not Working

- Check if filetype is detected: `:set filetype?`
- Verify plugin is loaded: `:lua print(vim.g.loaded_myst_markdown)`
- Check for errors: `:messages`

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Update documentation
5. Submit a pull request

### Plugin API

#### Setup Options

```lua
require('myst-markdown').setup({
  -- Future configuration options will be added here
})
```

#### Highlight Groups

- `MystDirective` - MyST directive blocks
- `MystDirectiveName` - Directive names
- `MystDirectiveArg` - Directive arguments
- `MystRole` - MyST roles
- `MystCodeCell` - Code-cell directives
- `MystBlockDirective` - Block directives (:::)