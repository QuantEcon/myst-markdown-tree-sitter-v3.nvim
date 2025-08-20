-- myst-markdown-tree-sitter-v3.nvim
-- MyST Markdown plugin for neovim with tree-sitter support

if vim.g.loaded_myst_markdown then
  return
end
vim.g.loaded_myst_markdown = 1

-- Initialize the plugin
require('myst-markdown').setup()