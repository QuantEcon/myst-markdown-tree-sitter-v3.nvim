-- MyST filetype settings
-- This file is loaded when filetype is set to 'myst'

-- Inherit from markdown settings
vim.cmd('runtime! ftplugin/markdown.vim')

-- MyST-specific settings
vim.bo.commentstring = '<!-- %s -->'
vim.bo.comments = 'b:<!--,e:-->'

-- Enable spell checking for MyST files
vim.wo.spell = true

-- Set up folding for MyST directives
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

-- Additional MyST-specific keymaps could be added here