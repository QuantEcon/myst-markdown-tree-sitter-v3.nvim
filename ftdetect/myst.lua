-- Filetype detection for MyST markdown files
-- Auto-detect MyST markdown files based on content

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
    local is_myst = false
    
    for _, line in ipairs(lines) do
      -- Check for MyST-specific syntax patterns
      if line:match("^```{[%w%-_]+}") or    -- MyST directives like {code-cell}
         line:match("{[%w%-_]+}`[^`]*`") or -- MyST roles like {doc}`filename`
         line:match("^:::{[%w%-_]+}") or    -- MyST block directives
         line:match("^---$") then           -- YAML frontmatter (common in MyST)
        is_myst = true
        break
      end
    end
    
    if is_myst then
      vim.bo.filetype = "myst"
    end
  end,
})