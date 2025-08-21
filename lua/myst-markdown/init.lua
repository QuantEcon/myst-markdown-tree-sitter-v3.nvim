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
  
  -- Set up syntax highlighting for myst filetype with improved priority handling
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "myst",
    callback = function()
      -- Ensure MyST highlighting takes priority by deferring initialization
      -- This allows markdown tree-sitter to initialize first, then MyST overrides it
      vim.defer_fn(function()
        local buf = vim.api.nvim_get_current_buf()
        
        -- Validate buffer is still valid and filetype is still myst
        if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "myst" then
          return
        end
        
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
          
          -- Force refresh highlighting to ensure MyST queries are used
          M.refresh_highlighting()
        else
          -- Fallback to vim syntax highlighting if tree-sitter not available
          vim.cmd("setlocal syntax=markdown")
        end
        
        -- Set up minimal MyST-specific highlighting for code-cell directives only
        M.setup_myst_highlighting()
      end, 100) -- Longer delay to ensure markdown highlighting is established first
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
          -- Force refresh highlighting after filetype change with improved timing
          vim.defer_fn(function()
            M.refresh_highlighting()
          end, 150) -- Increased delay to ensure proper initialization order
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

-- Force refresh tree-sitter highlighting for current buffer with improved reliability
function M.refresh_highlighting()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  
  -- Validate buffer is still valid
  if not vim.api.nvim_buf_is_valid(buf) then
    return false, "Buffer is not valid"
  end
  
  -- Try to refresh tree-sitter highlighting using proper nvim-treesitter APIs
  local has_treesitter = pcall(require, "nvim-treesitter.configs")
  if has_treesitter then
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight then
      
      -- Determine parser language - MyST uses markdown parser
      local parser_lang = (filetype == "myst") and "markdown" or filetype
      
      -- Enhanced detach/attach with retry logic and validation
      local function attempt_refresh(retry_count)
        retry_count = retry_count or 0
        
        -- Detach existing highlighter if present
        if ts_highlight.active and ts_highlight.active[buf] then
          local detach_ok = pcall(function()
            ts_highlight.detach(buf)
          end)
          if not detach_ok and retry_count < 2 then
            -- Retry detach after a short delay
            vim.defer_fn(function()
              attempt_refresh(retry_count + 1)
            end, 50)
            return
          end
        end
        
        -- Wait for detach to complete before attempting attach
        vim.defer_fn(function()
          -- Validate buffer is still valid after delay
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          
          -- Attempt to attach highlighter
          local attach_ok = pcall(function()
            ts_highlight.attach(buf, parser_lang)
          end)
          
          -- Verify that highlighting actually became active
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(buf) then
              local is_active = ts_highlight.active and ts_highlight.active[buf] ~= nil
              
              -- If attach failed or highlighting not active, try alternative methods
              if not attach_ok or not is_active then
                if retry_count < 2 then
                  -- Retry with alternative approach
                  pcall(function()
                    if vim.treesitter.stop then
                      vim.treesitter.stop(buf)
                    end
                    -- Add small delay before starting
                    vim.defer_fn(function()
                      if vim.treesitter.start and vim.api.nvim_buf_is_valid(buf) then
                        vim.treesitter.start(buf, parser_lang)
                      end
                    end, 25)
                  end)
                  
                  -- Try full refresh if still failing
                  if retry_count == 1 then
                    vim.defer_fn(function()
                      attempt_refresh(retry_count + 1)
                    end, 100)
                  end
                elseif filetype == "myst" then
                  -- Last resort: force buffer refresh for MyST files
                  pcall(function()
                    vim.cmd("silent! edit!")
                  end)
                end
              end
            end
          end, 50) -- Give time for attach to take effect
        end, 50) -- Increased delay for reliable detach/attach cycle
      end
      
      -- Start the refresh process
      attempt_refresh(0)
      
      return true, "Tree-sitter highlighting refresh initiated with validation"
    else
      return false, "nvim-treesitter.highlight module not available"
    end
  else
    -- Fallback to vim syntax refresh
    local syntax_ok = pcall(function()
      vim.cmd("syntax sync fromstart")
    end)
    if syntax_ok then
      return true, "Using fallback syntax highlighting"
    else
      return false, "All highlighting methods failed"
    end
  end
end

-- Manual command to enable MyST highlighting for current buffer
function M.enable_myst()
  local old_filetype = vim.bo.filetype
  vim.bo.filetype = "myst"
  
  -- Only refresh if filetype actually changed
  if old_filetype ~= "myst" then
    -- Force refresh tree-sitter highlighting
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
    -- Force refresh tree-sitter highlighting
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
    
    print("MyST highlighting refresh initiated with enhanced reliability...")
    print("Current filetype: " .. filetype)
    
    local success, message = M.refresh_highlighting()
    
    if success then
      print("MyST highlighting refresh process started - " .. message)
      
      -- Provide multiple status checks to track the refresh progress
      local check_count = 0
      local function check_status()
        check_count = check_count + 1
        
        if not vim.api.nvim_buf_is_valid(buf) then
          return -- Buffer no longer valid
        end
        
        local has_treesitter = pcall(require, "nvim-treesitter.configs")
        if has_treesitter then
          local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
          if ts_highlight_ok and ts_highlight then
            local highlighter_active = ts_highlight.active and ts_highlight.active[buf] ~= nil
            local status_msg = "Tree-sitter highlighter status (check " .. check_count .. "): " .. 
                              (highlighter_active and "active" or "not active")
            print(status_msg)
            
            -- Continue checking for up to 3 attempts
            if not highlighter_active and check_count < 3 then
              vim.defer_fn(check_status, 150)
            elseif highlighter_active then
              print("✓ MyST highlighting successfully activated!")
            elseif check_count >= 3 then
              print("⚠ MyST highlighting may not have activated properly. Try :MystDisable then :MystEnable")
            end
          end
        end
      end
      
      -- Start checking status after initial delay
      vim.defer_fn(check_status, 200)
    else
      print("MyST highlighting refresh failed - " .. (message or "unknown error"))
      print("Consider trying :MystDisable followed by :MystEnable")
    end
  end, { desc = 'Force refresh MyST highlighting for current buffer with enhanced reliability' })
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