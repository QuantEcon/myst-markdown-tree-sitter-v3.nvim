;; MyST Markdown Highlighting Queries
;; Extends the base markdown highlighting with MyST-specific patterns

;; Code cell directives ```{code-cell} language
(fenced_code_block
  (fenced_code_block_delimiter) @punctuation.delimiter
  (info_string) @myst.directive
  (code_fence_content) @none
  (#match? @myst.directive "^{code-cell}")
) @myst.code_cell

;; MyST directive blocks ```{directive_name}
(fenced_code_block
  (fenced_code_block_delimiter) @punctuation.delimiter
  (info_string) @myst.directive
  (#match? @myst.directive "^{[%w%-_]+}")
) @myst.directive.block

;; MyST roles {role_name}`content` - this is trickier in tree-sitter
;; We'll handle this in the lua code for now

;; YAML frontmatter (common in MyST)
(minus_metadata
  (yaml_metadata) @markup.raw.block
) @myst.frontmatter