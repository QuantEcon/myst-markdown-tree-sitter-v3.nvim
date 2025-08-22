-- Filetype detection for MyST markdown files
-- Auto-detect MyST markdown files based on code-cell directives

-- Primary detection on file read
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
    local is_myst = false
    
    for _, line in ipairs(lines) do
      -- Only detect as MyST if file contains code-cell directives
      -- This focuses support specifically on code-cell directives as requested
      if line:match("^```{code%-cell}") then       -- Code-cell directive only
        is_myst = true
        break
      end
    end
    
    if is_myst then
      vim.bo.filetype = "myst"
    end
  end,
})

-- Secondary detection to override markdown filetype if MyST content is detected
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
    
    for _, line in ipairs(lines) do
      -- Only detect as MyST if file contains code-cell directives
      -- This focuses support specifically on code-cell directives as requested
      if line:match("^```{code%-cell}") then       -- Code-cell directive only
        vim.bo.filetype = "myst"
        -- Simple refresh without complex timing
        vim.defer_fn(function()
          local ok, myst = pcall(require, 'myst-markdown')
          if ok and myst.refresh_highlighting then
            myst.refresh_highlighting()
          end
        end, 50)
        break
      end
    end
  end,
})