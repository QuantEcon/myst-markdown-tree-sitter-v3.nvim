;; MyST Markdown Highlighting Queries
;; Extends the base markdown highlighting with MyST-specific patterns

;; Code cell directives
(fenced_code_block
  (fenced_code_block_delimiter) @myst.directive.delimiter
  (info_string
    (language) @myst.directive.language
    (#match? @myst.directive.language "^{code-cell}"))
  (code_fence_content) @myst.code_content
) @myst.code_cell

;; MyST directive blocks ```{directive_name} args
(fenced_code_block
  (fenced_code_block_delimiter) @myst.directive.delimiter
  (info_string
    (language) @myst.directive.name
    (#match? @myst.directive.name "^{[%w%-_]+}"))
) @myst.directive

;; MyST roles {role_name}`content`
(inline_code
  (#match? @_content "^{[%w%-_]+}`[^`]*`$")
) @myst.role

;; Block directives starting with :::
(paragraph
  (text) @myst.block_directive
  (#match? @myst.block_directive "^:::{[%w%-_]+}")
)