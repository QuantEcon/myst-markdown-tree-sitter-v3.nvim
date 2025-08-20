-- Filetype detection for MyST markdown files
-- Auto-detect MyST markdown files based on code-cell directives

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
    local is_myst = false
    
    for _, line in ipairs(lines) do
      -- Check specifically for code-cell directives
      if line:match("^```{code%-cell}") then
        is_myst = true
        break
      end
    end
    
    if is_myst then
      vim.bo.filetype = "myst"
    end
  end,
})