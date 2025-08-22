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
      -- Configure parser for myst filetype to use markdown parser
      local has_treesitter, _ = pcall(require, "nvim-treesitter.configs")
      if has_treesitter then
        local parsers = require("nvim-treesitter.parsers")
        if not parsers.filetype_to_parsername then
          parsers.filetype_to_parsername = {}
        end
        parsers.filetype_to_parsername.myst = "markdown"
        
        -- Start tree-sitter highlighting with markdown parser
        if vim.treesitter.start then
          vim.treesitter.start(0, "markdown")
        end
      else
        -- Fallback to vim syntax highlighting if tree-sitter not available
        vim.cmd("setlocal syntax=markdown")
      end
      
      -- Set up MyST highlighting
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
          -- Simple refresh
          vim.defer_fn(function()
            M.refresh_highlighting()
          end, 50)
          return
        end
      end
    end,
  })
end

-- Setup minimal MyST-specific highlighting
function M.setup_myst_highlighting()
  -- Create highlight groups for MyST directives
  -- Note: Priority parameter removed for compatibility with older Neovim versions
  vim.api.nvim_set_hl(0, "@myst.code_cell.directive", { 
    link = "Special"
  })
  
  -- Additional MyST-specific highlights
  vim.api.nvim_set_hl(0, "@myst.directive", { 
    link = "Special"
  })
end

-- Simple refresh highlighting function
function M.refresh_highlighting()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  
  if not vim.api.nvim_buf_is_valid(buf) then
    return false, "Buffer is not valid"
  end
  
  -- Try to restart tree-sitter highlighting
  local has_treesitter = pcall(require, "nvim-treesitter.configs")
  if has_treesitter then
    local parser_lang = (filetype == "myst") and "markdown" or filetype
    
    -- Set up parser mapping for myst filetype (crucial step that was missing)
    if filetype == "myst" then
      local parsers = require("nvim-treesitter.parsers")
      if not parsers.filetype_to_parsername then
        parsers.filetype_to_parsername = {}
      end
      parsers.filetype_to_parsername.myst = "markdown"
    end
    
    -- Try using nvim-treesitter's highlight module for proper management
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight then
      -- First detach any existing highlighter
      pcall(function()
        if ts_highlight.detach then
          ts_highlight.detach(buf)
        end
      end)
      
      -- Wait a moment for detach to complete
      vim.wait(100, function() return false end) -- Wait 100ms
      
      -- Attach with the correct parser language
      pcall(function()
        if ts_highlight.attach then
          ts_highlight.attach(buf, parser_lang)
        end
      end)
      
      -- Wait for attachment to complete
      vim.wait(100, function() return false end) -- Wait 100ms
      
    else
      -- Fallback to low-level API if nvim-treesitter.highlight not available
      pcall(function()
        if vim.treesitter.stop then
          vim.treesitter.stop(buf)
        end
        vim.wait(50, function() return false end) -- Wait 50ms
        if vim.treesitter.start then
          vim.treesitter.start(buf, parser_lang)
        end
        vim.wait(100, function() return false end) -- Wait 100ms
      end)
    end
    
    -- Refresh MyST highlighting
    M.setup_myst_highlighting()
    
    -- Validate that tree-sitter highlighting is now actually active
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight and ts_highlight.active and ts_highlight.active[buf] then
      return true, "Tree-sitter highlighting activated successfully"
    else
      return false, "Tree-sitter highlighting failed to activate"
    end
  else
    -- Fallback to vim syntax refresh
    pcall(function()
      vim.cmd("syntax sync fromstart")
    end)
    return true, "Using fallback syntax highlighting"
  end
end

-- Manual command to enable MyST highlighting for current buffer
function M.enable_myst()
  vim.bo.filetype = "myst"
  M.refresh_highlighting()
  print("MyST highlighting enabled for current buffer")
end

-- Manual command to disable MyST highlighting for current buffer
function M.disable_myst()
  vim.bo.filetype = "markdown"
  M.refresh_highlighting()
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
  local highlighter_errors = {}
  
  if has_treesitter then
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight then
      if ts_highlight.active then
        ts_highlighter = ts_highlight.active[buf]
        if ts_highlighter then
          highlighter_info = "active"
          -- Try to get more info about the highlighter
          if ts_highlighter.tree then
            highlighter_info = highlighter_info .. " (has tree)"
          else
            table.insert(highlighter_errors, "missing tree")
          end
          if ts_highlighter.parser then
            highlighter_info = highlighter_info .. " (has parser)"
          else
            table.insert(highlighter_errors, "missing parser")
          end
        else
          table.insert(highlighter_errors, "no highlighter instance for buffer")
        end
      else
        table.insert(highlighter_errors, "ts_highlight.active is nil")
      end
    else
      table.insert(highlighter_errors, "failed to load nvim-treesitter.highlight")
    end
  else
    table.insert(highlighter_errors, "nvim-treesitter not available")
  end
  
  print("Tree-sitter highlighter: " .. highlighter_info)
  if #highlighter_errors > 0 then
    print("Highlighter issues: " .. table.concat(highlighter_errors, ", "))
    
    -- Provide diagnostic suggestions
    print("\nDiagnostic suggestions:")
    if filetype == "myst" then
      print("  - Try :MystRefresh to force re-initialization")
      print("  - Try :MystDisable followed by :MystEnable")
    else
      print("  - File may not be detected as MyST. Try :MystEnable")
    end
    print("  - Ensure nvim-treesitter is properly installed")
    print("  - Ensure markdown parser is installed with :TSInstall markdown")
  end
  
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
  
  vim.api.nvim_create_user_command('MystStatus', function()
    M.status_myst()
  end, { desc = 'Show quick MyST status check' })
  
  vim.api.nvim_create_user_command('MystRefresh', function()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.bo.filetype
    print("MyST highlighting refresh initiated...")
    print("Current filetype: " .. filetype)
    
    local success, message = M.refresh_highlighting()
    
    if success then
      print("MyST highlighting refreshed successfully - " .. message)
    else
      print("MyST highlighting refresh failed - " .. (message or "unknown error"))
    end
    
    -- Report actual tree-sitter status after refresh attempt
    local has_treesitter = pcall(require, "nvim-treesitter.configs")
    if has_treesitter then
      local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
      if ts_highlight_ok and ts_highlight and ts_highlight.active and ts_highlight.active[buf] then
        print("Tree-sitter highlighter status: active")
      else
        print("Tree-sitter highlighter status: not active")
      end
    end
  end, { desc = 'Force refresh MyST highlighting for current buffer' })
end

-- Quick status check for MyST highlighting
function M.status_myst()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local has_treesitter = pcall(require, "nvim-treesitter.configs")
  
  print("=== MyST Status ===")
  print("Filetype: " .. filetype)
  
  if filetype == "myst" then
    print("✓ File detected as MyST")
  else
    print("✗ File not detected as MyST (use :MystEnable to force)")
  end
  
  if has_treesitter then
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight and ts_highlight.active and ts_highlight.active[buf] then
      print("✓ Tree-sitter highlighting active")
    else
      print("✗ Tree-sitter highlighting not active (use :MystRefresh)")
    end
  else
    print("✗ nvim-treesitter not available")
  end
  
  -- Check for MyST content
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local has_myst_content = false
  for _, line in ipairs(lines) do
    if line:match("^```{code%-cell}") or line:match("^```{[%w%-_]+}") then
      has_myst_content = true
      break
    end
  end
  
  if has_myst_content then
    print("✓ MyST content detected in buffer")
  else
    print("? No obvious MyST content found (check full file)")
  end
  
  print("==================")
end

return M