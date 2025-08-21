local M = {}

-- Setup function for the MyST markdown plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Setup injection queries
  M.setup_injection_queries()
  
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

-- Setup injection queries
function M.setup_injection_queries()
  -- The injection queries are static files in the queries/ directory
  -- that are committed to the repository and provide language highlighting
  -- for code-cell blocks.
end

-- Setup filetype detection
function M.setup_filetype_detection()
  -- Note: Primary filetype detection is handled by ftdetect/myst.lua
  -- This function only sets up the secondary detection for FileType events
  
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
          -- Force refresh highlighting after filetype change
          vim.defer_fn(function()
            M.refresh_highlighting()
          end, 50) -- Increased delay for more reliable refresh
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

-- Force refresh tree-sitter highlighting for current buffer
function M.refresh_highlighting()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  
  -- Validate buffer is still valid
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  
  -- Try to refresh tree-sitter highlighting using proper nvim-treesitter APIs
  local has_treesitter = pcall(require, "nvim-treesitter.configs")
  if has_treesitter then
    local success = false
    
    -- Method 1: Use nvim-treesitter highlight module (preferred)
    pcall(function()
      local ts_highlight = require("nvim-treesitter.highlight")
      
      -- Detach existing highlighter
      if ts_highlight.active[buf] then
        ts_highlight.detach(buf)
      end
      
      -- Determine parser language
      local parser_lang = (filetype == "myst") and "markdown" or filetype
      
      -- Small delay to ensure clean detach before reattach
      vim.defer_fn(function()
        -- Check buffer is still valid before reattaching
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(function()
            -- Reattach with proper language
            ts_highlight.attach(buf, parser_lang)
          end)
        end
      end, 50)
      
      success = true
    end)
    
    -- Method 2: Fallback to vim.treesitter API if nvim-treesitter method fails
    if not success then
      pcall(function()
        if vim.treesitter.stop then
          vim.treesitter.stop(buf)
        end
        
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(buf) then
            local parser_lang = (filetype == "myst") and "markdown" or filetype
            pcall(function()
              if vim.treesitter.start then
                vim.treesitter.start(buf, parser_lang)
              end
            end)
          end
        end, 50)
      end)
    end
  else
    -- Fallback to vim syntax refresh
    pcall(function()
      vim.cmd("syntax sync fromstart")
    end)
  end
end

-- Manual command to enable MyST highlighting for current buffer
function M.enable_myst()
  local old_filetype = vim.bo.filetype
  vim.bo.filetype = "myst"
  
  -- Only refresh if filetype actually changed
  if old_filetype ~= "myst" then
    -- Force refresh tree-sitter highlighting with a more aggressive approach
    vim.defer_fn(function()
      M.refresh_highlighting()
    end, 10)
  end
  
  print("MyST highlighting enabled for current buffer")
end

-- Manual command to disable MyST highlighting for current buffer
function M.disable_myst()
  local old_filetype = vim.bo.filetype
  vim.bo.filetype = "markdown"
  
  -- Only refresh if filetype actually changed
  if old_filetype ~= "markdown" then
    -- Force refresh tree-sitter highlighting with a more aggressive approach
    vim.defer_fn(function()
      M.refresh_highlighting()
    end, 10)
  end
  
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
  
  -- Check tree-sitter highlighting status with more detail
  local ts_highlighter = nil
  local highlighter_info = "not active"
  if has_treesitter then
    pcall(function()
      local ts_highlight = require("nvim-treesitter.highlight")
      ts_highlighter = ts_highlight.active[buf]
      if ts_highlighter then
        highlighter_info = "active"
        -- Try to get more info about the highlighter
        if ts_highlighter.tree then
          highlighter_info = highlighter_info .. " (has tree)"
        end
        if ts_highlighter.parser then
          highlighter_info = highlighter_info .. " (has parser)"
        end
      end
    end)
  end
  print("Tree-sitter highlighter: " .. highlighter_info)
  
  -- Check if tree-sitter is properly configured for myst filetype
  if has_treesitter then
    local parsers = require("nvim-treesitter.parsers")
    local parser_config = parsers.get_parser_configs()
    print("Parser configs available: " .. table.concat(vim.tbl_keys(parser_config), ", "))
    
    -- Check filetype mapping
    if parsers.filetype_to_parsername then
      local myst_parser = parsers.filetype_to_parsername.myst
      print("MyST filetype mapped to parser: " .. tostring(myst_parser))
    end
  end
  
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
  
  print("Buffer name: " .. (vim.api.nvim_buf_get_name(buf) or "unnamed"))
  print("=== End Debug Info ===")
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
  
  vim.api.nvim_create_user_command('MystRefresh', function()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.bo.filetype
    
    print("MyST highlighting refresh initiated...")
    print("Current filetype: " .. filetype)
    
    M.refresh_highlighting()
    
    -- Provide feedback after a delay to allow refresh to complete
    vim.defer_fn(function()
      local has_treesitter = pcall(require, "nvim-treesitter.configs")
      if has_treesitter then
        local ts_highlight = require("nvim-treesitter.highlight")
        local highlighter_active = ts_highlight.active[buf] ~= nil
        print("MyST highlighting refreshed - Tree-sitter active: " .. tostring(highlighter_active))
      else
        print("MyST highlighting refreshed - Using fallback syntax highlighting")
      end
    end, 100)
  end, { desc = 'Force refresh MyST highlighting for current buffer' })
end

return M