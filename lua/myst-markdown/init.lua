local M = {}

-- Setup function for the MyST markdown plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Set up filetype detection
  M.setup_filetype_detection()
  
  -- Set up manual commands
  M.setup_commands()
  
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
        
        -- Configure parser for myst filetype to use markdown parser
        local parsers = require("nvim-treesitter.parsers")
        -- Ensure filetype_to_parsername table exists before assigning
        if not parsers.filetype_to_parsername then
          parsers.filetype_to_parsername = {}
        end
        parsers.filetype_to_parsername.myst = "markdown"
        
        -- Start tree-sitter highlighting
        local has_highlighter, _ = pcall(function()
          if vim.treesitter.start then
            -- Start with markdown parser for the myst filetype
            -- Tree-sitter will look for myst queries because of the filetype
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
        -- Check for various MyST directives
        if line:match("^```{code%-cell}") or       -- Code-cell directive
           line:match("^```{[%w%-_]+}") or         -- Other MyST directives like {raw}, {note}, etc.
           line:match("^{[%w%-_]+}") then          -- Standalone MyST directives
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
        -- Check for various MyST directives
        if line:match("^```{code%-cell}") or       -- Code-cell directive
           line:match("^```{[%w%-_]+}") or         -- Other MyST directives like {raw}, {note}, etc.
           line:match("^{[%w%-_]+}") then          -- Standalone MyST directives
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

-- Manual command to enable MyST highlighting for current buffer
function M.enable_myst()
  vim.bo.filetype = "myst"
  print("MyST highlighting enabled for current buffer")
end

-- Manual command to disable MyST highlighting for current buffer
function M.disable_myst()
  vim.bo.filetype = "markdown"
  print("MyST highlighting disabled for current buffer (reverted to markdown)")
end

-- Debug function to show current MyST state
function M.debug_myst()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local has_treesitter = pcall(require, "nvim-treesitter.configs")
  local parser_info = "not available"
  
  if has_treesitter then
    local parsers = require("nvim-treesitter.parsers")
    local lang = parsers.get_buf_lang(buf)
    parser_info = lang or "no parser found"
  end
  
  print("=== MyST Debug Information ===")
  print("Current filetype: " .. filetype)
  print("Tree-sitter available: " .. tostring(has_treesitter))
  print("Active parser: " .. parser_info)
  
  -- Check if myst queries exist
  local myst_highlights = vim.treesitter.query.get("markdown", "highlights")
  local myst_injections = vim.treesitter.query.get("markdown", "injections")
  print("Myst highlight queries loaded: " .. tostring(myst_highlights ~= nil))
  print("Myst injection queries loaded: " .. tostring(myst_injections ~= nil))
  
  -- Check first few lines for MyST patterns
  local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
  local has_myst_patterns = false
  for i, line in ipairs(lines) do
    if line:match("^```{code%-cell}") or line:match("^```{[%w%-_]+}") then
      print("MyST pattern found on line " .. i .. ": " .. line)
      has_myst_patterns = true
    end
  end
  if not has_myst_patterns then
    print("No MyST patterns found in first 10 lines")
  end
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command('MystEnable', function()
    M.enable_myst()
  end, { desc = 'Enable MyST highlighting for current buffer' })
  
  vim.api.nvim_create_user_command('MystDisable', function()
    M.disable_myst()
  end, { desc = 'Disable MyST highlighting for current buffer' })
  
  vim.api.nvim_create_user_command('MystDebug', function()
    M.debug_myst()
  end, { desc = 'Show MyST debugging information' })
end

return M