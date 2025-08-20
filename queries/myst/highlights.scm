;; MyST Markdown Highlighting Queries
;; Extends the base markdown highlighting with MyST-specific patterns
;; Focus only on code-cell directives to preserve base markdown highlighting

;; Code cell directive info_string highlighting only
;; Let tree-sitter handle the content with normal language highlighting
(fenced_code_block
  (info_string) @myst.code_cell.directive
  (#match? @myst.code_cell.directive "^\\{code-cell\\}")
)