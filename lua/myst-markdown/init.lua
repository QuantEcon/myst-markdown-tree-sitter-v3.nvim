local M = {}

-- Default configuration
M.config = {
  default_code_cell_language = "python"
}

-- Setup function for the MyST markdown plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Merge user options with defaults (with fallback for non-vim environments)
  if vim and vim.tbl_deep_extend then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  else
    -- Simple merge for testing environments
    for k, v in pairs(opts) do
      M.config[k] = v
    end
  end
  
  -- Generate injection queries with configured default language
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

-- Setup injection queries with configured default language
function M.setup_injection_queries()
  local default_lang = M.config.default_code_cell_language
  
  -- Skip dynamic query generation in test environments
  if not vim or not vim.fn then
    return
  end
  
  -- Get the queries directory
  local queries_dir = vim.fn.stdpath('data') .. '/lazy/myst-markdown-tree-sitter-v3.nvim/queries'
  
  -- If the plugin is installed in different location, try to find it
  if vim.fn.isdirectory(queries_dir) == 0 then
    -- Try runtime path
    local runtime_paths = vim.api.nvim_list_runtime_paths()
    for _, path in ipairs(runtime_paths) do
      if path:match('myst%-markdown') then
        queries_dir = path .. '/queries'
        break
      end
    end
  end
  
  -- Generate MyST injection queries
  local myst_injection_content = string.format([[;; MyST Markdown Language Injection Queries
;; These queries tell tree-sitter to parse code-cell content with appropriate language parsers

;; Standard markdown language injection (preserve existing behavior)
((fenced_code_block
  (info_string) @injection.language
  (code_fence_content) @injection.content)
  (#not-eq? @injection.language "")
  (#not-match? @injection.language "^\\{"))

;; MyST code-cell injection patterns
;; Inject Python parser into code-cell python blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} python")
  (#set! injection.language "python"))

;; Inject JavaScript parser into code-cell javascript blocks  
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} javascript")
  (#set! injection.language "javascript"))

;; Inject Bash parser into code-cell bash blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} bash")
  (#set! injection.language "bash"))

;; Inject R parser into code-cell r blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} r")
  (#set! injection.language "r"))

;; Inject Julia parser into code-cell julia blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} julia")
  (#set! injection.language "julia"))

;; Inject C++ parser into code-cell cpp blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} cpp")
  (#set! injection.language "cpp"))

;; Inject C parser into code-cell c blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} c")
  (#set! injection.language "c"))

;; Inject Rust parser into code-cell rust blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} rust")
  (#set! injection.language "rust"))

;; Inject Go parser into code-cell go blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} go")
  (#set! injection.language "go"))

;; Inject TypeScript parser into code-cell typescript blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} typescript")
  (#set! injection.language "typescript"))

;; Handle code-cell blocks without explicit language (default to configured language)
((fenced_code_block
  (info_string) @_directive
  (code_fence_content) @injection.content)
  (#eq? @_directive "{code-cell}")
  (#set! injection.language "%s"))]], default_lang)

  -- Generate markdown injection queries
  local markdown_injection_content = string.format([[;; MyST Markdown Language Injection Queries (Enhanced)
;; These queries extend standard markdown with MyST code-cell support

;; MyST code-cell injection patterns (processed first)
;; Inject Python parser into code-cell python blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} python")
  (#set! injection.language "python"))

;; Inject JavaScript parser into code-cell javascript blocks  
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} javascript")
  (#set! injection.language "javascript"))

;; Inject Bash parser into code-cell bash blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} bash")
  (#set! injection.language "bash"))

;; Inject R parser into code-cell r blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} r")
  (#set! injection.language "r"))

;; Inject Julia parser into code-cell julia blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} julia")
  (#set! injection.language "julia"))

;; Inject C++ parser into code-cell cpp blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} cpp")
  (#set! injection.language "cpp"))

;; Inject C parser into code-cell c blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} c")
  (#set! injection.language "c"))

;; Inject Rust parser into code-cell rust blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} rust")
  (#set! injection.language "rust"))

;; Inject Go parser into code-cell go blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} go")
  (#set! injection.language "go"))

;; Inject TypeScript parser into code-cell typescript blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} typescript")
  (#set! injection.language "typescript"))

;; Handle code-cell blocks without explicit language (default to configured language)
((fenced_code_block
  (info_string) @_directive
  (code_fence_content) @injection.content)
  (#eq? @_directive "{code-cell}")
  (#set! injection.language "%s"))

;; Standard markdown language injection (preserve existing behavior)
;; This handles regular markdown code blocks like ```python
((fenced_code_block
  (info_string) @injection.language
  (code_fence_content) @injection.content)
  (#not-eq? @injection.language "")
  (#not-match? @injection.language "^\\{"))]], default_lang)

  -- Write the injection query files (only if we can write to the queries directory)
  local myst_dir = queries_dir .. '/myst'
  local markdown_dir = queries_dir .. '/markdown'
  
  if vim.fn.isdirectory(myst_dir) == 1 and vim.fn.filewritable(myst_dir) == 2 then
    local myst_file = io.open(myst_dir .. '/injections.scm', 'w')
    if myst_file then
      myst_file:write(myst_injection_content)
      myst_file:close()
    end
  end
  
  if vim.fn.isdirectory(markdown_dir) == 1 and vim.fn.filewritable(markdown_dir) == 2 then
    local markdown_file = io.open(markdown_dir .. '/injections.scm', 'w')
    if markdown_file then
      markdown_file:write(markdown_injection_content)
      markdown_file:close()
    end
  end
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
  print("Default code-cell language: " .. M.config.default_code_cell_language)
  
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