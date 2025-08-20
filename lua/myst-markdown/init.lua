local M = {}

-- Setup function for the MyST markdown plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Set up syntax highlighting
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
            additional_vim_regex_highlighting = {"myst"},
          },
        })
        
        -- Use markdown syntax as base
        vim.cmd("setlocal syntax=markdown")
        
        -- Try to start tree-sitter highlighting
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
      
      -- Set up MyST-specific highlighting
      M.setup_myst_highlighting()
    end
  })
end

-- Setup MyST-specific highlighting
function M.setup_myst_highlighting()
  -- Create highlight groups for MyST elements
  vim.api.nvim_set_hl(0, "MystDirective", { link = "PreProc" })
  vim.api.nvim_set_hl(0, "MystDirectiveName", { link = "Function" })
  vim.api.nvim_set_hl(0, "MystDirectiveArg", { link = "String" })
  vim.api.nvim_set_hl(0, "MystRole", { link = "Identifier" })
  vim.api.nvim_set_hl(0, "MystCodeCell", { link = "Special" })
  vim.api.nvim_set_hl(0, "MystBlockDirective", { link = "Keyword" })
  
  -- Set up code-cell highlighting
  M.setup_code_cell_highlighting()
end

-- Setup highlighting for code-cell directives and other MyST elements
function M.setup_code_cell_highlighting()
  local ns_id = vim.api.nvim_create_namespace("myst_highlighting")
  
  -- Function to highlight MyST elements
  local function highlight_myst_elements()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    for i, line in ipairs(lines) do
      -- Match code-cell directive with language
      local lang = line:match("^```{code%-cell}%s+([%w%-_]+)")
      if lang then
        -- Highlight the directive line
        vim.api.nvim_buf_set_extmark(0, ns_id, i-1, 0, {
          end_col = #line,
          hl_group = "MystCodeCell"
        })
        
        -- Highlight the directive syntax specifically
        local directive_start = line:find("{code%-cell}")
        if directive_start then
          vim.api.nvim_buf_set_extmark(0, ns_id, i-1, directive_start-1, {
            end_col = directive_start + 10, -- length of "code-cell"
            hl_group = "MystDirectiveName"
          })
        end
        
        -- Highlight the language argument
        local lang_start = line:find(lang, directive_start or 1)
        if lang_start then
          vim.api.nvim_buf_set_extmark(0, ns_id, i-1, lang_start-1, {
            end_col = lang_start + #lang - 1,
            hl_group = "MystDirectiveArg"
          })
        end
      end
      
      -- Match other MyST directives
      local directive = line:match("^```{([%w%-_]+)}")
      if directive and directive ~= "code-cell" then
        vim.api.nvim_buf_set_extmark(0, ns_id, i-1, 0, {
          end_col = #line,
          hl_group = "MystDirective"
        })
        
        -- Highlight directive name
        local dir_start = line:find("{" .. directive .. "}")
        if dir_start then
          vim.api.nvim_buf_set_extmark(0, ns_id, i-1, dir_start, {
            end_col = dir_start + #directive - 1,
            hl_group = "MystDirectiveName"
          })
        end
      end
      
      -- Match block directives (:::)
      local block_directive = line:match("^:::{([%w%-_]+)}")
      if block_directive then
        vim.api.nvim_buf_set_extmark(0, ns_id, i-1, 0, {
          end_col = #line,
          hl_group = "MystBlockDirective"
        })
        
        -- Highlight directive name
        local dir_start = line:find("{" .. block_directive .. "}")
        if dir_start then
          vim.api.nvim_buf_set_extmark(0, ns_id, i-1, dir_start, {
            end_col = dir_start + #block_directive - 1,
            hl_group = "MystDirectiveName"
          })
        end
      end
      
      -- Match MyST roles {role}`content`
      for role_match in line:gmatch("{([%w%-_]+)}`[^`]*`") do
        local role_start = line:find("{" .. role_match .. "}")
        if role_start then
          vim.api.nvim_buf_set_extmark(0, ns_id, i-1, role_start-1, {
            end_col = role_start + #role_match + 1,
            hl_group = "MystRole"
          })
        end
      end
    end
  end
  
  -- Set up autocommands to trigger highlighting
  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "BufEnter", "BufRead"}, {
    buffer = 0,
    callback = function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
      highlight_myst_elements()
    end
  })
  
  -- Initial highlighting
  vim.schedule(function()
    highlight_myst_elements()
  end)
end

return M