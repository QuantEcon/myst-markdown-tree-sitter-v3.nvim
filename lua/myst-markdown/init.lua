local M = {}

-- Setup function for the MyST markdown plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Set up syntax highlighting
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "myst",
    callback = function()
      -- Use markdown tree-sitter for base highlighting
      if pcall(require, "nvim-treesitter") then
        require("nvim-treesitter.configs").setup({
          ensure_installed = {"markdown", "markdown_inline"},
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = {"myst"},
          },
        })
        
        -- Start tree-sitter highlighting for markdown
        vim.cmd("setlocal syntax=markdown")
        if vim.treesitter.highlighter then
          vim.treesitter.highlighter.new(vim.treesitter.get_parser(0, "markdown"))
        end
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
  
  -- Set up code-cell highlighting
  M.setup_code_cell_highlighting()
end

-- Setup highlighting for code-cell directives
function M.setup_code_cell_highlighting()
  local ns_id = vim.api.nvim_create_namespace("myst_code_cell")
  
  -- Function to highlight code-cell blocks
  local function highlight_code_cells()
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
        local start_pos = line:find("{code%-cell}")
        if start_pos then
          vim.api.nvim_buf_set_extmark(0, ns_id, i-1, start_pos-1, {
            end_col = start_pos + 10, -- length of "code-cell"
            hl_group = "MystDirectiveName"
          })
        end
        
        -- Highlight the language argument
        local lang_start = line:find(lang, start_pos)
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
      end
      
      -- Match block directives
      local block_directive = line:match("^:::{([%w%-_]+)}")
      if block_directive then
        vim.api.nvim_buf_set_extmark(0, ns_id, i-1, 0, {
          end_col = #line,
          hl_group = "MystDirective"
        })
      end
      
      -- Match MyST roles
      local role_match = line:match("{([%w%-_]+)}`[^`]*`")
      if role_match then
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
  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "BufEnter"}, {
    buffer = 0,
    callback = function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
      highlight_code_cells()
    end
  })
  
  -- Initial highlighting
  highlight_code_cells()
end

return M