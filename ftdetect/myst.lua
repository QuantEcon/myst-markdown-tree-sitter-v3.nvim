-- Filetype detection for MyST markdown files
-- Auto-detect MyST markdown files based on code-cell directives

-- Primary detection on file read
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
    local is_myst = false
    
    for _, line in ipairs(lines) do
      -- Check for various MyST directives
      if line:match("^```{code%-cell}") or       -- Code-cell directive
         line:match("^```{[%w%-_]+}") or         -- Other MyST directives like {raw}, {note}, etc.
         line:match("^{[%w%-_]+}") then          -- Standalone MyST directives
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
      -- Check for various MyST directives
      if line:match("^```{code%-cell}") or       -- Code-cell directive
         line:match("^```{[%w%-_]+}") or         -- Other MyST directives like {raw}, {note}, etc.
         line:match("^{[%w%-_]+}") then          -- Standalone MyST directives
        vim.bo.filetype = "myst"
        -- Trigger highlighting refresh after longer delay to ensure proper initialization order
        vim.defer_fn(function()
          -- Try to call refresh function if plugin is loaded
          local ok, myst = pcall(require, 'myst-markdown')
          if ok and myst.refresh_highlighting then
            myst.refresh_highlighting()
          end
        end, 150) -- Longer delay to ensure MyST setup completes after markdown
        break
      end
    end
  end,
})