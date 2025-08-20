local M = {}

-- Setup function for the MyST markdown plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Set up filetype detection
  M.setup_filetype_detection()
  
  -- Set up syntax highlighting for myst filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "myst",
    callback = function()
      -- Try to use tree-sitter if available
      local has_treesitter, ts_configs = pcall(require, "nvim-treesitter.configs")
      if has_treesitter then
        -- Ensure markdown parsers are available
        ts_configs.setup({
          ensure_installed = {"markdown", "markdown_inline"},
          highlight = {
            enable = true,
            -- Remove additional_vim_regex_highlighting to avoid conflicts
          },
        })
        
        -- Start tree-sitter highlighting with markdown parser
        local has_highlighter, _ = pcall(function()
          if vim.treesitter.start then
            vim.treesitter.start(0, "markdown")
          end
        end)
        
        if not has_highlighter then
          -- Fallback to vim syntax highlighting
          vim.cmd("setlocal syntax=markdown")
        end
      else
        -- Fallback to vim syntax highlighting if tree-sitter not available
        vim.cmd("setlocal syntax=markdown")
      end
      
      -- Set up minimal MyST-specific highlighting for code-cell directives only
      M.setup_myst_highlighting()
    end
  })
end

-- Setup filetype detection
function M.setup_filetype_detection()
  -- Primary detection on file read
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.md",
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
      
      for _, line in ipairs(lines) do
        -- Check specifically for code-cell directives
        if line:match("^```{code%-cell}") then
          vim.bo.filetype = "myst"
          return
        end
      end
    end,
  })

  -- Secondary detection to override markdown filetype if MyST content is detected
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
      
      for _, line in ipairs(lines) do
        -- Check specifically for code-cell directives
        if line:match("^```{code%-cell}") then
          vim.bo.filetype = "myst"
          return
        end
      end
    end,
  })
end

-- Setup minimal MyST-specific highlighting
function M.setup_myst_highlighting()
  -- Create a highlight group for MyST code-cell directives that matches tree-sitter query
  vim.api.nvim_set_hl(0, "@myst.code_cell.directive", { link = "Special" })
end

return M